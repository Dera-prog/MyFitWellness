import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(process.argv[2] ?? 'build/web');
const port = Number(process.argv[3] ?? 8099);

const types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.css': 'text/css; charset=utf-8',
  '.ico': 'image/x-icon',
  '.bin': 'application/octet-stream',
  '.map': 'application/json; charset=utf-8',
};

http
  .createServer((req, res) => {
    const url = decodeURIComponent((req.url || '/').split('?')[0]);
    let file = path.join(root, url);
    if (url.endsWith('/')) file = path.join(file, 'index.html');
    fs.stat(file, (err, stat) => {
      if (err || stat.isDirectory()) {
        const siteRoot =
          path.basename(root) === 'site' ? root : path.join(root, 'site');
        const wantsSite = url === '/site' || url.startsWith('/site/');
        file =
          wantsSite || path.basename(root) === 'site'
            ? path.join(siteRoot, 'index.html')
            : path.join(root, 'index.html');
      }
      fs.readFile(file, (readErr, data) => {
        if (readErr) {
          res.writeHead(404);
          res.end('not found');
          return;
        }
        res.writeHead(200, {
          'Content-Type': types[path.extname(file).toLowerCase()] ?? 'application/octet-stream',
          'Cache-Control': 'no-store',
        });
        res.end(data);
      });
    });
  })
  .listen(port, '127.0.0.1', () => console.log(`serving ${root} on http://127.0.0.1:${port}`));
