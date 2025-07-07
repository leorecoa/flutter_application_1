const CACHE_NAME = 'agendemais-v1';
const urlsToCache = [
  '/',
  '/main.dart.js',
  '/flutter_service_worker.js',
  '/manifest.json',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
});

self.addEventListener('push', (event) => {
  const options = {
    body: event.data ? event.data.text() : 'Nova notificação do AGENDEMAIS',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'explore',
        title: 'Ver Agendamentos',
        icon: '/icons/Icon-192.png'
      },
      {
        action: 'close',
        title: 'Fechar',
        icon: '/icons/Icon-192.png'
      }
    ]
  };

  event.waitUntil(
    self.registration.showNotification('AGENDEMAIS', options)
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/appointments')
    );
  }
});