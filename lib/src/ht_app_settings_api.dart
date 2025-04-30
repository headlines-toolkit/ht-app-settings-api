import 'package:ht_app_settings_client/ht_app_settings_client.dart';
import 'package:ht_http_client/ht_http_client.dart';

/// {@template ht_app_settings_api}
/// An API client implementation for managing user application settings
/// via an HTTP backend.
///
/// This client interacts with endpoints assumed to be nested under the user
/// resource (e.g., `/api/v1/users/me/settings/...`).
/// {@endtemplate}
class HtAppSettingsApi implements HtAppSettingsClient {
  /// {@macro ht_app_settings_api}
  ///
  /// Requires an [HtHttpClient] instance for making network requests.
  const HtAppSettingsApi({
    required HtHttpClient httpClient,
  }) : _httpClient = httpClient;

  final HtHttpClient _httpClient;

  // Define base paths for the nested settings endpoints.
  static const String _baseDisplayPath = '/api/v1/users/me/settings/display';
  static const String _baseLanguagePath = '/api/v1/users/me/settings/language';
  static const String _baseSettingsPath = '/api/v1/users/me/settings';

  @override
  Future<DisplaySettings> getDisplaySettings() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        _baseDisplayPath,
      );
      // Assuming the API returns the DisplaySettings JSON directly.
      return DisplaySettings.fromJson(response);
    } on HtHttpException {
      rethrow; // Propagate HTTP-related errors.
    } catch (e, stackTrace) {
      // Catch potential FormatExceptions during deserialization or others.
      Error.throwWithStackTrace(
        UnknownException('Failed to get display settings: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> setDisplaySettings(DisplaySettings settings) async {
    try {
      await _httpClient.put<void>(
        _baseDisplayPath,
        data: settings.toJson(), // Send the settings object as JSON body.
      );
    } on HtHttpException {
      rethrow;
    } catch (e, stackTrace) {
      Error.throwWithStackTrace(
        UnknownException('Failed to set display settings: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<AppLanguage> getLanguage() async {
    try {
      // Assuming the API returns a simple JSON like {"language": "en"}
      final response = await _httpClient.get<Map<String, dynamic>>(
        _baseLanguagePath,
      );
      final language = response['language'] as String?;
      if (language == null) {
        throw const FormatException(
          'Language field missing or not a string in response.',
        );
      }
      return language;
    } on HtHttpException {
      rethrow;
    } on FormatException {
      rethrow; // Let FormatException propagate for deserialization issues.
    } catch (e, stackTrace) {
      Error.throwWithStackTrace(
        UnknownException('Failed to get language: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> setLanguage(AppLanguage language) async {
    try {
      // Send the language in a simple JSON structure.
      await _httpClient.put<void>(
        _baseLanguagePath,
        data: {'language': language},
      );
    } on HtHttpException {
      rethrow;
    } catch (e, stackTrace) {
      Error.throwWithStackTrace(
        UnknownException('Failed to set language: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> clearSettings() async {
    try {
      // Assuming DELETE on the base settings path clears all user settings.
      await _httpClient.delete<void>(_baseSettingsPath);
    } on HtHttpException {
      rethrow;
    } catch (e, stackTrace) {
      Error.throwWithStackTrace(
        UnknownException('Failed to clear settings: $e'),
        stackTrace,
      );
    }
  }
}
