import { spawn } from 'node:child_process';
import fs from 'node:fs';

const EDGE = 'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe';
const PORT = 9334;
const URL = 'http://127.0.0.1:4789/';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const proc = spawn(
  EDGE,
  [
    '--headless=new',
    '--disable-gpu',
    '--hide-scrollbars',
    '--no-first-run',
    `--remote-debugging-port=${PORT}`,
    `--user-data-dir=${process.env.TEMP}/edge-dbg-${Date.now()}`,
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
  if (msg.method === 'Runtime.consoleAPICalled') {
    console.log('console:', msg.params.args.map((a) => a.value ?? a.description).join(' '));
  }
  if (msg.method === 'Runtime.exceptionThrown') {
    console.log('exception:', msg.params.exceptionDetails.text, msg.params.exceptionDetails.exception?.description);
  }
  if (msg.method === 'Network.loadingFailed') {
    console.log('failed:', msg.params.type, msg.params.errorText, msg.params.blockedReason ?? '');
  }
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
await send('Network.enable');
await send('Emulation.setDeviceMetricsOverride', {
  width: 390,
  height: 844,
  deviceScaleFactor: 2,
  mobile: true,
});
await send('Page.navigate', { url: URL });
await sleep(12000);
const evalRes = await send('Runtime.evaluate', {
  expression: `JSON.stringify({url: location.href, title: document.title, html: document.body.innerHTML.length, canvases: [...document.querySelectorAll('canvas')].map(c => [c.width, c.height, c.clientWidth, c.clientHeight]), flt: !!document.querySelector('flutter-view')})`,
  returnByValue: true,
});
console.log('state:', evalRes.result?.result?.value);
const shot = await send('Page.captureScreenshot', { format: 'png' });
fs.writeFileSync('qa/debug.png', Buffer.from(shot.result.data, 'base64'));
ws.close();
proc.kill();
process.exit(0);
