# Smart Panel

A modern Flutter application for managing and monitoring IoT devices through an intuitive dashboard interface using MQTT protocol.

## Features

- **Interactive Dashboard**: Customizable dashboard for monitoring multiple IoT devices and sensors
- **Widget Management**: Add and customize various panel widgets for different device types
- **MQTT Integration**: Real-time communication with IoT devices using MQTT protocol
- **Secure Communication**: Encrypted data transmission for enhanced security
- **Dark/Light Theme**: Support for both dark and light themes
- **Local Storage**: Persistent storage for device configurations and settings
- **Error Handling**: Robust error handling and logging system

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- MQTT Broker (Mosquitto recommended)
- iOS/Android development environment setup

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/smart_panel.git
cd smart_panel
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure MQTT broker:
- Update the `mosquitto.conf` file with your broker settings
- Ensure proper SSL/TLS certificates are placed in `assets/certs/` if using secure communication

4. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/          # Data models for panel items and widgets
├── screens/         # Application screens/pages
├── services/        # Core services (MQTT, Storage, Theme, etc.)
├── utils/          # Utility functions and helpers
└── widgets/        # Reusable UI components
```

### Key Components

- **Panel Items**: Configurable dashboard elements for different IoT devices
- **Widget System**: Extensible widget framework for various data displays
- **Service Layer**: 
  - MQTT Service: Handles device communication
  - Encryption Service: Manages secure data transmission
  - Storage Service: Handles local data persistence
  - Theme Service: Manages application theming
  - Logger Service: Comprehensive logging system

## Configuration

### MQTT Settings

The application requires a properly configured MQTT broker. Update the connection settings in the application:

1. Broker address
2. Port
3. Username/Password (if required)
4. SSL/TLS settings (if using secure communication)

### Theme Configuration

The application supports both light and dark themes, which can be configured in the settings screen.

## Testing

Run the tests using:
```bash
flutter test
```

The project includes:
- Widget tests
- Icon generator tests
- Service unit tests

## Security

- All sensitive data is encrypted using the encryption service
- Secure MQTT communication with SSL/TLS support
- Local storage encryption for sensitive data

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
