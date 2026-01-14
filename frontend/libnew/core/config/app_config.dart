class AppConfig {
  // Default fallback values
  static const String _defaultBaseUrl = 'http://192.168.137.1:8000/api';
  
  // This would typically be loaded from environment variables or build-time configuration
  // Since Flutter doesn't have native .env support, we'll use a fallback approach
  static String get baseUrl {
    // In a real implementation, this would check for environment variables
    // For now, we'll use the default value
    return _defaultBaseUrl;
  }

  // Google OAuth client IDs
  static String get googleClientId {
    // This would be loaded from environment
    return '110742925112-6lgb0mcgcrt7q57h5993q4a5g41mue3s.apps.googleusercontent.com';
  }

  static String get googleServerClientId {
    // This would be loaded from environment
    return '110742925112-jrpr6oene8oh0uq7t0uf384afvarruvs.apps.googleusercontent.com';
  }

  static String get environment {
    // This would be loaded from environment
    return 'development';
  }
}