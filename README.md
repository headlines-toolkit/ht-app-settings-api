# ht_app_settings_api

![coverage: 95%](https://img.shields.io/badge/coverage-95-green)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: PolyForm Free Trial](https://img.shields.io/badge/License-PolyForm%20Free%20Trial-blue)](https://polyformproject.org/licenses/free-trial/1.0.0)

> **Note:** This package is being archived. Please use the successor package [`ht-data-api`](https://github.com/headlines-toolkit/ht-data-api) instead.

An API client implementation for managing user application settings via an HTTP backend, part of the Headlines Toolkit (HT) ecosystem.

## Description

This package provides a concrete implementation of the `HtAppSettingsClient` interface defined in the `ht_app_settings_client` package. It uses the `HtHttpClient` (from the `ht_http_client` package) to interact with a backend API for retrieving and persisting user-specific settings like display preferences and language.

It assumes the backend API exposes endpoints nested under a user resource, such as `/api/v1/users/me/settings/...`.

## Getting Started

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  ht_app_settings_api:
    git:
      url: https://github.com/headlines-toolkit/ht-app-settings-api.git
      # Optionally specify a ref (branch, tag, commit hash)
      # ref: main
```

Ensure you also have the necessary peer dependencies:

```yaml
dependencies:
  ht_app_settings_client:
    git:
      url: https://github.com/headlines-toolkit/ht-app-settings-client.git
  ht_http_client:
    git:
      url: https://github.com/headlines-toolkit/ht-http-client.git
  ht_shared:
    git:
      url: https://github.com/headlines-toolkit/ht-shared.git
```

## Features

*   Implements the `HtAppSettingsClient` interface.
*   Provides methods to interact with backend API endpoints for:
    *   Getting and setting `DisplaySettings`.
    *   Getting and setting `AppLanguage`.
    *   Clearing all settings.
*   Uses `HtHttpClient` for making HTTP requests.
*   Handles HTTP errors by throwing specific `HtHttpException` subtypes.
*   Wraps other potential errors (e.g., deserialization) in `UnknownException`.

## Usage

Instantiate `HtAppSettingsApi` with a configured `HtHttpClient` instance.

```dart
import 'package:ht_app_settings_api/ht_app_settings_api.dart';
import 'package:ht_app_settings_client/ht_app_settings_client.dart';
import 'package:ht_http_client/ht_http_client.dart';

// Assume httpClient is an already configured HtHttpClient instance
// (e.g., provided via dependency injection)
final HtHttpClient httpClient = HtHttpClient(baseUrl: 'YOUR_API_BASE_URL');

// Create the API client instance
final HtAppSettingsClient appSettingsApi = HtAppSettingsApi(
  httpClient: httpClient,
);

// Example: Fetch display settings
Future<void> loadSettings(String userId) async {
  try {
    final DisplaySettings settings = await appSettingsApi.getDisplaySettings(
      userId: userId,
    );
    print('Current theme: ${settings.baseTheme}');
    // ... use the settings
  } on HtHttpException catch (e) {
    print('HTTP Error fetching settings: ${e.message}');
  } on UnknownException catch (e) {
    print('Error fetching settings: ${e.message}');
  }
}

// Example: Set language
Future<void> changeLanguage(String userId, AppLanguage newLanguage) async {
  try {
    await appSettingsApi.setLanguage(
      userId: userId,
      language: newLanguage,
    );
    print('Language updated successfully.');
  } on HtHttpException catch (e) {
    print('HTTP Error setting language: ${e.message}');
  } on UnknownException catch (e) {
    print('Error setting language: ${e.message}');
  }
}
```

## License

This package is licensed under the [PolyForm Free Trial 1.0.0](LICENSE). Please review the terms before use.
