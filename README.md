# error_monitor

[![Pub Version](https://img.shields.io/pub/v/error_monitor)](https://pub.dev/packages/error_monitor)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Production-ready crash tracking for Flutter — zero Firebase dependency.**

Ship your crash reports to **any HTTP server** via a custom REST API. Drop-in replacement for Firebase Crashlytics with full offline support, breadcrumb trails, session tracking, and rich device context.

---

## ✨ Features

| Feature | Description |
|---|---|
| **3-Layer Auto Capture** | Flutter errors, async errors, and platform errors — all caught automatically |
| **Custom REST API** | POST JSON crash reports to your own backend — no Firebase needed |
| **Issue Grouping** | SHA-256 fingerprint-based grouping (same crash = same group) |
| **Fatal / Non-Fatal** | Automatically classified per capture layer |
| **Breadcrumbs** | 50-event circular trail recorded before every crash |
| **Session Tracking** | Session ID + session age attached to every report |
| **User Context** | Attach user ID, email, and name to reports |
| **Custom Keys** | Arbitrary key-value pairs on every report |
| **Offline Queue** | Persisted to SharedPreferences, auto-flushed on reconnect (max 100) |
| **Device Info** | Model, brand, OS, SDK, battery, network, RAM, storage, CPU cores, performance tier |
| **Console Logging** | Structured logs always printed — even without an API endpoint |
| **Minimum Severity Filter** | Drop errors below a threshold (info / warning / error / critical) |

---

## 📦 Installation

Add `error_monitor` to your `pubspec.yaml`:

```yaml
dependencies:
  error_monitor:
    path: ../error_monitor  # or from pub.dev / git
```

Then run:

```bash
flutter pub get
```

### Dependencies (auto-installed)

- `device_info_plus` — device model, brand, OS
- `connectivity_plus` — online/offline detection
- `battery_plus` — battery percentage
- `shared_preferences` — offline queue persistence
- `uuid` — unique report IDs

---

## 🚀 Quick Start (Console-Only)

Replace your `main()` with a single call — **no API key needed** for local logging:

```dart
import 'package:flutter/material.dart';
import 'package:error_monitor/error_monitor.dart';

void main() => ErrorMonitor.runApp(
  config: ErrorMonitorConfig(
    appName: 'MyApp',
    appVersion: '1.0.0',
    buildNumber: '1',
  ),
  app: const MyApp(),
);
```

That's it. All Flutter, async, and platform errors are now captured and printed to the console in a structured format.

---

## 🌐 Full Setup (With Remote Reporting)

Send crash reports to your own REST API:

```dart
import 'package:flutter/material.dart';
import 'package:error_monitor/error_monitor.dart';

void main() => ErrorMonitor.runApp(
  config: ErrorMonitorConfig(
    appName: 'MyApp',
    appVersion: '1.0.0',
    buildNumber: '42',
    minimumLevel: ErrorLevel.warning, // drop info-level noise
    apiConfig: ErrorMonitorApiConfig(
      endpoint: 'https://api.yourserver.com/v1/crash-reports',
      apiKey: 'your-secret-key',
      timeoutSeconds: 10,
      maxRetries: 3,
      headers: {
        'X-Custom-Header': 'value',
      },
    ),
  ),
  app: const MyApp(),
);
```

---

## 🔧 Localhost / Development Setup

Testing against a local server? Follow these steps:

### 1. Use the correct host address

| Platform | Use instead of `localhost` |
|---|---|
| **Android Emulator** | `10.0.2.2` |
| **iOS Simulator** | `localhost` (works directly) |
| **Physical Device** | Your machine's LAN IP (e.g., `192.168.1.x`) |

### 2. Enable cleartext HTTP traffic (Android)

Android blocks HTTP (non-HTTPS) by default. Add this to your **app's** `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### 3. Configure the API endpoint

```dart
void main() => ErrorMonitor.runApp(
  config: ErrorMonitorConfig(
    appName: 'MyApp',
    appVersion: '1.0.0',
    buildNumber: '1',
    apiConfig: ErrorMonitorApiConfig(
      // Android emulator → use 10.0.2.2
      endpoint: 'http://10.0.2.2:3000/api/crashes',
      // For HTTPS with self-signed certs:
      allowBadCertificates: true, // ⚠️ dev only!
    ),
  ),
  app: const MyApp(),
);
```

### 4. iOS — allow local networking (if needed)

Add to your `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

> **⚠️ Warning:** Never use `allowBadCertificates: true` or `usesCleartextTraffic="true"` in production builds!

---

## 🏗️ How It Works

### 3 Automatic Capture Layers

```
┌─────────────────────────────────────────────────────┐
│  Layer 1 — FlutterError.onError                     │
│  Widget build, layout, rendering, disposed errors   │
├─────────────────────────────────────────────────────┤
│  Layer 2 — runZonedGuarded                          │
│  All unhandled Future, async/await, Stream errors   │
├─────────────────────────────────────────────────────┤
│  Layer 3 — PlatformDispatcher.instance.onError      │
│  Native/platform errors that escape layers 1 & 2   │
└─────────────────────────────────────────────────────┘
```

### Crash Report Pipeline

```
Error occurs
  → Collect device info (async, non-blocking)
  → Log to console (always, instant)
  → Build CrashReport with breadcrumbs, session, fingerprint, user context
  → POST to REST API (or queue offline)
  → Fire developer callback hooks
```

---

## 📖 API Reference

### User Context

Attach user information after login. Pass `null` to clear on logout.

```dart
// Set user after login
ErrorMonitor.setUser(UserInfo(
  id: '42',
  email: 'user@example.com',
  name: 'Jane Doe',
  extra: {'plan': 'premium'},
));

// Clear on logout
ErrorMonitor.setUser(null);
```

### Custom Keys

Attach arbitrary key-value pairs to every subsequent crash report:

```dart
ErrorMonitor.setCustomKey('plan', 'premium');
ErrorMonitor.setCustomKey('cart_items', 3);
ErrorMonitor.setCustomKey('feature_flag_new_ui', true);

// Remove a key
ErrorMonitor.removeCustomKey('cart_items');
```

### Breadcrumbs

Record a trail of events leading up to a crash (last 50 are kept):

```dart
// Screen navigation
ErrorMonitor.navigation('/checkout', params: {'from': '/cart'});

// User action
ErrorMonitor.action('tapped_pay_button', data: {'amount': 29.99});

// Network request
ErrorMonitor.networkCall('POST', '/api/v1/orders', statusCode: 201);

// App state change
ErrorMonitor.stateChange('cart_cleared', data: {'item_count': 5});

// Raw breadcrumb
ErrorMonitor.addBreadcrumb(Breadcrumb(
  message: 'Custom event',
  type: BreadcrumbType.log,
  timestamp: DateTime.now(),
  data: {'key': 'value'},
));
```

### Manual Logging

Log errors or messages manually with a severity level:

```dart
// General log
ErrorMonitor.log('Payment timeout', level: ErrorLevel.warning);

// With stack trace
try {
  riskyOperation();
} catch (e, stack) {
  ErrorMonitor.log(e.toString(), stackTrace: stack, level: ErrorLevel.error);
}
```

### API Error Logging

Log HTTP API errors with endpoint and status context:

```dart
ErrorMonitor.logApiError(
  '/api/orders',
  statusCode: 503,
  message: 'Service unavailable',
);

// Status code auto-classifies severity:
//   5xx → critical
//   4xx → error
//   other → warning
```

### Offline Queue

Reports are automatically queued when offline and flushed when connectivity returns.

```dart
// Manual flush (e.g., on connectivity restored)
await ErrorMonitor.flushOfflineQueue();

// Check pending count
final count = await ErrorMonitor.pendingQueueCount;
print('$count reports waiting');
```

### Developer Callbacks

Hook into the report pipeline for custom analytics or UI alerts:

```dart
ErrorMonitorConfig(
  appName: 'MyApp',
  appVersion: '1.0.0',
  buildNumber: '1',

  // Called after every crash report is built (before sending)
  onReport: (CrashReport report) {
    print('Crash: ${report.message}');
    print('Fatal: ${report.isFatal}');
    print('Fingerprint: ${report.fingerprint}');
    print('Session age: ${report.sessionAge.inSeconds}s');
    // Send to custom analytics, show in-app alert, etc.
  },

  // Legacy callback — receives the raw ErrorRecord
  onError: (ErrorRecord record) {
    // ...
  },
);
```

---

## ⚙️ Configuration Reference

### `ErrorMonitorConfig`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `appName` | `String` | **required** | Your application name |
| `appVersion` | `String` | **required** | App version (e.g., `'1.0.0'`) |
| `buildNumber` | `String` | **required** | Build number (e.g., `'42'`) |
| `minimumLevel` | `ErrorLevel` | `ErrorLevel.info` | Errors below this severity are dropped |
| `apiConfig` | `ErrorMonitorApiConfig?` | `null` | Set to enable remote reporting |
| `enableFlutterErrors` | `bool` | `true` | Capture Flutter framework errors |
| `enableAsyncErrors` | `bool` | `true` | Capture async/Future errors |
| `enablePlatformErrors` | `bool` | `true` | Capture platform dispatcher errors |
| `onReport` | `Function(CrashReport)?` | `null` | Callback after each report is built |
| `onError` | `Function(ErrorRecord)?` | `null` | Legacy callback for raw error records |

### `ErrorMonitorApiConfig`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `endpoint` | `String` | **required** | Full URL that accepts POST JSON requests |
| `apiKey` | `String?` | `null` | Sent as `X-Api-Key` header |
| `headers` | `Map<String, String>?` | `null` | Additional HTTP headers |
| `timeoutSeconds` | `int` | `10` | Request timeout in seconds |
| `maxRetries` | `int` | `3` | Retry attempts before queuing offline |
| `allowBadCertificates` | `bool` | `false` | Accept self-signed TLS certs (dev only!) |

### `ErrorLevel`

| Value | Description |
|---|---|
| `info` | Informational messages |
| `warning` | Non-critical warnings |
| `error` | Errors that need attention |
| `critical` | Fatal / high-severity crashes |

---

## 🌐 Server-Side Integration

### Expected Request Format

```http
POST /v1/crash-reports HTTP/1.1
Content-Type: application/json
Accept: application/json
X-Api-Key: your-secret-key
X-Error-Monitor-Version: 2.0.0

{
  "id": "a1b2c3d4-...",
  "message": "RangeError (index): Invalid value: Not in range...",
  "type": "FlutterError",
  "level": "ERROR",
  "isFatal": false,
  "sessionId": "f8e7d6c5-...",
  "sessionAgeSec": 142,
  "appLaunchTime": "2026-03-03T10:00:00.000Z",
  "fingerprint": "sha256-abc123...",
  "stackTrace": "...",
  "breadcrumbs": [
    {
      "message": "/home",
      "type": "navigation",
      "timestamp": "2026-03-03T10:01:00.000Z"
    },
    {
      "message": "tapped_buy_button",
      "type": "userAction",
      "timestamp": "2026-03-03T10:02:00.000Z",
      "data": {"item_id": "SKU-123"}
    }
  ],
  "device": {
    "appName": "MyApp",
    "appVersion": "1.0.0",
    "buildNumber": "42",
    "deviceModel": "Pixel 7",
    "deviceBrand": "Google",
    "osVersion": "14",
    "sdkVersion": "34",
    "batteryPercentage": 72,
    "networkType": "wifi",
    "networkSpeedMbps": 54.0,
    "totalRamMB": 8192,
    "freeRamMB": 3200,
    "totalStorageGB": 128.0,
    "freeStorageGB": 45.5,
    "cpuCores": 8,
    "appMemoryUsageMB": 120.5,
    "devicePerformanceLevel": "high",
    "isPhysicalDevice": true,
    "timestamp": "2026-03-03T10:02:22.000Z"
  },
  "user": {
    "id": "42",
    "email": "user@example.com",
    "name": "Jane Doe"
  },
  "customKeys": {
    "plan": "premium",
    "cart_items": 3
  },
  "createdAt": "2026-03-03T10:02:22.000Z"
}
```

### Expected Server Response

| Status | Behavior |
|---|---|
| `2xx` | Report accepted — removed from queue |
| `4xx` | Bad request — discarded (no retry) |
| `5xx` | Server error — kept in offline queue for retry |
| Timeout / Network error | Kept in offline queue |

### Retry Strategy

- **Exponential back-off**: 1s → 2s → 4s (up to `maxRetries`)
- **Queue limit**: 100 reports (FIFO eviction when full)
- **Auto-flush**: Attempts to drain queue after every successful send

---

## 🧪 Advanced Init (Testing / Custom Setup)

For testing or when you need more control over initialization:

```dart
await ErrorMonitor.init(
  ErrorMonitorConfig(
    appName: 'MyApp',
    appVersion: '1.0.0',
    buildNumber: '1',
  ),
);

// Then handle zone errors manually:
runZonedGuarded(
  () => runApp(const MyApp()),
  ErrorMonitor.handleZoneError,
);
```

---

## 📂 Project Structure

```
lib/
  error_monitor.dart              ← barrel file (public exports)
  src/
    tracker/
      error_monitor.dart          ← main ErrorMonitor class
      error_monitor_config.dart   ← ErrorMonitorConfig + ErrorMonitorApiConfig
    models/
      breadcrumb.dart             ← Breadcrumb + BreadcrumbType
      crash_report.dart           ← CrashReport (full payload)
      device_info.dart            ← DeviceInfo snapshot
      error_level.dart            ← ErrorLevel enum
      error_record.dart           ← ErrorRecord (console log)
      error_type.dart             ← ErrorType enum
      user_info.dart              ← UserInfo model
    breadcrumbs/
      breadcrumb_manager.dart     ← circular buffer (last 50)
    logger/
      console_logger.dart         ← structured dart:developer output
    reporter/
      fingerprint_generator.dart  ← SHA-256 issue grouping
      remote_reporter.dart        ← HTTP transport + retry logic
    queue/
      offline_queue.dart          ← SharedPreferences persistence
    services/
      device_info_service.dart    ← device data collection
    session/
      session_manager.dart        ← session ID + launch time
```

---

## 🔄 Full Integration Example

```dart
import 'package:flutter/material.dart';
import 'package:error_monitor/error_monitor.dart';

void main() => ErrorMonitor.runApp(
  config: ErrorMonitorConfig(
    appName: 'ShopApp',
    appVersion: '2.1.0',
    buildNumber: '87',
    minimumLevel: ErrorLevel.warning,
    apiConfig: ErrorMonitorApiConfig(
      endpoint: 'https://api.myserver.com/v1/crashes',
      apiKey: 'sk-live-abc123',
    ),
    onReport: (report) {
      debugPrint('📋 Report sent: ${report.fingerprint}');
    },
  ),
  app: const ShopApp(),
);

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [ErrorMonitorNavigatorObserver()],
      home: const HomeScreen(),
    );
  }
}

