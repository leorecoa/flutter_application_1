// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/**
 * This script installs service_worker.js to provide PWA functionality to
 *     application. For more information, see:
 *     https://developers.google.com/web/fundamentals/primers/service-workers
 */

if (!_flutter) {
  var _flutter = {};
}
_flutter.loader = null;

(function() {
  "use strict";
  class FlutterLoader {
    /**
     * Creates a FlutterLoader, which manages loading the Flutter engine and app.
     */
    constructor() {
      this._scriptLoaded = false;
      this._engineInitializer = null;
    }

    /**
     * Initializes the Flutter engine.
     *
     * @param {*} options
     * @returns {Promise<EngineInitializer>}
     */
    loadEntrypoint(options) {
      const {
        entrypointUrl = "main.dart.js",
        serviceWorker,
        onEntrypointLoaded,
      } = options || {};

      return this._loadWithServiceWorker(serviceWorker)
        .then(() => {
          return this._loadEntrypoint(entrypointUrl);
        })
        .then((engineInitializer) => {
          if (typeof onEntrypointLoaded === "function") {
            onEntrypointLoaded(engineInitializer);
          }
          return engineInitializer;
        });
    }

    /**
     * Downloads the script at `url`.
     *
     * @param {string} url
     * @returns {Promise<void>}
     */
    _downloadScript(url) {
      if (this._scriptLoaded) {
        return Promise.resolve();
      }
      this._scriptLoaded = true;
      const script = document.createElement("script");
      script.src = url;
      document.body.append(script);
      return new Promise((resolve, reject) => {
        script.addEventListener("load", resolve);
        script.addEventListener("error", reject);
      });
    }

    /**
     * Loads the Flutter app bundle at `entrypointUrl`.
     *
     * @param {string} entrypointUrl
     * @returns {Promise<EngineInitializer>}
     */
    _loadEntrypoint(entrypointUrl) {
      return new Promise((resolve, reject) => {
        this._downloadScript(entrypointUrl).then(() => {
          if (window.flutter_inappwebview) {
            console.warn(
              "Flutter Web Bootstrap: Auto-registering plugins with flutter_inappwebview is deprecated. " +
                "See: https://github.com/flutter/flutter/issues/123405"
            );
          }
          this._engineInitializer = window._flutter_entrypoint_js();
          resolve(this._engineInitializer);
        }, reject);
      });
    }

    /**
     * Loads a service worker if necessary.
     *
     * @param {*} serviceWorker
     * @returns {Promise<void>}
     */
    _loadWithServiceWorker(serviceWorker) {
      if (!serviceWorker) {
        return Promise.resolve();
      }
      const { serviceWorkerVersion, timeoutMillis = 4000 } = serviceWorker;

      // If service worker is not supported, don't wait for it!
      if (!("serviceWorker" in navigator)) {
        return Promise.resolve();
      }

      const serviceWorkerUrl =
        "flutter_service_worker.js?v=" + serviceWorkerVersion;
      return navigator.serviceWorker.register(serviceWorkerUrl).then(
        (registration) => {
          if (!serviceWorkerVersion) {
            return Promise.resolve();
          }
          let serviceWorkerActivation = null;
          const timeoutId = setTimeout(() => {
            if (serviceWorkerActivation) {
              serviceWorkerActivation.resolve(true);
            }
          }, timeoutMillis);

          serviceWorkerActivation = new Promise((resolve, reject) => {
            if (registration.active) {
              // If there's an active service worker, check its version.
              if (registration.active.scriptURL.endsWith(serviceWorkerVersion)) {
                // Same version, resolve immediately.
                clearTimeout(timeoutId);
                resolve(true);
              } else {
                // Different version, wait for update.
                let listener = () => {
                  navigator.serviceWorker.removeEventListener(
                    "controllerchange",
                    listener
                  );
                  if (registration.active) {
                    if (
                      registration.active.scriptURL.endsWith(
                        serviceWorkerVersion
                      )
                    ) {
                      // Same version, resolve immediately.
                      clearTimeout(timeoutId);
                      resolve(true);
                    } else {
                      // Still a different version, continue waiting.
                      console.debug("SW: version mismatch, continuing to wait");
                    }
                  }
                };
                navigator.serviceWorker.addEventListener(
                  "controllerchange",
                  listener
                );
              }
            } else {
              // No active service worker, wait for activation.
              let listener = () => {
                navigator.serviceWorker.removeEventListener(
                  "controllerchange",
                  listener
                );
                clearTimeout(timeoutId);
                resolve(true);
              };
              navigator.serviceWorker.addEventListener(
                "controllerchange",
                listener
              );
            }
          });

          return serviceWorkerActivation;
        },
        (error) => {
          console.warn("Failed to register service worker:", error);
          // Service worker registration failed, continue without it.
          return Promise.resolve();
        }
      );
    }
  }

  _flutter.loader = new FlutterLoader();
})();