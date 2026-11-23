// Local app QA: signs in by seeding the persisted token, then runs steps.
// node qa/verify.mjs '[{"wait":1000},{"shot":"home"}]'
import { spawn } from 'node:child_process';
import fs from 'node:fs';

const EDGE = 'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe';
const PORT = 9345;
const URL = process.env.APP_URL || 'http://127.0.0.1:8099/';
const OUT = 'qa';
const W = Number(process.env.VIEW_W || 1440);
const H = Number(process.env.VIEW_H || 900);

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const profile = process.env.TEMP + '/edge-verify-' + Date.now();
const proc = spawn(
  EDGE,
  [
    '--headless=new',
    '--disable-gpu',
    '--hide-scrollbars',
    '--no-first-run',
    '--no-default-browser-check',
    `--remote-debugging-port=${PORT}`,
    `--user-data-dir=${profile}`,
    'about:blank',
  ],
  { stdio: 'ignore' },
);

async function target() {
  for (let i = 0; i < 80; i++) {
    try {
      const list = await (await fetch(`http://127.0.0.1:${PORT}/json/list`)).json();
      const page = list.find((t) => t.type === 'page');
      if (page) return page;
    } catch {}
    await sleep(250);
  }
  throw new Error('no debuggable page');
}

const page = await target();
const ws = new WebSocket(page.webSocketDebuggerUrl);
let seq = 0;
const pending = new Map();
ws.onmessage = (ev) => {
  const msg = JSON.parse(ev.data);
  if (msg.id && pending.has(msg.id)) {
    pending.get(msg.id)(msg);
    pending.delete(msg.id);
  }
};
await new Promise((r) => (ws.onopen = r));
const send = (method, params = {}) =>
  new Promise((resolve) => {
    const id = ++seq;
    pending.set(id, resolve);
    ws.send(JSON.stringify({ id, method, params }));
  });

await send('Page.enable');
await send('Runtime.enable');
await send('Emulation.setDeviceMetricsOverride', {
  width: W,
  height: H,
  deviceScaleFactor: 1,
  mobile: W < 1000,
});
await send('Page.navigate', { url: URL });
await sleep(1500);

const token = fs.existsSync('qa/.token') ? fs.readFileSync('qa/.token', 'utf8').trim() : '';
if (token) {
  await send('Runtime.evaluate', {
    expression: `localStorage.setItem('flutter.mfw.token', JSON.stringify(${JSON.stringify(token)}))`,
  });
  await send('Page.reload');
}
await sleep(Number(process.env.BOOT_MS || 15000));

async function shot(name) {
  const res = await send('Page.captureScreenshot', { format: 'png' });
  if (!res.result?.data) {
    console.log('SHOT_FAIL', name, JSON.stringify(res).slice(0, 200));
    return;
  }
  fs.writeFileSync(`${OUT}/${name}.png`, Buffer.from(res.result.data, 'base64'));
  console.log('shot', name);
}

async function click(x, y) {
  await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y, button: 'none', buttons: 0 });
  await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', buttons: 1, clickCount: 1 });
  await sleep(60);
  await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', buttons: 0, clickCount: 1 });
  await sleep(800);
}

async function evaluate(expression) {
  const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
  const value = r.result?.result?.value ?? r.result;
  console.log('eval:', typeof value === 'string' ? value : JSON.stringify(value));
}

async function wheel(x, y, dy) {
  await send('Input.dispatchMouseEvent', {
    type: 'mouseWheel',
    x,
    y,
    deltaX: 0,
    deltaY: dy,
  });
  await sleep(700);
}

const steps = JSON.parse(process.argv[2] ?? '[]');
for (const step of steps) {
  if (step.wait) await sleep(step.wait);
  if (step.click) await click(step.click[0], step.click[1]);
  if (step.wheel) await wheel(step.wheel[0], step.wheel[1], step.wheel[2]);
  if (step.type) await send('Input.insertText', { text: step.type });
  if (step.eval) await evaluate(step.eval);
  if (step.shot) await shot(step.shot);
}

ws.close();
proc.kill();
process.exit(0);
