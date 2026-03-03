## 1.0.0

Initial stable release.

### Core
- 3-layer automatic error capture:
  - `FlutterError.onError` — widget build, layout, rendering errors.
  - `runZonedGuarded` — unhandled async/Future/Stream errors.
  - `PlatformDispatcher.instance.onError` — native platform errors.
- Drop-in `ErrorMonitor.runApp()` replaces Flutter's `runApp()`.
- Advanced `ErrorMonitor.init()` for custom setups and testing.

### Reporting
- Custom REST API reporting — POST JSON to any HTTP endpoint.
- Fingerprint-based issue grouping (SHA-256, same crash = same group).
- Fatal vs non-fatal classification per capture layer.
- Offline queue with auto-retry (SharedPreferences, max 100, FIFO eviction).
- Exponential back-off retry strategy (1s → 2s → 4s).

### Context
- Rich device info: model, brand, OS, SDK, battery, network type/speed,
  RAM, storage, CPU cores, app memory, performance tier, physical device flag.
- Breadcrumb trail — 50-event circular buffer (navigation, user action, network, state).
- Session tracking — session ID + session age on every report.
- User context — `setUser(UserInfo(id, email, name))`.
- Custom key-value pairs — `setCustomKey(key, value)`.

### Logging
- Manual logging: `ErrorMonitor.log(message, {stackTrace, level})`.
- API error logging: `ErrorMonitor.logApiError(endpoint, statusCode, message)`.
- Structured console output via `dart:developer` (always on).
- `ErrorMonitorConfig.minimumLevel` severity filter.
- `ErrorMonitorConfig.onReport` callback for custom sinks/analytics.
- `ErrorMonitorConfig.onError` legacy callback for raw error records.
