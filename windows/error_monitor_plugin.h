#ifndef FLUTTER_PLUGIN_ERROR_MONITOR_PLUGIN_H_
#define FLUTTER_PLUGIN_ERROR_MONITOR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace error_monitor {

class ErrorMonitorPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ErrorMonitorPlugin();

  virtual ~ErrorMonitorPlugin();

  // Disallow copy and assign.
  ErrorMonitorPlugin(const ErrorMonitorPlugin&) = delete;
  ErrorMonitorPlugin& operator=(const ErrorMonitorPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace error_monitor

#endif  // FLUTTER_PLUGIN_ERROR_MONITOR_PLUGIN_H_
