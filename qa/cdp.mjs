// Usage:
//   node qa/cdp.mjs info
//   node qa/cdp.mjs click <x> <y>        (CSS px)
//   node qa/cdp.mjs drag <x1> <y1> <x2> <y2>
//   node qa/cdp.mjs eval "<js>"
const port = process.env.CDP_PORT || 9756;
const cmd = process.argv[2] || 'info';

const list = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
const target = list.find((t) => t.type === 'page' && t.url.includes('4789'));
if (!target) { console.log('NO_TARGET', list.map((t) => t.url)); process.exit(1); }

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

const clickAt = async (x, y) => {
  await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y, button: 'none', buttons: 0, clickCount: 0 });
  await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', buttons: 1, clickCount: 1 });
  await new Promise((r) => setTimeout(r, 60));
  await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', buttons: 0, clickCount: 1 });
};

if (cmd === 'info') {
  const r = await send('Runtime.evaluate', { expression: 'JSON.stringify({w:innerWidth,h:innerHeight,dpr:devicePixelRatio})', returnByValue: true });
  console.log(r.result.result.value);
} else if (cmd === 'click') {
  const [x, y] = process.argv.slice(3, 5).map(Number);
  await clickAt(x, y);
  console.log('clicked', x, y);
} else if (cmd === 'drag') {
  const [x1, y1, x2, y2] = process.argv.slice(3, 7).map(Number);
  await send('Input.dispatchMouseEvent', { type: 'mousePressed', x: x1, y: y1, button: 'left', buttons: 1, clickCount: 1 });
  for (let i = 1; i <= 12; i++) {
    const t = i / 12;
    await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: x1 + (x2 - x1) * t, y: y1 + (y2 - y1) * t, button: 'left', buttons: 1 });
    await new Promise((r) => setTimeout(r, 16));
  }
  await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: x2, y: y2, button: 'left', buttons: 0, clickCount: 1 });
  console.log('dragged', x1, y1, x2, y2);
} else if (cmd === 'wheel') {
  const [x, y, dy] = process.argv.slice(3, 6).map(Number);
  await send('Input.dispatchMouseEvent', { type: 'mouseWheel', x, y, deltaX: 0, deltaY: dy });
  console.log('wheel', dy);
} else if (cmd === 'type') {
  await send('Input.insertText', { text: process.argv[3] ?? '' });
  console.log('typed');
} else if (cmd === 'key') {
  const key = process.argv[3] || 'Enter';
  await send('Input.dispatchKeyEvent', { type: 'keyDown', key, windowsVirtualKeyCode: key === 'Enter' ? 13 : 0 });
  await send('Input.dispatchKeyEvent', { type: 'keyUp', key, windowsVirtualKeyCode: key === 'Enter' ? 13 : 0 });
  console.log('key', key);
} else if (cmd === 'eval') {
  const r = await send('Runtime.evaluate', { expression: process.argv[3], returnByValue: true });
  console.log(JSON.stringify(r.result.result.value ?? r.result, null, 2));
}

ws.close();
process.exit(0);
