import 'package:ht_app_settings_client/ht_app_settings_client.dart';
import 'package:ht_http_client/ht_http_client.dart';
import 'package:ht_shared/ht_shared.dart';

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
      final responseMap = await _httpClient.get<Map<String, dynamic>>(
        _baseDisplayPath,
      );
      // Deserialize the wrapper and the nested data.
      final successResponse = SuccessApiResponse.fromJson(
        responseMap,
        (dataJson) =>
            DisplaySettings.fromJson(dataJson! as Map<String, dynamic>),
      );
      return successResponse.data;
    } on HtHttpException {
      rethrow; // Propagate HTTP-related errors.
    } on FormatException catch (e, stackTrace) {
      // Catch FormatExceptions during deserialization of wrapper or data.
      Error.throwWithStackTrace(
        UnknownException('Failed to parse display settings response: $e'),
        stackTrace,
      );
    } catch (e, stackTrace) {
      // Catch other potential errors.
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
      final responseMap = await _httpClient.get<Map<String, dynamic>>(
        _baseLanguagePath,
      );
      // Deserialize the wrapper, expecting the inner data to be a Map.
      final successResponse = SuccessApiResponse.fromJson(
        responseMap,
        (dataJson) => dataJson! as Map<String, dynamic>,
      );
      // Extract the language from the inner data map.
      final languageData = successResponse.data;
      final language = languageData['language'] as String?;
      if (language == null) {
        throw const FormatException(
          "Response data missing 'language' field or it's not a string.",
        );
      }
      return language;
    } on HtHttpException {
      rethrow;
    } on FormatException catch (e, stackTrace) {
      // Catch FormatExceptions during deserialization or if structure is wrong.
      Error.throwWithStackTrace(
        UnknownException('Failed to parse language response: $e'),
        stackTrace,
      );
    } catch (e, stackTrace) {
      // Catch other potential errors.
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
