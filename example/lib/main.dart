import 'package:flutter/material.dart';
import 'package:error_monitor/error_monitor.dart';

void main() => ErrorMonitor.runApp(
      config: ErrorMonitorConfig(
        appName: 'ErrorMonitorExample',
        appVersion: '1.0.0',
        buildNumber: '1',
        minimumLevel: ErrorLevel.info,
        // Uncomment to send reports to your REST API:
        // apiConfig: ErrorMonitorApiConfig(
        //   endpoint: 'https://api.yourserver.com/v1/crashes',
        //   apiKey: 'your-secret-key',
        // ),
        onReport: (report) {
          debugPrint('📋 Report: ${report.message}');
          debugPrint('   Fatal: ${report.isFatal}');
          debugPrint('   Fingerprint: ${report.fingerprint}');
          debugPrint('   Session age: ${report.sessionAge.inSeconds}s');
        },
      ),
      app: const ExampleApp(),
    );

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error Monitor Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Monitor Example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'User Context',
            children: [
              _ActionButton(
                label: 'Set User',
                onPressed: () {
                  ErrorMonitor.setUser(UserInfo(
                    id: 'user-42',
                    email: 'jane@example.com',
                    name: 'Jane Doe',
                  ));
                  _showSnack(context, 'User set: jane@example.com');
                },
              ),
              _ActionButton(
                label: 'Clear User',
                onPressed: () {
                  ErrorMonitor.setUser(null);
                  _showSnack(context, 'User cleared');
                },
              ),
            ],
          ),
          _Section(
            title: 'Custom Keys',
            children: [
              _ActionButton(
                label: 'Set Custom Key',
                onPressed: () {
                  ErrorMonitor.setCustomKey('plan', 'premium');
                  ErrorMonitor.setCustomKey('cart_items', 3);
                  _showSnack(context, 'Custom keys set');
                },
              ),
            ],
          ),
          _Section(
            title: 'Breadcrumbs',
            children: [
              _ActionButton(
                label: 'Navigation Breadcrumb',
                onPressed: () {
                  ErrorMonitor.navigation('/settings');
                  _showSnack(context, 'Navigation breadcrumb recorded');
                },
              ),
              _ActionButton(
                label: 'Action Breadcrumb',
                onPressed: () {
                  ErrorMonitor.action('tapped_example_button');
                  _showSnack(context, 'Action breadcrumb recorded');
                },
              ),
              _ActionButton(
                label: 'Network Breadcrumb',
                onPressed: () {
                  ErrorMonitor.networkCall('GET', '/api/users',
                      statusCode: 200);
                  _showSnack(context, 'Network breadcrumb recorded');
                },
              ),
            ],
          ),
          _Section(
            title: 'Manual Logging',
            children: [
              _ActionButton(
                label: 'Log Info',
                onPressed: () {
                  ErrorMonitor.log('User opened settings',
                      level: ErrorLevel.info);
                },
              ),
              _ActionButton(
                label: 'Log Warning',
                onPressed: () {
                  ErrorMonitor.log('Slow network detected',
                      level: ErrorLevel.warning);
                },
              ),
              _ActionButton(
                label: 'Log API Error',
                onPressed: () {
                  ErrorMonitor.logApiError(
                    '/api/orders',
                    statusCode: 503,
                    message: 'Service unavailable',
                  );
                },
              ),
            ],
          ),
          _Section(
            title: 'Trigger Errors',
            children: [
              _ActionButton(
                label: 'Throw Flutter Error',
                color: Colors.red,
                onPressed: () {
                  // This will be caught by Layer 1 (FlutterError.onError)
                  throw Exception('Example Flutter error');
                },
              ),
              _ActionButton(
                label: 'Throw Async Error',
                color: Colors.red,
                onPressed: () async {
                  // This will be caught by Layer 2 (runZonedGuarded)
                  await Future.delayed(const Duration(milliseconds: 100));
                  throw StateError('Example async error');
                },
              ),
              _ActionButton(
                label: 'Trigger Null Error',
                color: Colors.red,
                onPressed: () {
                  String? value;
                  // ignore: unnecessary_non_null_assertion
                  debugPrint(value!); // Null check error
                },
              ),
            ],
          ),
          _Section(
            title: 'Offline Queue',
            children: [
              _ActionButton(
                label: 'Flush Offline Queue',
                onPressed: () async {
                  await ErrorMonitor.flushOfflineQueue();
                  _showSnack(context, 'Offline queue flushed');
                },
              ),
              _ActionButton(
                label: 'Check Pending Count',
                onPressed: () async {
                  final count = await ErrorMonitor.pendingQueueCount;
                  if (context.mounted) {
                    _showSnack(context, '$count reports pending');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: children),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.color,
  });
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: color != null
          ? FilledButton.styleFrom(backgroundColor: color)
          : null,
      child: Text(label),
    );
  }
}
