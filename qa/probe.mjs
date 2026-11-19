import { spawn } from 'node:child_process';
import fs from 'node:fs';
const EDGE='C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe';
const sleep=(ms)=>new Promise(r=>setTimeout(r,ms));
const flag=process.argv[2]||'--headless=new';
const port=9600+Math.floor(Math.random()*100);
const proc=spawn(EDGE,[flag,'--disable-gpu','--hide-scrollbars','--window-size=390,844',`--remote-debugging-port=${port}`,`--user-data-dir=${process.env.TEMP}/p-${Date.now()}`,'about:blank'],{stdio:'ignore'});
let page;
for(let i=0;i<80;i++){try{const l=await(await fetch(`http://127.0.0.1:${port}/json/list`)).json();page=l.find(t=>t.type==='page');if(page)break;}catch{}await sleep(250);}
if(!page){console.log('NO PAGE');process.exit(1);}
const ws=new WebSocket(page.webSocketDebuggerUrl);let seq=0;const pend=new Map();
ws.onmessage=e=>{const m=JSON.parse(e.data);if(m.id&&pend.has(m.id)){pend.get(m.id)(m);pend.delete(m.id);}};
await new Promise(r=>ws.onopen=r);
const send=(method,params={})=>new Promise(res=>{const id=++seq;pend.set(id,res);ws.send(JSON.stringify({id,method,params}));});
await send('Page.enable');
await send('Page.navigate',{url:'http://127.0.0.1:4789/'});
await sleep(7000);
await send('Input.dispatchMouseEvent',{type:'mouseMoved',x:190,y:400});
await sleep(600);
let r=await send('Page.captureScreenshot',{format:'png'});
fs.writeFileSync('qa/p1.png',Buffer.from(r.result.data,'base64'));
await send('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:2,mobile:true});
await sleep(1200);
r=await send('Page.captureScreenshot',{format:'png'});
fs.writeFileSync('qa/p2.png',Buffer.from(r.result.data,'base64'));
const e=await send('Runtime.evaluate',{expression:`(()=>{const fv=document.querySelector('flutter-view');const sr=fv&&fv.shadowRoot;return JSON.stringify({inner:[innerWidth,innerHeight],dpr:devicePixelRatio,shadow: sr? sr.innerHTML.slice(0,400):null});})()`,returnByValue:true});
console.log(e.result.result.value);
ws.close();proc.kill();process.exit(0);
