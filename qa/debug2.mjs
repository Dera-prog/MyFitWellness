import { spawn } from 'node:child_process';
import fs from 'node:fs';

const EDGE = 'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe';
const PORT = 9335;
const URL = 'http://127.0.0.1:4789/';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const proc = spawn(
  EDGE,
  [
    '--headless=new',
    '--disable-gpu',
    '--hide-scrollbars',
    '--no-first-run',
    '--window-size=390,844',
    `--remote-debugging-port=${PORT}`,
    `--user-data-dir=${process.env.TEMP}/edge-qa2-${Date.now()}`,
    'about:blank',
  ],
  { stdio: 'ignore' },
);

let page;
for (let i = 0; i < 60; i++) {
  try {
    const list = await (await fetch(`http://127.0.0.1:${PORT}/json/list`)).json();
    page = list.find((t) => t.type === 'page');
    if (page) break;
  } catch {}
  await sleep(250);
}

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
await send('Page.navigate', { url: URL });
await sleep(9000);

const a = await send('Page.captureScreenshot', { format: 'png' });
fs.writeFileSync('qa/t-a.png', Buffer.from(a.result.data, 'base64'));

const b = await send('Page.captureScreenshot', { format: 'png', fromSurface: false });
fs.writeFileSync('qa/t-b.png', Buffer.from(b.result.data, 'base64'));

const bounds = await send('Runtime.evaluate', {
  expression: `JSON.stringify({w: innerWidth, h: innerHeight, dpr: devicePixelRatio})`,
  returnByValue: true,
});
console.log(bounds.result?.result?.value);

ws.close();
proc.kill();
process.exit(0);
