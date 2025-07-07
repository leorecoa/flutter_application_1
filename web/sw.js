const CACHE_NAME = 'agendemais-production-v1.0';
const STATIC_CACHE_NAME = 'agendemais-static-v1.0';
const DYNAMIC_CACHE_NAME = 'agendemais-dynamic-v1.0';

// Static assets that are safe to cache (public resources)
const staticAssets = [
  '/',
  '/manifest.json',
  '/favicon.ico',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  '/flutter.js',
  '/flutter_bootstrap.js'
];

// Safe dynamic assets that can be cached
const dynamicAssets = [
  '/main.dart.js',
  '/flutter_service_worker.js'
];

// Routes that should never be cached (require authentication)
const protectedRoutes = [
  '/dashboard',
  '/appointments',
  '/reports',
  '/pix',
  '/settings'
];

// API endpoints that should never be cached
const protectedApiPatterns = [
  '/api/',
  '/auth/',
  '/dashboard/',
  '/appointments/',
  '/payments/',
  'amazonaws.com'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    Promise.all([
      caches.open(STATIC_CACHE_NAME).then(cache => cache.addAll(staticAssets)),
      caches.open(DYNAMIC_CACHE_NAME).then(cache => cache.addAll(dynamicAssets))
    ])
  );
  self.skipWaiting();
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
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  const url = new URL(event.request.url);
  
  // Never cache protected API endpoints
  if (protectedApiPatterns.some(pattern => url.pathname.includes(pattern) || url.hostname.includes(pattern))) {
    event.respondWith(fetch(event.request));
    return;
  }

  // Never cache protected routes (requires auth)
  if (protectedRoutes.some(route => url.pathname.startsWith(route))) {
    event.respondWith(fetch(event.request));
    return;
  }

  // Never cache external requests (except for allowed CDNs)
  if (url.origin !== self.location.origin && !isAllowedExternalResource(url)) {
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

        // Determine which cache to use
        let cacheName = DYNAMIC_CACHE_NAME;
        if (staticAssets.some(asset => url.pathname === asset || url.pathname.includes(asset))) {
          cacheName = STATIC_CACHE_NAME;
        }

        // Only cache safe file types
        if (isSafeToCache(url.pathname)) {
          caches.open(cacheName).then(cache => {
            cache.put(event.request, responseClone);
          });
        }

        return fetchResponse;
      }).catch(() => {
        // Return offline page for navigation requests
        if (event.request.destination === 'document') {
          return caches.match('/');
        }
        throw error;
      });
    })
  );
});

function isAllowedExternalResource(url) {
  const allowedDomains = [
    'fonts.googleapis.com',
    'fonts.gstatic.com',
    'cdn.jsdelivr.net'
  ];
  
  return allowedDomains.some(domain => url.hostname.includes(domain));
}

function isSafeToCache(pathname) {
  const safeExtensions = ['.js', '.css', '.png', '.jpg', '.jpeg', '.gif', '.ico', '.svg', '.woff', '.woff2', '.ttf', '.eot'];
  const safeFiles = ['manifest.json', 'favicon.ico'];
  
  // Check file extensions
  if (safeExtensions.some(ext => pathname.endsWith(ext))) {
    return true;
  }
  
  // Check specific files
  if (safeFiles.some(file => pathname.includes(file))) {
    return true;
  }
  
  // Allow caching of assets directory
  if (pathname.startsWith('/assets/')) {
    return true;
  }
  
  // Allow caching of icons directory
  if (pathname.startsWith('/icons/')) {
    return true;
  }
  
  return false;
}

// Push notification handling (production-ready)
self.addEventListener('push', (event) => {
  if (!event.data) return;
  
  try {
    const data = event.data.json();
    const options = {
      body: data.body || 'Nova notificação do AGENDEMAIS',
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
      vibrate: [100, 50, 100],
      data: {
        dateOfArrival: Date.now(),
        primaryKey: data.id || Date.now(),
        url: data.url || '/dashboard'
      },
      actions: [
        {
          action: 'view',
          title: data.actionTitle || 'Ver',
          icon: '/icons/Icon-192.png'
        },
        {
          action: 'dismiss',
          title: 'Dispensar',
          icon: '/icons/Icon-192.png'
        }
      ],
      requireInteraction: data.requireInteraction || false,
      silent: data.silent || false,
      tag: data.tag || 'agendemais-notification'
    };

    event.waitUntil(
      self.registration.showNotification(data.title || 'AGENDEMAIS', options)
    );
  } catch (error) {
    console.error('Error processing push notification:', error);
  }
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  if (event.action === 'view' || !event.action) {
    const url = event.notification.data.url || '/dashboard';
    event.waitUntil(
      clients.matchAll({ type: 'window', includeUncontrolled: true }).then(clientList => {
        // Check if there's already a window/tab open with the target URL
        for (const client of clientList) {
          if (client.url === url && 'focus' in client) {
            return client.focus();
          }
        }
        // If not, open a new window/tab
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
  // Implement offline data sync when connection is restored
  return Promise.resolve();
}