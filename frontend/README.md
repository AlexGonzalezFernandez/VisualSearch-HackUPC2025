# 📱 Frontend - Flutter (Dart)

This is the mobile app built with Flutter that allows users to take a photo of clothing and receive product information using the Inditex Visual Search API.

---

## 🔧 Setup

1. **Install Flutter**  
   Make sure you have Flutter installed. If not, follow the instructions here:  
   https://docs.flutter.dev/get-started/install

2. **Install Dependencies**  
   Navigate to the `frontend` directory and run the following command to fetch all dependencies:
   ```bash
   flutter pub get

3. **Run the App**  
   You can run the app on an emulator or a physical device. Use the following command:
   ```bash
   flutter run
   ```

---
## 📸 Usage Flow

1. **Take a Photo**  
   Tap the "Take Photo" button to open the camera.
2. **Capture the Image**
   Take a picture of the clothing you want to search for.
3. **Send to Backend**
   The app sends the captured image to the backend for processing.
4. **Receive Product Info**
   The backend sends the results from the Inditex Visual Search API, and the app displays product information (e.g., name, price, link).
---
## ⚠️ Important Notes
1. **Backend URL**  
   You must replace the backend URL with your local server's IP address in `main.dart`. Find your local IP (e.g., 192.168.1.x) and use it in the code below:
   ```dart
   Uri.parse("http://192.168.x.x:8000/analyze")
   ```
2. **Same Network Requirement**  
   Ensure that your phone and the backend server (running on your computer) are on the same Wi-Fi network.
---
## 🧪 Test the App
After setting up the app, test it by:
1. Running the backend server (uvicorn).
2. Running the Flutter app (flutter run).
3. Taking a picture of any clothing item and viewing the returned results.
---

## 🔧 Dependencies

In pubspec.yaml, you’ll find the dependencies for the app:

dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.0.0     # For capturing images
  http: ^0.13.0           # For sending HTTP requests to the backend


