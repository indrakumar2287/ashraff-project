# Google Maps integration for Android

This guide adds a Google map to this Flutter app on Android only. It does not
configure iOS, web, desktop, directions, geocoding, or device-location
permissions.

The Android application ID in this project is
`com.ashraffapps.shopping_app` (`android/app/build.gradle.kts`).

## 1. Create and secure a Google Maps API key

1. Open the [Google Cloud Console](https://console.cloud.google.com/), select
   or create a project, and attach a billing account. Maps Platform requires
   billing to be enabled.
2. In **APIs & Services → Library**, enable **Maps SDK for Android**.
3. In **APIs & Services → Credentials**, create an API key.
4. Restrict the key:
   - Under **Application restrictions**, select **Android apps**.
   - Add package name `com.ashraffapps.shopping_app`.
   - Add the SHA-1 certificate fingerprint for each build that will use this
     key. Get the local debug fingerprint with:

     ```sh
     cd android
     ./gradlew signingReport
     ```

     Find the `SHA1` value under the `debug` variant. Add the release signing
     certificate's SHA-1 separately before distributing a release build.
   - Under **API restrictions**, restrict the key to **Maps SDK for Android**.
5. Keep separate keys for development and production when practical. Do not
   commit unrestricted keys or upload signing credentials.

Google key restrictions are essential: the key is included in the installed
app and should not be treated as a private server secret.

## 2. Add the Flutter plugin

From the project root, add the current compatible plugin version through the
Flutter package manager:

```sh
flutter pub add google_maps_flutter
```

This adds the dependency to `pubspec.yaml` and resolves it in `pubspec.lock`.
The existing Android configuration uses Kotlin DSL in
`android/app/build.gradle.kts`.

## 3. Supply the key to Android at build time

Keep the key in the local Android `local.properties` file rather than in
committed source. Add the following line to `android/local.properties` without
removing existing Flutter SDK configuration:

```properties
MAPS_API_KEY=YOUR_RESTRICTED_ANDROID_API_KEY
```

Confirm that `android/local.properties` is ignored by Git before adding a real
key. Do not publish the file or paste a production key into documentation.

In `android/app/build.gradle.kts`, load the properties and expose the value as
a manifest placeholder. Add the properties loading before the `android { ... }`
block:

```kotlin
import java.util.Properties

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use(localProperties::load)
}
```

Then add this inside the existing `defaultConfig { ... }` block:

```kotlin
manifestPlaceholders["MAPS_API_KEY"] =
    localProperties.getProperty("MAPS_API_KEY", "")
```

Inside the existing `<application>` element in
`android/app/src/main/AndroidManifest.xml`, add:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${MAPS_API_KEY}" />
```

Do not add this metadata outside `<application>`. The app already declares
`android.permission.INTERNET`; displaying a map does not require the device's
location permission.

If using a different build system, flavors, or CI, provide the placeholder
through that build's secure configuration and ensure each variant uses a key
restricted to its actual package name and signing certificate.

## 4. Display a map

Create a screen such as `lib/screens/map_screen.dart`. Replace the sample
coordinates with the location appropriate to the app:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const LatLng initialLocation = LatLng(37.4219999, -122.0840575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: initialLocation,
          zoom: 14,
        ),
        markers: const {
          Marker(
            markerId: MarkerId('initial-location'),
            position: initialLocation,
            infoWindow: InfoWindow(title: 'Selected location'),
          ),
        },
      ),
    );
  }
}
```

Navigate to `MapScreen` using the app's existing GetX route conventions or
Flutter navigation. Keep the map in a widget with bounded size, such as the
`body` above or an `Expanded` child.

## 5. If the feature needs the user's location

Showing a map or a fixed marker does not need location permission. If the
feature specifically needs the user's current location, separately add a
location plugin, declare the appropriate Android location permissions, request
permission at runtime, handle denial/permanent denial, and only then enable the
map's current-location layer. Do not enable location display before permission
has been granted. Location acquisition and the Google Maps SDK are separate
concerns.

## 6. Run and troubleshoot

After adding the plugin and Android configuration:

```sh
flutter pub get
flutter run
```

Test on an Android emulator with Google Play services or a physical Android
device. If the map is blank, check:

- Billing and **Maps SDK for Android** are enabled in the same Cloud project
  as the key.
- The manifest metadata name and placeholder spelling match exactly.
- `MAPS_API_KEY` is present in `android/local.properties`, and Gradle was
  rebuilt after changing it.
- The key's Android restriction matches `com.ashraffapps.shopping_app` and
  the exact signing SHA-1 for the build being tested.
- The key's API restriction includes **Maps SDK for Android**.
- The device/emulator has network access and a supported Google Play services
  image.

Useful official references:

- [Google Maps Flutter package](https://pub.dev/packages/google_maps_flutter)
- [Google Maps Platform API key best practices](https://developers.google.com/maps/api-security-best-practices)
- [Google Maps SDK for Android setup](https://developers.google.com/maps/documentation/android-sdk/get-api-key)
