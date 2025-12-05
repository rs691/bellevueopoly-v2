# Project Blueprint

## Overview

This document outlines the architecture and implementation of the Flutter application. It serves as a guide for developers to understand the project structure, design principles, and implemented features.

## Project Structure

- `lib/` - The main source code of the application.
  - `main.dart` - The entry point of the application.
  - `models/` - Contains the data models for the application (e.g., `Business`, `Player`).
  - `screens/` - The different screens of the application.
  - `widgets/` - Reusable widgets used throughout the application.
  - `router/` - The routing configuration using `go_router`.
  - `theme/` - The application's theme and styling.
  - `services/` - Services for fetching data and handling business logic.
  - `providers/` - State management providers.
- `assets/` - Contains static assets like JSON data and images.
- `test/` - Contains the tests for the application.

## Implemented Features

- **UI and Theming:**
  - A modern, dark theme with a purple and green color scheme.
  - Custom `GlassmorphicCard` widget for a blurred glass effect.
  - Consistent styling for buttons, text, and other UI elements.
- **Navigation:**
  - Routing is handled by the `go_router` package.
  - A bottom navigation bar for easy access to the main screens.
  - Screens for home, business listings, business details, profile, and settings.
- **Data Models:**
  - `Business`: Represents a business with properties like name, address, and ID.
  - `Player`: Represents the user of the application.
  - `City`: Represents the city in which the game is being played.
- **Services:**
  - `ConfigService`: Loads configuration data from a JSON file.
  - `LocationService`: Handles location-related functionalities.

## Recent Fixes

- **`app_theme.dart`:** Corrected the `cardTheme` property to use `CardThemeData` instead of `CardTheme`.
- **`index.dart`:** Added missing exports for `WelcomeScreen`, `SettingsScreen`, and `BusinessListScreen`.
- **`business_card.dart`:** Removed the display of the `distance` property, which was not part of the `Business` model.
- **`glassmorphic_card.dart`:** Replaced non-existent color constants with colors from the `AppTheme`.
- **`main_scaffold.dart`:** Corrected the logic in `_calculateCurrentIndex` to properly highlight the active tab in the bottom navigation bar.

This blueprint provides a snapshot of the project's current state. It will be updated as new features are added and changes are made.
