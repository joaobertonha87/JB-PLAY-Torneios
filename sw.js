const CACHE='jb-torneios-v25-8-7';
const CORE=['./','./index.html','./jb-logo-lime.svg'];
self.addEventListener('install',e=>{self.skipWaiting();e.waitUntil(caches.open(CACHE).then(c=>c.addAll(CORE).catch(()=>{})))});
self.addEventListener('activate',e=>e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==CACHE).map(x=>caches.delete(x)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',e=>{if(e.request.method!=='GET')return;const q=e.request;if(q.mode==='navigate'){e.respondWith(fetch(q,{cache:'no-store'}).then(r=>{const x=r.clone();caches.open(CACHE).then(c=>c.put('./index.html',x)).catch(()=>{});return r}).catch(()=>caches.match('./index.html')));return}e.respondWith(caches.match(q).then(c=>c||fetch(q)))});
