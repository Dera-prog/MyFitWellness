param(
  [string]$Out = "qa\shot.png",
  [int]$ClickX = -1,
  [int]$ClickY = -1,
  [int]$Wait = 0,
  [int]$ProcId = 0
)

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W {
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, IntPtr pid);
  [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool attach);
  [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint flags);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr h, ref POINT p);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint dx, uint dy, uint d, UIntPtr e);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
  [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
}
"@

[void][W]::SetProcessDPIAware()

if ($ProcId -gt 0) {
  $proc = Get-Process -Id $ProcId -ErrorAction SilentlyContinue
} else {
  $proc = Get-Process msedge -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowTitle -eq 'MyFitWellness' } |
    Select-Object -First 1
}

if (-not $proc) {
  Write-Output "NO_WINDOW"
  exit 1
}

[void][W]::ShowWindow($proc.MainWindowHandle, 9)
$h = $proc.MainWindowHandle
$fg = [W]::GetForegroundWindow()
$fgThread = [W]::GetWindowThreadProcessId($fg, [IntPtr]::Zero)
$myThread = [W]::GetWindowThreadProcessId($h, [IntPtr]::Zero)
[void][W]::AttachThreadInput($myThread, $fgThread, $true)
[void][W]::BringWindowToTop($h)
[void][W]::SetForegroundWindow($h)
[void][W]::AttachThreadInput($myThread, $fgThread, $false)
Start-Sleep -Milliseconds 1100

$origin = New-Object W+POINT
$origin.X = 0; $origin.Y = 0
[void][W]::ClientToScreen($proc.MainWindowHandle, [ref]$origin)

$rect = New-Object W+RECT
[void][W]::GetClientRect($proc.MainWindowHandle, [ref]$rect)
$w = $rect.Right - $rect.Left
$h = $rect.Bottom - $rect.Top

if ($ClickX -ge 0 -and $ClickY -ge 0) {
  [void][W]::SetCursorPos($origin.X + $ClickX, $origin.Y + $ClickY)
  Start-Sleep -Milliseconds 80
  [W]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 70
  [W]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 100
}

if ($Wait -gt 0) { Start-Sleep -Milliseconds $Wait }

Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($origin.X, $origin.Y, 0, 0, (New-Object System.Drawing.Size($w, $h)))
$dir = Split-Path -Parent $Out
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
$bmp.Save((Resolve-Path (Split-Path -Parent $Out)).Path + "\" + (Split-Path -Leaf $Out), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "OK ${w}x${h} origin=$($origin.X),$($origin.Y) title=$($proc.MainWindowTitle)"
