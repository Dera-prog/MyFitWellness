"""Warp the live app screenshot onto the blank phone screen in a generated plate."""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

plate_path, shot_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
plate = Image.open(plate_path).convert("RGB")
a = np.asarray(plate).astype(int)
h, w, _ = a.shape

# Screen = bright, near-neutral pixels (skin is warm: green channel lower)
mn = a.min(axis=2)
mx = a.max(axis=2)
bright = (mn > 196) & ((mx - mn) < 20)

rows = []
for y in range(h):
    xs = np.flatnonzero(bright[y])
    if xs.size < 150:
        continue
    splits = np.split(xs, np.flatnonzero(np.diff(xs) > 4) + 1)
    run = max(splits, key=len)
    if len(run) > 150:
        rows.append((y, int(run[0]), int(run[-1])))

if not rows:
    raise SystemExit("no screen found")
ys = np.array([r[0] for r in rows])
xl = np.array([r[1] for r in rows], dtype=float)
xr = np.array([r[2] for r in rows], dtype=float)

# Fit left/right edges over the straight middle section, then extrapolate to true rect
keep = (ys > ys.min() + (ys.max() - ys.min()) * 0.15) & (
    ys < ys.max() - (ys.max() - ys.min()) * 0.15
)
cl = np.polyfit(ys[keep], xl[keep], 1)
cr = np.polyfit(ys[keep], xr[keep], 1)
y0, y1 = int(ys.min()) + 2, int(ys.max()) - 2
quad = [
    (np.polyval(cl, y0), y0),
    (np.polyval(cr, y0), y0),
    (np.polyval(cr, y1), y1),
    (np.polyval(cl, y1), y1),
]
sw = (quad[1][0] - quad[0][0] + quad[2][0] - quad[3][0]) / 2
sh = y1 - y0
print(f"screen quad {[(round(x,1), round(y,1)) for x, y in quad]} size {sw:.0f}x{sh} aspect {sw/sh:.3f}")

shot = Image.open(shot_path).convert("RGB")
dw, dh = shot.size
print(f"shot {dw}x{dh} aspect {dw/dh:.3f}")


def coeffs(dest, src):
    m = []
    for (x, y), (u, v) in zip(dest, src):
        m.append([x, y, 1, 0, 0, 0, -u * x, -u * y])
        m.append([0, 0, 0, x, y, 1, -v * x, -v * y])
    A = np.array(m, dtype=float)
    B = np.array(src, dtype=float).reshape(8)
    return np.linalg.solve(A, B)


src_rect = [(0, 0), (dw, 0), (dw, dh), (0, dh)]
c = coeffs(quad, src_rect)
warped = shot.transform((w, h), Image.PERSPECTIVE, c, Image.BICUBIC)

radius = int(sw * 0.088)
mask = Image.new("L", (dw, dh), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, dw - 1, dh - 1], radius=radius, fill=255)
mask = mask.transform((w, h), Image.PERSPECTIVE, c, Image.BICUBIC).filter(
    ImageFilter.GaussianBlur(0.7)
)

# Screen glass: slight corner falloff + soft diagonal reflection
yy, xx = np.mgrid[0:h, 0:w]
cx, cy = (quad[0][0] + quad[2][0]) / 2, (quad[0][1] + quad[2][1]) / 2
r = np.sqrt(((xx - cx) / (sw * 0.75)) ** 2 + ((yy - cy) / (sh * 0.75)) ** 2)
vignette = np.clip(1.0 - 0.10 * r ** 2, 0.9, 1.0)
glass = (xx / w * 0.55 + (1 - yy / h) * 0.45)
gloss = np.clip((glass - 0.62) * 0.30, 0, 0.055)

arr = np.asarray(warped).astype(float)
arr *= vignette[..., None]
arr = arr * (1 - gloss[..., None]) + 255 * gloss[..., None]
# Warm the panel to sit in the plate's tungsten light
arr[..., 0] *= 1.005
arr[..., 2] *= 0.975
arr = np.clip(arr * 0.985, 0, 255).astype(np.uint8)
layered = Image.fromarray(arr)

out = plate.copy()
out.paste(layered, (0, 0), mask)

# Inner shadow so the panel sits under the bezel instead of on top of it
inv = mask.filter(ImageFilter.GaussianBlur(5)).point(lambda v: 255 - v)
edge = Image.fromarray(
    (np.asarray(inv, dtype=float) * np.asarray(mask, dtype=float) / 255 * 0.20).astype(np.uint8)
)
out.paste(Image.new("RGB", out.size, (10, 8, 4)), (0, 0), edge)

out = out.resize((1200, 1200), Image.LANCZOS).filter(
    ImageFilter.UnsharpMask(radius=1.4, percent=55, threshold=3)
)
out.save(out_path)
print("wrote", out_path, out.size)