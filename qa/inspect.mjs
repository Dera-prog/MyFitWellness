import fs from 'node:fs';
const port=process.argv[2]||'9755';
const sleep=(ms)=>new Promise(r=>setTimeout(r,ms));
const list=await(await fetch(`http://127.0.0.1:${port}/json/list`)).json();
const page=list.find(t=>t.url.startsWith('http://127.0.0.1:4789'));
if(!page){console.log('no app target');process.exit(1);}
const ws=new WebSocket(page.webSocketDebuggerUrl);let seq=0;const pend=new Map();
ws.onmessage=e=>{const m=JSON.parse(e.data);
 if(m.method==='Runtime.consoleAPICalled'){console.log('console',m.params.type+':',m.params.args.map(a=>a.value??a.description).join(' ').slice(0,300));}
 if(m.method==='Runtime.exceptionThrown'){console.log('EXC:',m.params.exceptionDetails.text,(m.params.exceptionDetails.exception?.description||'').slice(0,600));}
 if(m.method==='Log.entryAdded'){console.log('log',m.params.entry.level+':',m.params.entry.text.slice(0,300));}
 if(m.id&&pend.has(m.id)){pend.get(m.id)(m);pend.delete(m.id);}};
await new Promise(r=>ws.onopen=r);
const send=(method,params={})=>new Promise(res=>{const id=++seq;pend.set(id,res);ws.send(JSON.stringify({id,method,params}));});
await send('Runtime.enable');await send('Log.enable');await send('Page.enable');
await send('Page.reload',{ignoreCache:true});
await sleep(8000);
const ev=await send('Runtime.evaluate',{expression:`(()=>{const fv=document.querySelector('flutter-view');const sr=fv&&fv.shadowRoot;const c=sr?[...sr.querySelectorAll('canvas')].map(x=>[x.width,x.height]):null;return JSON.stringify({rs:document.readyState,fv:!!fv,canvases:c,body:document.body.innerHTML.slice(0,300)});})()`,returnByValue:true});
console.log('state',ev.result?.result?.value);
const r=await send('Page.captureScreenshot',{format:'png'});
fs.writeFileSync('qa/inspect.png',Buffer.from(r.result.data,'base64'));
ws.close();process.exit(0);
