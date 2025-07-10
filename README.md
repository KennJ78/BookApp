# Book App

A Flutter application for managing a book collection with local storage.

## Features

- View list of books
- Add new books
- Delete books
- Modern Material Design UI
- Works completely offline

## Project Structure

```
bookapp/
├── lib/
│   ├── main.dart          # Main Flutter app entry point
│   ├── homepage.dart      # Home page with book list
│   └── addbookpage.dart   # Add book form page
└── README.md
```

## Setup Instructions

### Flutter App Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run the Flutter app:
   ```bash
   flutter run
   ```

## How It Works

The app now works completely offline with local state management:

1. **HomePage**: 
   - Displays a list of books stored in memory
   - Handles book deletion with confirmation dialog
   - Navigates to AddBookPage when adding new books

2. **AddBookPage**: 
   - Form to add new books with validation
   - Returns the new book object to HomePage
   - Generates unique IDs using timestamps

3. **Book Model**: 
   - Simple data class with id, title, author, and description
   - No external dependencies

## Book Data Structure

```dart
class Book {
  final String id;
  final String title;
  final String author;
  final String description;
}
```

## Requirements

- Flutter SDK

## Notes

- The app uses in-memory storage, so data will be lost when the app is closed
- No internet connection required
- Simple and lightweight implementation
- Perfect for learning Flutter state management
