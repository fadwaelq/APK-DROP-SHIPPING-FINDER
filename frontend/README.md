# Dropshipping Finder

An AI-powered mobile application that transforms tedious product research into an intelligent, secure, and lightning-fast experience powered by AI and data analytics.

## Overview

Dropshipping Finder helps entrepreneurs discover profitable products in seconds instead of hours. Using advanced AI and big data analysis, it provides:

- **3-second product discovery** instead of 3+ hours of manual research
- **90%+ accuracy** in profitability predictions
- **Anonymous research** via Tor network integration
- **Real-time trend detection** before competitors

## Features

- **Smart Product Discovery**: AI-powered search across AliExpress, Amazon, and Shopify
- **Advanced Analytics**: Comprehensive metrics including demand, popularity, competition, and profitability scores
- **Category Filtering**: Browse by Tech, Sport, Home, Fashion, Beauty, Toys, and Health
- **Favorites Management**: Save and organize promising products
- **Trend Analysis**: Real-time tracking of product performance and market trends
- **Supplier Intelligence**: Detailed supplier ratings and reviews
- **User Profiles**: Personalized experience with subscription management

## Tech Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart (>=3.0.0)
- **State Management**: Provider
- **Networking**: HTTP & Dio
- **UI**: Google Fonts (Inter), Flutter SVG, Cached Network Images
- **Charts**: FL Chart
- **Backend**: Django REST API (separate project)

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (3.0 or higher)
- Xcode (for iOS development)
- Android Studio (for Android development)
- A running instance of the Django backend API

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd dropshipping-finder-mobile/frontend
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

Create an `assets/.env` file in the project root:

```env
API_BASE_URL=http://localhost:8000/api
```

**Note**: Update the API_BASE_URL to point to your Django backend instance.

### 4. Run the Application

#### iOS
```bash
flutter run -d ios
```

#### Android
```bash
flutter run -d android
```

#### macOS (Development)
```bash
flutter run -d macos
```

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── models/                      # Data models
│   ├── product.dart            # Product, Supplier, PerformanceMetrics
│   └── user.dart               # User model
├── providers/                   # State management
│   ├── auth_provider.dart      # Authentication logic
│   ├── product_provider.dart   # Product operations
│   └── user_provider.dart      # User management
├── screens/                     # UI screens
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen_v2.dart
│   ├── search_screen.dart
│   ├── product_detail_screen.dart
│   ├── favorites_screen.dart
│   ├── profile_screen.dart
│   ├── edit_profile_screen.dart
│   └── subscription_screen.dart
├── widgets/                     # Reusable components
│   ├── bottom_nav_bar.dart
│   ├── product_card.dart
│   └── stat_card.dart
├── services/                    # Business logic
│   └── api_service.dart        # Backend API integration
└── utils/                       # Utilities
    └── theme.dart              # App theme and colors
```

## Design System

### Color Palette

- **Primary Orange**: `#FF8C42`
- **Dark Orange**: `#FF6B1A`
- **Background**: `#F8F9FA`
- **Text Primary**: `#212529`
- **Text Secondary**: `#6C757D`

### Score Colors

Products are rated with color-coded scores:
- **Excellent** (90+): Green `#51CF66`
- **Good** (75-89): Light Green `#94D82D`
- **Average** (60-74): Yellow `#FFD43B`
- **Poor** (<60): Red `#FF8787`

### Typography

The app uses **Inter** font family via Google Fonts for a modern, clean interface.

## API Integration

The app communicates with a Django REST API backend. Key endpoints include:

- **Authentication**: `/auth/login/`, `/auth/register/`
- **Products**: `/products/`, `/products/trending/`, `/products/search/`
- **Favorites**: `/favorites/`, `/favorites/toggle/`
- **User**: `/users/me/`
- **Subscription**: `/subscription/update/`

Authentication is handled via Bearer tokens included in request headers.

## Building for Production

### iOS

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode and archive the app.

### Android

```bash
# APK
flutter build apk --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release
```

## Testing

Run the test suite:

```bash
flutter test
```

## UI Designs

Design mockups for the app are available in the `/designs/` folder. All designs are optimized for iPhone 16 Pro Max.

## Development

### Adding New Features

1. Check design files in `/designs/` folder
2. Create or update models in `lib/models/`
3. Add API methods to `lib/services/api_service.dart`
4. Update providers for state management
5. Build UI screens following existing patterns
6. Use theme constants from `lib/utils/theme.dart`

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use consistent naming conventions
- Add comments for complex logic
- Ensure proper error handling

## Troubleshooting

### Common Issues

**Issue**: `.env` file not found
**Solution**: Create `assets/.env` with your API configuration

**Issue**: API connection fails
**Solution**: Ensure Django backend is running and `API_BASE_URL` is correct

**Issue**: iOS build fails
**Solution**: Run `cd ios && pod install && cd ..`

**Issue**: Images not loading
**Solution**: Check network connectivity and API image URLs

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Documentation

For detailed project documentation, architecture, and development guidelines, see [CLAUDE.md](./CLAUDE.md).

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)

## License

[Add your license here]

## Support

For issues, questions, or contributions, please open an issue on the repository.

---

**Built with Flutter**
