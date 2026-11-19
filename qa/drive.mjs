import { spawn } from 'node:child_process';
import fs from 'node:fs';

const EDGE = 'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe';
const PORT = 9333;
const URL = 'http://127.0.0.1:4789/';
const OUT = 'qa';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const profile = process.env.TEMP + '/edge-qa-' + Date.now();
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
  for (let i = 0; i < 60; i++) {
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
await send('Emulation.setDeviceMetricsOverride', {
  width: 390,
  height: 844,
  deviceScaleFactor: 2,
  mobile: true,
});
await send('Page.navigate', { url: URL });

async function shot(name) {
  const res = await send('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(`${OUT}/${name}.png`, Buffer.from(res.result.data, 'base64'));
  console.log('shot', name);
}

async function click(x, y) {
  for (const type of ['mousePressed', 'mouseReleased']) {
    await send('Input.dispatchMouseEvent', {
      type,
      x,
      y,
      button: 'left',
      clickCount: 1,
      buttons: type === 'mousePressed' ? 1 : 0,
    });
    await sleep(40);
  }
  await sleep(650);
}

const steps = JSON.parse(process.argv[2] ?? '[]');
for (const step of steps) {
  if (step.wait) await sleep(step.wait);
  if (step.click) await click(step.click[0], step.click[1]);
  if (step.shot) await shot(step.shot);
  if (step.scroll) {
    await send('Input.dispatchMouseEvent', {
      type: 'mouseWheel',
      x: 195,
      y: 400,
      deltaY: step.scroll,
      deltaX: 0,
    });
    await sleep(700);
  }
}

ws.close();
proc.kill();
process.exit(0);
