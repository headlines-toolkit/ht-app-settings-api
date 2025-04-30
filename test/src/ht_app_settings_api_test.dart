// ignore_for_file: prefer_const_constructors, cast_nullable_to_non_nullable
import 'package:ht_app_settings_api/ht_app_settings_api.dart';
import 'package:ht_app_settings_client/ht_app_settings_client.dart';
import 'package:ht_http_client/ht_http_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mocks
class MockHtHttpClient extends Mock implements HtHttpClient {}

// No need to mock RequestOptions if exceptions don't require it directly.
// class MockRequestOptions extends Mock implements RequestOptions {}

// Helper to create a valid DisplaySettings JSON map
Map<String, dynamic> createDisplaySettingsJson({
  AppBaseTheme baseTheme = AppBaseTheme.system,
  AppAccentTheme accentTheme = AppAccentTheme.defaultBlue,
  String fontFamily = 'SystemDefault',
  AppTextScaleFactor textScaleFactor = AppTextScaleFactor.medium,
  AppFontWeight fontWeight = AppFontWeight.regular,
}) {
  return DisplaySettings(
    baseTheme: baseTheme,
    accentTheme: accentTheme,
    fontFamily: fontFamily,
    textScaleFactor: textScaleFactor,
    fontWeight: fontWeight,
  ).toJson();
}

// Helper to create a valid DisplaySettings object
DisplaySettings createDisplaySettingsObject({
  AppBaseTheme baseTheme = AppBaseTheme.system,
  AppAccentTheme accentTheme = AppAccentTheme.defaultBlue,
  String fontFamily = 'SystemDefault',
  AppTextScaleFactor textScaleFactor = AppTextScaleFactor.medium,
  AppFontWeight fontWeight = AppFontWeight.regular,
}) {
  return DisplaySettings(
    baseTheme: baseTheme,
    accentTheme: accentTheme,
    fontFamily: fontFamily,
    textScaleFactor: textScaleFactor,
    fontWeight: fontWeight,
  );
}

// Helper to create a SuccessApiResponse JSON structure
Map<String, dynamic> createSuccessResponseJson<T>(
  T data, {
  String? requestId,
  DateTime? timestamp,
}) {
  // Simulate the structure the API would return
  return {
    'data':
        data, // Assumes data is already JSON-serializable (Map or primitive)
    'metadata': {
      if (requestId != null) 'request_id': requestId,
      if (timestamp != null) 'timestamp': timestamp.toIso8601String(),
    },
  };
}

