import { spawn } from 'node:child_process';
import fs from 'node:fs';
const EDGE='C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe';
const sleep=(ms)=>new Promise(r=>setTimeout(r,ms));
const port=9500+Math.floor(Math.random()*100);
const proc=spawn(EDGE,['--headless=new','--disable-gpu','--hide-scrollbars','--window-size=390,844',`--remote-debugging-port=${port}`,`--user-data-dir=${process.env.TEMP}/v-${Date.now()}`,'about:blank'],{stdio:'ignore'});
let page;
for(let i=0;i<60;i++){try{const l=await(await fetch(`http://127.0.0.1:${port}/json/list`)).json();page=l.find(t=>t.type==='page');if(page)break;}catch{}await sleep(250);}
const ws=new WebSocket(page.webSocketDebuggerUrl);let seq=0;const pend=new Map();
ws.onmessage=e=>{const m=JSON.parse(e.data);if(m.id&&pend.has(m.id)){pend.get(m.id)(m);pend.delete(m.id);}};
await new Promise(r=>ws.onopen=r);
const send=(method,params={})=>new Promise(res=>{const id=++seq;pend.set(id,res);ws.send(JSON.stringify({id,method,params}));});
await send('Page.enable');
await send('Page.navigate',{url:'http://127.0.0.1:4789/'});
await sleep(1500);
async function budget(ms,name){
  await send('Emulation.setVirtualTimePolicy',{policy:'advance',budget:ms,maxVirtualTimeTaskStarvationCount:10000});
  await sleep(1500);
  const r=await send('Page.captureScreenshot',{format:'png'});
  fs.writeFileSync('qa/'+name+'.png',Buffer.from(r.result.data,'base64'));
  console.log('shot',name);
}
await budget(2500,'v-splash');
await budget(6000,'v-ad1');
ws.close();proc.kill();process.exit(0);
