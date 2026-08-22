const VERSION='jb-v12-premium-20260822';
self.addEventListener('install',()=>self.skipWaiting());
self.addEventListener('activate',event=>event.waitUntil((async()=>{for(const k of await caches.keys()) await caches.delete(k);await self.clients.claim();})()));
self.addEventListener('fetch',event=>{if(event.request.method==='GET') event.respondWith(fetch(event.request,{cache:'no-store'}).catch(()=>caches.match(event.request)));});
