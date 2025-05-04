# 📱 Frontend - Flutter (Dart)

This is the mobile app built with Flutter that allows users to capture a photo of clothing and receive product information using the Inditex Visual Search API.

---

## 📂 Directory Structure

```
frontend/
├── android/             # Android-specific configuration and build files
├── ios/                 # iOS-specific configuration and build files
├── lib/                 # Dart source code for the Flutter app
├── linux/               # Linux-specific configuration and build files
├── macos/               # MacOS-specific configuration and build files
├── windows/             # Windows-specific configuration and build files
├── test/                # Automated tests for the Flutter app
├── .flutter-plugins     # Generated file for Flutter plugins
├── .gitignore           # Specifies intentionally untracked files that Git should ignore
├── README.md            # Documentation for the frontend
├── pubspec.yaml         # Flutter project configuration file
└── pubspec.lock         # Records the exact versions of dependencies used
```

---

## 📍 `lib/` Directory: Detailed Explanation

The `lib/` directory contains all the Dart source code for the Flutter application. It is structured to promote maintainability, scalability, and separation of concerns.

```
lib/
├── models/              # Data models representing the structure of the data
├── screens/             # Flutter screens (UI components)
├── services/            # Services for handling API calls and business logic
├── widgets/             # Reusable Flutter widgets
├── app.dart             # Main application file defining the app's structure
└── main.dart            # Entry point of the Flutter application
```

### ├── models/
This directory contains Dart classes that define the structure of the data used within the application. These models help in data serialization and deserialization, ensuring type safety and data integrity.

   - **Why?** Centralizing data models makes it easier to manage and update data structures consistently across the app.

### ├── screens/
This directory houses the different screens or pages of the Flutter application. Each file represents a distinct UI screen, such as the home screen, search results screen, or product details screen.

   - **Why?** Separating screens into individual files improves code organization and makes it easier to navigate and work on specific parts of the UI.

### ├── services/
This directory includes services that handle API calls, data processing, and other business logic. Services abstract the implementation details of fetching and manipulating data, providing a clean interface for the rest of the application.

   - **Why?** Abstracting services promotes code reusability and testability. It also allows you to change the underlying implementation (e.g., switching to a different API) without affecting the UI.

### ├── widgets/
This directory contains reusable Flutter widgets that can be used across multiple screens. These widgets encapsulate UI components like buttons, image displays, or custom input fields.

   - **Why?** Reusable widgets reduce code duplication and ensure a consistent look and feel throughout the application.

### ├── app.dart
This file defines the main application widget, setting up the app's theme, routing, and overall structure. It serves as the root widget for the entire application.

   - **Why?** Having a central `app.dart` file provides a clear entry point for understanding the app's high-level structure and configuration.

### └── main.dart
This is the entry point of the Flutter application. It initializes the Flutter environment and starts the app by calling the `runApp` function with the main application widget (`app.dart`).

   - **Why?** The `main.dart` file is essential for any Flutter app, as it tells Flutter where to begin executing the code.

---

## 🔧 Setup

1. **Install Flutter**  
   Ensure that you have Flutter installed on your development machine. If not, follow the installation instructions provided in the official Flutter documentation:  
   https://docs.flutter.dev/get-started/install

2. **Clean possible residual build files**
   Navigate to the `frontend` directory in your terminal and run the following command. Although good Git practices should make this unnecessary, cleaning the build files is a good habit to ensure a fresh start.
   ```bash
   flutter clean
   ```

3. **Install Dependencies**  
   In the same `frontend` directory, execute the following command to fetch all the required dependencies specified in the `pubspec.yaml` file:
   ```bash
   flutter pub get
   ```

4. **Run the App**  
   You can run the app on an emulator or a physical device. Ensure that your device is connected and properly configured, then use the following command to start the application:
   ```bash
   flutter run
   ```

---
## 📸 Usage Flow

1. **Take a Photo**  
   Tap the "Take Photo" button to open the camera.
2. **Capture the Image**
   Use the camera to take a clear picture of the clothing item you want to search for.
3. **Send to Backend**
   The app automatically sends the captured image to the backend server for analysis and processing.
4. **Receive Product Info**
   The backend server processes the image and sends back the relevant product information from the Inditex Visual Search API. The app then displays this information to the user, including details such as the product name, price, and a link to purchase.
---
## ⚠️ Important Notes
1. **Backend URL**  
   You must replace the backend URL with your local server's IP address in `main.dart`. Find your local IP (e.g., 192.168.1.x) and use it in the code below:
   ```dart
   Uri.parse("http://192.168.x.x:8000/analyze")
   ```
2. **Same Network Requirement**  
   Ensure that your phone and the backend server (running on your computer) are connected to the same Wi-Fi network.
---
## 🧪 Test the App
After completing the setup, thoroughly test the app by following these steps:
1. **Start the Backend Server:** First, ensure that the backend server (using uvicorn or a similar tool) is running and accessible.
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```
2. **Launch the Flutter App:** Run the Flutter app on your connected device or emulator using the `flutter run` command.
3. **Capture and Analyze:** Use the app to take a picture of a clothing item. Verify that the app sends the image to the backend and correctly displays the returned product information.
---

## 🔧 Dependencies

The app's dependencies are managed through the `pubspec.yaml` file. You **must** install these dependencies before running the app for the first time and after executing `flutter clean`.
To install dependencies, run:
```bash
flutter pub get
```