void main() {
  group('HtAppSettingsApi', () {
    late HtHttpClient mockHttpClient;
    late HtAppSettingsApi apiClient;
    // late RequestOptions mockRequestOptions; // Not needed now

    // Base paths from the implementation (ensure they match)
    const baseDisplayPath = '/api/v1/users/me/settings/display';
    const baseLanguagePath = '/api/v1/users/me/settings/language';
    const baseSettingsPath = '/api/v1/users/me/settings';

    setUp(() {
      mockHttpClient = MockHtHttpClient();
      // mockRequestOptions = MockRequestOptions(); // Not needed now
      apiClient = HtAppSettingsApi(httpClient: mockHttpClient);
    });

    test('can be instantiated', () {
      expect(apiClient, isNotNull);
    });

    group('getDisplaySettings', () {
      final validSettingsJson = createDisplaySettingsJson();
      final expectedSettings = createDisplaySettingsObject();
      final validResponseJson = createSuccessResponseJson(validSettingsJson);

      test('completes successfully when http client returns valid wrapped data',
          () async {
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseDisplayPath),
        ).thenAnswer((_) async => validResponseJson);

        final actualSettings = await apiClient.getDisplaySettings();

        expect(actualSettings, equals(expectedSettings));
        verify(() => mockHttpClient.get<Map<String, dynamic>>(baseDisplayPath))
            .called(1);
      });

      test('throws UnknownException on invalid inner JSON structure', () async {
        // Valid wrapper, but invalid inner data
        final invalidInnerJson = {'baseTheme': 123}; // Invalid type for enum
        final invalidResponseJson = createSuccessResponseJson(invalidInnerJson);
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseDisplayPath),
        ).thenAnswer((_) async => invalidResponseJson);

        expect(
          apiClient.getDisplaySettings(),
          // Expect UnknownException because FormatException is wrapped
          throwsA(isA<UnknownException>()),
        );
        verify(() => mockHttpClient.get<Map<String, dynamic>>(baseDisplayPath))
            .called(1);
      });

      test(
          'throws UnknownException on invalid wrapper structure (missing data)',
          () async {
        // Invalid wrapper structure
        final invalidWrapperJson = {'metadata': <String, dynamic>{}};
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseDisplayPath),
        ).thenAnswer((_) async => invalidWrapperJson);

        expect(
          apiClient.getDisplaySettings(),
          // Expect UnknownException because FormatException is wrapped
          throwsA(isA<UnknownException>()),
        );
        verify(() => mockHttpClient.get<Map<String, dynamic>>(baseDisplayPath))
            .called(1);
      });

      test('throws UnknownException on generic exception during http call',
          () async {
        final exception = Exception('Generic error');
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseDisplayPath),
        ).thenThrow(exception);

        expect(
          apiClient.getDisplaySettings(),
          throwsA(isA<UnknownException>()),
        );
        verify(() => mockHttpClient.get<Map<String, dynamic>>(baseDisplayPath))
            .called(1);
      });

      test('throws UnknownException on generic exception during http call',
          () async {
        final exception = Exception('Generic error');
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).thenThrow(exception);

        expect(
          apiClient.getLanguage(),
          throwsA(isA<UnknownException>()),
        );
        verify(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).called(1);
      });

      test('rethrows HtHttpException when http client throws', () async {
        // Use the correct constructor based on feedback
        final exception = NotFoundException('Resource not found');
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseDisplayPath),
        ).thenThrow(exception);

        expect(
          apiClient.getDisplaySettings(),
          throwsA(isA<NotFoundException>()),
        );
        verify(() => mockHttpClient.get<Map<String, dynamic>>(baseDisplayPath))
            .called(1);
      });
    });

    group('setDisplaySettings', () {
      final settingsToSet = createDisplaySettingsObject(
        baseTheme: AppBaseTheme.dark,
      );
      final settingsJson = settingsToSet.toJson();

      test('completes successfully when http client succeeds', () async {
        when(
          () => mockHttpClient.put<void>(
            baseDisplayPath,
            data: settingsJson,
          ),
        ).thenAnswer((_) async {}); // Simulate successful void PUT

        await apiClient.setDisplaySettings(settingsToSet);

        verify(
          () => mockHttpClient.put<void>(
            baseDisplayPath,
            data: settingsJson,
          ),
        ).called(1);
      });

      test('throws HtAppSettingsException on generic exception', () async {
        final exception = Exception('Generic error');
        when(
          () => mockHttpClient.put<void>(
            baseDisplayPath,
            data: settingsJson,
          ),
        ).thenThrow(exception);

        expect(
          apiClient.setDisplaySettings(settingsToSet),
          throwsA(isA<UnknownException>()),
        );
        verify(
          () => mockHttpClient.put<void>(
            baseDisplayPath,
            data: settingsJson,
          ),
        ).called(1);
      });

      test('rethrows HtHttpException when http client throws', () async {
        final exception = BadRequestException('Invalid settings format');
        when(
          () => mockHttpClient.put<void>(
            baseDisplayPath,
            data: settingsJson,
          ),
        ).thenThrow(exception);

        expect(
          apiClient.setDisplaySettings(settingsToSet),
          throwsA(isA<BadRequestException>()),
        );
        verify(
          () => mockHttpClient.put<void>(
            baseDisplayPath,
            data: settingsJson,
          ),
        ).called(1);
      });
    });

    group('getLanguage', () {
      const expectedLanguage = 'fr';
      final validLanguageJson = {'language': expectedLanguage};
      final validResponseJson = createSuccessResponseJson(validLanguageJson);

      test('completes successfully when http client returns valid wrapped data',
          () async {
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).thenAnswer((_) async => validResponseJson);

        final actualLanguage = await apiClient.getLanguage();

        expect(actualLanguage, equals(expectedLanguage));
        verify(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).called(1);
      });

      test('throws UnknownException when language key is missing in inner data',
          () async {
        final invalidInnerJson = {'other_key': 'value'}; // Missing key
        final invalidResponseJson = createSuccessResponseJson(invalidInnerJson);
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).thenAnswer((_) async => invalidResponseJson);

        expect(
          apiClient.getLanguage(),
          // Expect UnknownException because FormatException is wrapped
          throwsA(isA<UnknownException>()),
        );
        verify(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).called(1);
      });

      test('throws UnknownException when language value is not string',
          () async {
        final invalidInnerJson = {'language': 123}; // Wrong type
        final invalidResponseJson = createSuccessResponseJson(invalidInnerJson);
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).thenAnswer((_) async => invalidResponseJson);

        expect(
          apiClient.getLanguage(),
          // Expect UnknownException because FormatException is wrapped
          throwsA(isA<UnknownException>()),
        );
        verify(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).called(1);
      });

      test(
          'throws UnknownException on invalid wrapper structure (missing data)',
          () async {
        // Invalid wrapper structure
        final invalidWrapperJson = {'metadata': <String, dynamic>{}};
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).thenAnswer((_) async => invalidWrapperJson);

        expect(
          apiClient.getLanguage(),
          // Expect UnknownException because FormatException is wrapped
          throwsA(isA<UnknownException>()),
        );
        verify(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).called(1);
      });

      test('rethrows HtHttpException when http client throws during http call',
          () async {
        final exception = ServerException('Internal server error');
        when(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).thenThrow(exception);

        expect(
          apiClient.getLanguage(),
          throwsA(isA<ServerException>()),
        );
        verify(
          () => mockHttpClient.get<Map<String, dynamic>>(baseLanguagePath),
        ).called(1);
      });
    });

    group('setLanguage', () {
      const languageToSet = 'es';
      final expectedData = {'language': languageToSet};

      test('completes successfully when http client succeeds', () async {
        when(
          () => mockHttpClient.put<void>(
            baseLanguagePath,
            data: expectedData,
          ),
        ).thenAnswer((_) async {});

        await apiClient.setLanguage(languageToSet);

        verify(
          () => mockHttpClient.put<void>(
            baseLanguagePath,
            data: expectedData,
          ),
        ).called(1);
      });

      test('throws HtAppSettingsException on generic exception', () async {
        final exception = Exception('Generic error');
        when(
          () => mockHttpClient.put<void>(
            baseLanguagePath,
            data: expectedData,
          ),
        ).thenThrow(exception);

        expect(
          apiClient.setLanguage(languageToSet),
          throwsA(isA<UnknownException>()),
        );
        verify(
          () => mockHttpClient.put<void>(
            baseLanguagePath,
            data: expectedData,
          ),
        ).called(1);
      });

      test('rethrows HtHttpException when http client throws', () async {
        // NetworkException constructor takes optional DioException, not message
        final exception = NetworkException();
        when(
          () => mockHttpClient.put<void>(
            baseLanguagePath,
            data: expectedData,
          ),
        ).thenThrow(exception);

        expect(
          apiClient.setLanguage(languageToSet),
          throwsA(isA<NetworkException>()),
        );
        verify(
          () => mockHttpClient.put<void>(
            baseLanguagePath,
            data: expectedData,
          ),
        ).called(1);
      });
    });

    group('clearSettings', () {
      test('completes successfully when http client succeeds', () async {
        when(
          () => mockHttpClient.delete<void>(baseSettingsPath),
        ).thenAnswer((_) async {});

        await apiClient.clearSettings();

        verify(
          () => mockHttpClient.delete<void>(baseSettingsPath),
        ).called(1);
      });

      test('throws HtAppSettingsException on generic exception', () async {
        final exception = Exception('Generic error');
        when(
          () => mockHttpClient.delete<void>(baseSettingsPath),
        ).thenThrow(exception);

        expect(
          apiClient.clearSettings(),
          throwsA(isA<UnknownException>()),
        );
        verify(
          () => mockHttpClient.delete<void>(baseSettingsPath),
        ).called(1);
      });

      test('rethrows HtHttpException when http client throws', () async {
        // Correct exception name and constructor
        final exception = UnauthorizedException('Invalid token');
        when(
          () => mockHttpClient.delete<void>(baseSettingsPath),
        ).thenThrow(exception);

        expect(
          apiClient.clearSettings(),
          // Use correct exception type
          throwsA(isA<UnauthorizedException>()),
        );
        verify(
          () => mockHttpClient.delete<void>(baseSettingsPath),
        ).called(1);
      });
    });
  });
}