/// Example: custom NavigatorObserver that records breadcrumbs
class ErrorMonitorNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    final name = route.settings.name ?? route.runtimeType.toString();
    ErrorMonitor.navigation(name);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final name = previousRoute?.settings.name ?? 'back';
    ErrorMonitor.navigation(name, params: {'action': 'pop'});
  }
}

/// Example: using error monitor in a screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _onCheckout(context),
          child: const Text('Checkout'),
        ),
      ),
    );
  }

  Future<void> _onCheckout(BuildContext context) async {
    // Record user action
    ErrorMonitor.action('tapped_checkout');

    // Set user context
    ErrorMonitor.setUser(UserInfo(id: 'user-42', email: 'jane@shop.com'));

    // Set custom keys
    ErrorMonitor.setCustomKey('cart_total', 59.99);
    ErrorMonitor.setCustomKey('item_count', 3);

    try {
      // Simulate API call
      await _placeOrder();
      ErrorMonitor.networkCall('POST', '/api/orders', statusCode: 201);
    } catch (e, stack) {
      // Log API error
      ErrorMonitor.logApiError(
        '/api/orders',
        statusCode: 500,
        message: e.toString(),
        stackTrace: stack,
      );
    }
  }

  Future<void> _placeOrder() async {
    // Your order logic here
  }
}
```

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.
