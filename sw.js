const CACHE='jb-torneios-v25-2';
const CORE=['./','./index.html','./manifest.webmanifest'];
self.addEventListener('install',e=>{self.skipWaiting();e.waitUntil(caches.open(CACHE).then(c=>c.addAll(CORE).catch(()=>{})))});
self.addEventListener('activate',e=>e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==CACHE).map(x=>caches.delete(x)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',e=>{if(e.request.method!=='GET')return;const q=e.request;if(q.mode==='navigate'){e.respondWith(fetch(q,{cache:'no-store'}).then(r=>{const x=r.clone();caches.open(CACHE).then(c=>c.put('./index.html',x)).catch(()=>{});return r}).catch(()=>caches.match('./index.html')));return}e.respondWith(caches.match(q).then(cached=>cached||fetch(q).then(r=>{if(r&&r.ok){const x=r.clone();caches.open(CACHE).then(c=>c.put(q,x)).catch(()=>{})}return r})))});
