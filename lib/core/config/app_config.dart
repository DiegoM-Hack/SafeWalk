class AppConfig {
  /// API Key de Google Maps (Maps SDK for Android/iOS + Directions API).
  ///
  /// Obténla en: https://console.cloud.google.com/google/maps-apis
  /// Habilita estas APIs para el proyecto:
  ///   - Maps SDK for Android
  ///   - Maps SDK for iOS
  ///   - Directions API
  ///   - Geocoding API
  ///
  /// Luego reemplaza este valor y también el que está en:
  ///   - android/app/src/main/AndroidManifest.xml (meta-data com.google.android.geo.API_KEY)
  ///   - ios/Runner/AppDelegate.swift (GMSServices.provideAPIKey)
  static const String googleMapsApiKey = 'TU_API_KEY_DE_GOOGLE_MAPS';
}
