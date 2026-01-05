# Development Environment Setup Guide

This guide will help you set up your development environment for the Dropshipping Finder mobile app.

## Prerequisites

Before starting, ensure you have:

- macOS (for iOS development) or Linux/Windows (for Android)
- Git installed
- A code editor (VS Code or Android Studio recommended)

## Step 1: Install Flutter

### macOS/Linux
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add to PATH (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/flutter/bin:$PATH"

# Verify installation
flutter doctor
```

### Windows
1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add to PATH in System Environment Variables
4. Run `flutter doctor` in Command Prompt

## Step 2: iOS Setup (macOS only)

### Install Xcode
```bash
# Install Xcode from App Store or run:
xcode-select --install

# Accept Xcode license
sudo xcodebuild -license accept
```

### Install CocoaPods
```bash
# Install CocoaPods (Ruby package manager for iOS)
sudo gem install cocoapods

# Verify installation
pod --version
```

### Setup iOS Simulator
```bash
# Open Xcode
open -a Simulator

# Or install from command line
xcodebuild -downloadPlatform iOS
```

## Step 3: Android Setup

### Install Android Studio
1. Download from https://developer.android.com/studio
2. Run the installer
3. Open Android Studio and complete setup wizard
4. Install Android SDK (API 33 or higher recommended)

### Accept Android Licenses
```bash
flutter doctor --android-licenses
```

### Install Android SDK Command-line Tools
1. Open Android Studio
2. Go to Settings → Appearance & Behavior → System Settings → Android SDK
3. Click "SDK Tools" tab
4. Check "Android SDK Command-line Tools"
5. Click "Apply" to install

### Setup Android Emulator
```bash
# Create an emulator via Android Studio AVD Manager
# Or use command line:
flutter emulators --launch <emulator_name>
```

## Step 4: Clone and Setup Project

```bash
# Clone repository
git clone <repository-url>
cd dropshipping-finder-mobile

# Install dependencies
flutter pub get

# Setup environment file
cp assets/.env.example assets/.env

# Edit .env file with your API configuration
# For iOS Simulator: http://localhost:8000/api
# For Android Emulator: http://10.0.2.2:8000/api
```

## Step 5: iOS Pod Installation

```bash
cd ios
pod install
cd ..
```

## Step 6: Verify Setup

```bash
# Check for issues
flutter doctor -v

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android
```

## Common Issues & Solutions

### Issue: CocoaPods not installed
**Solution:**
```bash
sudo gem install cocoapods
cd ios && pod install && cd ..
```

### Issue: Android licenses not accepted
**Solution:**
```bash
flutter doctor --android-licenses
```

### Issue: API connection fails
**Solution:**
- iOS: Use `http://localhost:8000/api` or `http://127.0.0.1:8000/api`
- Android Emulator: Use `http://10.0.2.2:8000/api`
- Real Device: Use your computer's IP (find with `ipconfig getifaddr en0` on Mac)

### Issue: Flutter not in PATH
**Solution:**
```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/flutter/bin:$PATH"
source ~/.zshrc
```

### Issue: Xcode version too old
**Solution:**
```bash
# Update Xcode from App Store
# Or install command line tools
xcode-select --install
```

### Issue: Pod install fails
**Solution:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
```

## Environment Configuration

### Development
Edit `assets/.env`:
```env
# iOS Simulator
API_BASE_URL=http://localhost:8000/api
ENV=development

# OR for Android Emulator
API_BASE_URL=http://10.0.2.2:8000/api
ENV=development
```

### Production
```env
API_BASE_URL=https://your-production-api.com/api
ENV=production
```

## Running the App

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run in release mode
flutter run --release

# Hot reload: press 'r' in terminal
# Hot restart: press 'R' in terminal
# Quit: press 'q' in terminal
```

## Building for Release

### iOS
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode and archive
```

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

## Troubleshooting

### Clear Build Cache
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Reset Flutter
```bash
flutter channel stable
flutter upgrade
flutter doctor -v
```

### Check Logs
```bash
# iOS logs
flutter logs

# Android logs
adb logcat
```

## Next Steps

1. Ensure Django backend is running on `http://localhost:8000`
2. Run the app with `flutter run`
3. Check the README.md for feature documentation
4. Review CLAUDE.md for architecture details

## Support

For issues:
1. Run `flutter doctor -v` and check output
2. Check GitHub Issues
3. Consult Flutter documentation: https://docs.flutter.dev
