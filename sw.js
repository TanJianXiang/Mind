const CACHE_NAME = 'xinji-v5';
const urlsToCache = [
  './',
  './index.html',
  './manifest.json',
  './chart.umd.min.js',
  './icons/icon.svg',
  './icons/ai-avatar.png',
  './icons/user-avatar.png'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Opened cache');
        // 单个资源失败不阻塞整体安装（CDN 不可达时仍能完成安装）
        return Promise.allSettled(urlsToCache.map(u => cache.add(u)));
      })
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const request = event.request;

  // 非 GET 请求（如 AI API 的 POST）与跨域 API 请求直接放行，不经 SW 处理
  if (request.method !== 'GET') {
    return;
  }
  const url = new URL(request.url);
  if (url.origin !== self.location.origin && !url.hostname.includes('cdn') && !url.hostname.includes('jsdelivr') && !url.hostname.includes('cdnjs') && !url.hostname.includes('unpkg')) {
    return;
  }

  // HTML 页面：网络优先，确保用户始终拿到最新版本，断网时回退缓存
  if (request.mode === 'navigate' || request.url.endsWith('.html')) {
    event.respondWith(
      fetch(request).then(response => {
        const responseToCache = response.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(request, responseToCache));
        return response;
      }).catch(() => {
        return caches.match(request, { ignoreSearch: true })
          .then(cached => cached || caches.match('./index.html'));
      })
    );
    return;
  }

  // 静态资源：缓存优先，后台更新缓存
  event.respondWith(
    caches.match(request, { ignoreSearch: true })
      .then(response => {
        if (response) {
          return response;
        }

        return fetch(request).then(response => {
          if (!response || response.status !== 200 || response.type !== 'basic') {
            return response;
          }

          const responseToCache = response.clone();

          caches.open(CACHE_NAME)
            .then(cache => {
              cache.put(request, responseToCache);
            });

          return response;
        });
      })
  );
});

self.addEventListener('push', event => {
  const options = {
    body: event.data ? event.data.text() : '你有新的消息',
    icon: './icons/icon.svg',
    badge: './icons/icon.svg',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    }
  };
  
  event.waitUntil(
    self.registration.showNotification('心迹', options)
  );
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  
  event.waitUntil(
    clients.openWindow('./')
  );
});
