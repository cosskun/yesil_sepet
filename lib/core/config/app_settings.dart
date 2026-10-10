/// Global settings and environment configuration for the application.
class AppSettings {
  /// Toggle between offline local mode and remote server synchronization.
  static bool isServerSync = false;

  /// Base URL of the backend API server.
  static String serverUrl = 'http://localhost:9090';
}
