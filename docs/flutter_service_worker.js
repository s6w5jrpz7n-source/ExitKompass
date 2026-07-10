// Kill-switch service worker.
//
// Earlier builds registered a Flutter offline service worker that cached the
// app aggressively, so new deploys did not show up (especially on iOS Safari).
// The app is now built with --pwa-strategy=none (no service worker), and this
// file replaces the old worker: when the browser checks for an update it picks
// this up, which unregisters itself, clears all caches and reloads open pages
// so the fresh version loads. After that no service worker is registered again.
self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    try {
      const keys = await caches.keys();
      await Promise.all(keys.map((k) => caches.delete(k)));
      await self.registration.unregister();
      const clients = await self.clients.matchAll({ type: 'window' });
      for (const client of clients) {
        client.navigate(client.url);
      }
    } catch (_) {
      // Best effort – nothing else to do.
    }
  })());
});

// Never serve from cache; always go to the network while this worker lives.
self.addEventListener('fetch', () => {});
