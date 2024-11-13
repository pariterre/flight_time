# flight_time

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Prepare the project

### Android

Change the minimum SDK version to 21 (or higher) in `android/app/build.gradle`:

    minSdkVersion 21


### iOS

Add these on ios/Runner/Info.plist:

<key>NSCameraUsageDescription</key>
<string>Your own description</string>

<key>NSMicrophoneUsageDescription</key>
<string>To enable microphone access when recording video</string>

<key>UIRequiresFullScreen</key>
<true/>

## Generate icons

To generate the icons, run:

    dart run flutter_launcher_icons

### Android

    For some unknown reason, the folder `android/app/src/main/res/mipmap-anydpi-26` creates a transparent icon on Android 8.0.0. To fix this, delete the folder `android/app/src/main/res/mipmap-anydpi-26`.

### iOS

    Nothing special to do.

## Generate splash screen

### Android

Currently not setup

### iOS

Run the following command: 

    dart run flutter_native_splash:create --path=flutter_native_splash.yaml

## Building the app

### Android

To build the app, run the following command:

    flutter build appbundle

If the signing process fails, you probably forgot to add the `key.properties` file. Create a file named `key.properties` in the `android` folder with the following content:

    storeFile=...
    storePassword=...  
    keyAlias=s2mjumpapp
    keyPassword=...

If you don't have the `storeFile`, you must request it from the project owner.

### iOS

    flutter build ios --release