const port=process.argv[2];
const list=await(await fetch(`http://127.0.0.1:${port}/json/list`)).json();
const p=list.find(t=>t.url.includes('4789'));
const ws=new WebSocket(p.webSocketDebuggerUrl);
await new Promise(r=>ws.onopen=r);
ws.send(JSON.stringify({id:1,method:'Page.reload',params:{ignoreCache:true}}));
setTimeout(()=>{ws.close();process.exit(0);},600);
