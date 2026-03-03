/// error_monitor — Custom REST API crash tracking for Flutter.
///
/// Zero Firebase dependency. Ships your crash reports to any HTTP server.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:error_monitor/error_monitor.dart';
///
/// void main() => ErrorMonitor.runApp(
///   config: ErrorMonitorConfig(
///     appName: 'MyApp',
///     appVersion: '1.0.0',
///     buildNumber: '1',
///   ),
///   app: const MyApp(),
/// );
/// ```
///
/// ## Features
///   • Automatic capture (Flutter + async + platform) — 3 layers
///   • Custom REST API reporting (POST JSON)
///   • Issue grouping by fingerprint
///   • Fatal vs non-fatal classification
///   • Breadcrumb trail (50 events before crash)
///   • User session tracking (ID + age)
///   • User context (id, email, name)
///   • Custom key-value pairs
///   • Offline queue with auto-retry (SharedPreferences)
///   • Structured console logging (always on)
library;

export 'src/models/breadcrumb.dart';
export 'src/models/crash_report.dart';
export 'src/models/device_info.dart';
export 'src/models/error_level.dart';
export 'src/models/error_record.dart';
export 'src/models/error_type.dart';
export 'src/models/user_info.dart';
export 'src/tracker/error_monitor.dart';
export 'src/tracker/error_monitor_config.dart';

