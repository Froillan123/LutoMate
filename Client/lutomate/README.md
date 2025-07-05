# LutoMate Flutter App

A Flutter application for recipe discovery and meal planning.

## Features

- User authentication and registration
- AI-powered recipe suggestions
- Voice-based recipe search
- Image integration with Openverse API (free alternative to Unsplash)
- Recipe history and favorites

## Image Integration

This app uses the [Openverse API](https://api.openverse.engineering/) for fetching food-related images. Openverse is a free and open-source alternative to Unsplash that provides access to millions of openly licensed images from various sources.

### Benefits of Openverse:
- **Free**: No API key required
- **Open Source**: Community-driven project
- **Multiple Sources**: Images from Wikimedia Commons, Flickr, and more
- **Licensed Content**: All images are properly licensed for commercial use

### API Usage:
- Images are fetched automatically for recipe categories
- Fallback mechanism ensures images are available even if commercial licenses aren't found
- Error handling prevents app crashes when image fetching fails

## Environment Setup

Copy `env.txt` to `.env` and configure:

```
API_BASE_URL=https://lutomate.onrender.com
```

Note: No API key is required for Openverse integration.

## Getting Started

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- `http`: For API communication
- Flutter standard libraries

## API Endpoints

The app communicates with the LutoMate backend API for:
- User authentication
- Recipe data
- AI-powered suggestions
- Voice queries
