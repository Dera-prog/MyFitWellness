// Headless QA driver.
//   node qa/shot.mjs shot <out.png> [waitMs]
//   node qa/shot.mjs click <x> <y> [waitMs] [out.png]
//   node qa/shot.mjs tap <x> <y> [waitMs] [out.png]
//   node qa/shot.mjs drag <x1> <y1> <x2> <y2> [waitMs] [out.png]
//   node qa/shot.mjs reload [waitMs] [out.png]
//   node qa/shot.mjs eval "<js>"
//   node qa/shot.mjs wait <ms>
import fs from 'node:fs';

const port = process.env.CDP_PORT || 9757;
const cmd = process.argv[2] || 'shot';
const url = process.env.APP_URL || 'http://127.0.0.1:4789/';

const list = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
let target = list.find((t) => t.type === 'page' && t.url.includes('4789'));
if (!target) {
  const created = await (await fetch(`http://127.0.0.1:${port}/json/new?${encodeURIComponent(url)}`, { method: 'PUT' })).json();
  target = created;
}
const ws = new WebSocket(target.webSocketDebuggerUrl);
let id = 0;
const pending = new Map();
const send = (method, params = {}) =>
  new Promise((res) => { const i = ++id; pending.set(i, res); ws.send(JSON.stringify({ id: i, method, params })); });
ws.onmessage = (e) => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
};
await new Promise((r) => (ws.onopen = r));

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const mouse = async (type, x, y, extra = {}) =>
  send('Input.dispatchMouseEvent', { type, x, y, button: 'left', clickCount: 1, ...extra });

const clickAt = async (x, y) => {
  await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y, button: 'none', buttons: 0 });
  await mouse('mousePressed', x, y, { buttons: 1 });
  await sleep(70);
  await mouse('mouseReleased', x, y, { buttons: 0 });
};

const shot = async (out) => {
  const r = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false });
  if (!r.result?.data) { console.log('SHOT_FAIL', JSON.stringify(r).slice(0, 300)); return; }
  fs.writeFileSync(out, Buffer.from(r.result.data, 'base64'));
  console.log('saved', out);
};

const wait = async (ms) => { if (ms) await sleep(ms); };

if (cmd === 'shot') {
  await wait(Number(process.argv[4] || 0));
  await shot(process.argv[3] || 'qa/headless.png');
} else if (cmd === 'click' || cmd === 'tap') {
  const [x, y] = process.argv.slice(3, 5).map(Number);
  await clickAt(x, y);
  await wait(Number(process.argv[5] || 800));
  await shot(process.argv[6] || 'qa/headless.png');
} else if (cmd === 'drag') {
  const [x1, y1, x2, y2] = process.argv.slice(3, 7).map(Number);
  await mouse('mousePressed', x1, y1, { buttons: 1 });
  for (let i = 1; i <= 12; i++) {
    const t = i / 12;
    await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: x1 + (x2 - x1) * t, y: y1 + (y2 - y1) * t, button: 'left', buttons: 1 });
    await sleep(16);
  }
  await mouse('mouseReleased', x2, y2, { buttons: 0 });
  await wait(Number(process.argv[7] || 800));
  await shot(process.argv[8] || 'qa/headless.png');
} else if (cmd === 'reload') {
  await send('Page.reload', { ignoreCache: true });
  await wait(Number(process.argv[3] || 12000));
  await shot(process.argv[4] || 'qa/headless.png');
} else if (cmd === 'eval') {
  const r = await send('Runtime.evaluate', { expression: process.argv[3], returnByValue: true });
  console.log(JSON.stringify(r.result?.result?.value ?? r.result, null, 2));
} else if (cmd === 'wait') {
  await sleep(Number(process.argv[3] || 1000));
  console.log('waited');
}

ws.close();
process.exit(0);
