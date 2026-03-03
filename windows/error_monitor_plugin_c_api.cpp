#include "include/error_monitor/error_monitor_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "error_monitor_plugin.h"

void ErrorMonitorPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  error_monitor::ErrorMonitorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
