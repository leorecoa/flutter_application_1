const CACHE_NAME = 'agendemais-v3.2-optimized';
const STATIC_CACHE_NAME = 'agendemais-static-v3.2';
const DYNAMIC_CACHE_NAME = 'agendemais-dynamic-v3.2';

// Static assets that rarely change
const staticAssets = [
  '/',
  '/manifest.json',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  '/flutter.js',
  '/flutter_bootstrap.js'
];

// Large assets that should be cached but can be updated
const dynamicAssets = [
  '/main.dart.js',
  '/flutter_service_worker.js'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    Promise.all([
      caches.open(STATIC_CACHE_NAME).then(cache => cache.addAll(staticAssets)),
      caches.open(DYNAMIC_CACHE_NAME).then(cache => cache.addAll(dynamicAssets))
    ])
  );
  self.skipWaiting(); // Activate immediately
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          // Delete old caches
          if (cacheName !== STATIC_CACHE_NAME && 
              cacheName !== DYNAMIC_CACHE_NAME && 
              cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim(); // Take control immediately
});

self.addEventListener('fetch', (event) => {
  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  // Don't cache API calls or external requests
  if (event.request.url.includes('/api/') || 
      event.request.url.includes('amazonaws.com') ||
      event.request.url.includes('http') && !event.request.url.includes(self.location.origin)) {
    event.respondWith(fetch(event.request));
    return;
  }

  event.respondWith(
    caches.match(event.request).then(response => {
      if (response) {
        return response;
      }

      return fetch(event.request).then(fetchResponse => {
        // Only cache successful responses
        if (!fetchResponse.ok) {
          return fetchResponse;
        }

        const responseClone = fetchResponse.clone();
        const url = new URL(event.request.url);

        // Determine which cache to use
        let cacheName = DYNAMIC_CACHE_NAME;
        if (staticAssets.some(asset => url.pathname.includes(asset))) {
          cacheName = STATIC_CACHE_NAME;
        }

        // Cache based on file type
        if (url.pathname.endsWith('.js') || 
            url.pathname.endsWith('.css') || 
            url.pathname.endsWith('.png') || 
            url.pathname.endsWith('.ico') ||
            url.pathname.endsWith('.json')) {
          
          caches.open(cacheName).then(cache => {
            cache.put(event.request, responseClone);
          });
        }

        return fetchResponse;
      });
    })
  );
});

// Optimized push notification handling
self.addEventListener('push', (event) => {
  const data = event.data ? event.data.json() : {};
  const options = {
    body: data.body || 'Nova notificação do AGENDEMAIS',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: data.id || 1,
      url: data.url || '/dashboard'
    },
    actions: [
      {
        action: 'explore',
        title: data.actionTitle || 'Ver Agendamentos',
        icon: '/icons/Icon-192.png'
      },
      {
        action: 'close',
        title: 'Fechar',
        icon: '/icons/Icon-192.png'
      }
    ],
    requireInteraction: data.requireInteraction || false,
    silent: data.silent || false
  };

  event.waitUntil(
    self.registration.showNotification(data.title || 'AGENDEMAIS', options)
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  if (event.action === 'explore') {
    const url = event.notification.data.url || '/appointments';
    event.waitUntil(
      clients.matchAll().then(clientList => {
        for (const client of clientList) {
          if (client.url === url && 'focus' in client) {
            return client.focus();
          }
        }
        if (clients.openWindow) {
          return clients.openWindow(url);
        }
      })
    );
  }
});

// Background sync for offline functionality
self.addEventListener('sync', (event) => {
  if (event.tag === 'background-sync') {
    event.waitUntil(doBackgroundSync());
  }
});

function doBackgroundSync() {
  // Implement background sync logic here
  return Promise.resolve();
}

// Periodic background sync for cache updates
self.addEventListener('periodicsync', (event) => {
  if (event.tag === 'cache-update') {
    event.waitUntil(updateCache());
  }
});

function updateCache() {
  return caches.open(DYNAMIC_CACHE_NAME).then(cache => {
    return cache.addAll(dynamicAssets);
  });
}