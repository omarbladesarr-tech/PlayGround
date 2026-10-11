#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PROJECT_DIR="$(/usr/bin/time -p pwd)"
/usr/bin/time -p pwd
DIST_DIR="$PROJECT_DIR/dist"
PORT="${PORT:-3000}"
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
# Install dependencies when a root package.json exists (timed, no-op otherwise).
if /usr/bin/time -p test -f "$PROJECT_DIR/package.json"; then
  if /usr/bin/time -p test -f "$PROJECT_DIR/package-lock.json"; then
    /usr/bin/time -p npm --prefix "$PROJECT_DIR" ci --no-audit --no-fund
  else
    /usr/bin/time -p npm --prefix "$PROJECT_DIR" install --no-audit --no-fund
  fi
  if /usr/bin/time -p node -e "const p=require('./package.json'); process.exit(p.scripts&&p.scripts.build?0:1)"; then
    /usr/bin/time -p npm --prefix "$PROJECT_DIR" run build
  fi
fi
# Build check: built output must exist inside PROJECT_DIR.
/usr/bin/time -p test -f "$DIST_DIR/index.html"
/usr/bin/time -p mkdir -p "$WEB_DIR"
export DIST_DIR PORT PROJECT_DIR WEB_DIR
/usr/bin/time -p node -e "const fs=require('fs'); const path=require('path'); const project=process.env.PROJECT_DIR||process.cwd(); const dir=process.env.DIST_DIR; const out=process.env.WEB_DIR+'/deployment-output.json'; fs.writeFileSync(out, JSON.stringify({project, directory: path.resolve(dir)})); console.log('wrote '+out)"
# Serve built static directory in the foreground on PORT.
/usr/bin/time -p node -e "
const http=require('http'), fs=require('fs'), path=require('path');
const root=process.env.DIST_DIR, port=Number(process.env.PORT||3000);
const mime={'.html':'text/html','.js':'application/javascript','.css':'text/css','.json':'application/json','.svg':'image/svg+xml','.png':'image/png','.jpg':'image/jpeg','.webp':'image/webp','.wasm':'application/wasm','.glb':'model/gltf-binary'};
const server=http.createServer((req,res)=>{ try{
  const u=new URL(req.url,'http://localhost');
  let p=path.resolve(root,'.'+decodeURIComponent(u.pathname));
  if(p!==path.resolve(root)&&!p.startsWith(path.resolve(root)+path.sep)){res.writeHead(404);res.end();return;}
  try{ if(fs.statSync(p).isDirectory()) p=path.join(p,'index.html'); }catch{ p=path.join(root,'index.html'); }
  const ext=path.extname(p);
  res.setHeader('Content-Type',mime[ext]||'application/octet-stream');
  res.setHeader('Cache-Control','no-cache');
  res.end(fs.readFileSync(p));
}catch{res.writeHead(404);res.end('Not found');} });
server.listen(port,'0.0.0.0',()=>console.log('serving '+root+' on '+port));
"
