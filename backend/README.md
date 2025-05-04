# Snap2Shop Backend Server

This is the backend for **Snap2Shop**, a mobile app that helps users discover fashion items from Inditex brands (Zara, Pull&Bear, Oysho, Mango) by using images.  
The backend is built with **FastAPI** and serves as the bridge between the mobile app and external APIs for product matching, image processing, and user data management.

---

## 📂 Project Structure

```plaintext
backend/
├── auth.py                     # User authentication logic (mocked)
├── caches/                     # Cached files for different resources
│   ├── firebase_cache.json     # Mocked Firebase session data
│   ├── inditex_cache.json      # Cached results for Inditex API responses
│   └── scrapping_cache.json    # Cached scraped images from Zara
├── config/                     # Configuration files (API keys, services)
│   ├── google-services.json    # Firebase service credentials
│   ├── marc_keys.json          # API keys for Inditex Tech
│   ├── scraper_key.txt         # Key for web scraping
│   ├── token.json              # Token for accessing Inditex API
│   └── visualsearchhackupc-firebase-adminsdk-fbsvc-9483e6d9c2.json # Firebase config
├── images/                     # Sample images for testing
├── inditex_api.py              # Logic to interact with Inditex API
├── main.py                     # Main FastAPI app entry point
├── prova_image_uploader.py     # Image uploader testing script
├── requirements.txt            # List of required Python packages
├── scrapper2.py                # Web scraping logic for product images
├── url_image_uploader.py       # Image uploading and storage logic
└── README.md                   # This file
```

---

## 🧩 Features

- **Image Uploading**: Upload product images and use the Inditex API to find similar items from their product catalog.
- **Product Matching**: Interfaces with Inditex’s visual search API to return similar products.
- **Web Scraping**: Scrapes Zara’s website for product images as a fallback.
- **User Session (Mocked)**: Simulates user sessions for tracking favorites (currently no real authentication).
- **Product Caching**: Caches recent search results and images to improve performance.
- **Firebase Integration (Mocked)**: Mocked Firebase integration for storing user data (auth flow not fully implemented yet).

---

## 🛠️ Prerequisites

Make sure you have the following installed:
- **Python 3.10+**
- **Git** for cloning the repository
- **pip** for installing Python dependencies

---

## 🚀 Getting Started

### 1. Create a Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

---

## 🔧 Configuration

Before running the backend, you need to set up the necessary configuration files:

1. **Firebase Configuration**:
   - Place the Firebase keys in the `config/` folder.
   - Update `google-services.json` and the Firebase admin SDK config file with the correct credentials.

2. **API Keys**:
   - Ensure that `marc_keys.json` and `token.json` have the correct API keys for interacting with Inditex Tech's visual search API.

3. **Scraper Key**:
   - The `scraper_key.txt` file is used for web scraping. Make sure it contains the required key from scraper api.

---

## 🚀 Running the Server

To start the FastAPI server locally, run the following command:
```bash
uvicorn main:app --reload
```

The server will start on `http://127.0.0.1:8000`. You can access the API and check the OpenAPI documentation at:

---

## 🖼️ Image Uploading

You can use the `/match` endpoint to upload an image and get similar products. The endpoint will accept an image file and return a list of matching items from Inditex brands.

### Example Request:
```bash
curl -X 'POST' \
  'http://127.0.0.1:8000/match' \
  -H 'accept: application/json' \
  -F 'image=@path_to_your_image_file.jpg'
```

---

## 📝 File Cache & Scraping

The backend stores some cached data in the `caches/` folder:
- `firebase_cache.json`: Mocked data for Firebase sessions.
- `inditex_cache.json`: Cached Inditex API responses.
- `scrapping_cache.json`: Cached images scraped from Zara's website.

Scraping results are saved in the `images/` directory for local testing.

---

## 🐞 Troubleshooting

- **500 Internal Server Error**: Check if the API keys and Firebase credentials are set correctly.
- **Slow Response**: The scraping functionality may take longer to retrieve images from Zara. The caching mechanism helps speed up responses.

---

## 💡 Future Improvements

- Implement real Firebase authentication for user login.
- Switch to a database (e.g., PostgreSQL) for persistent storage of user favorites.
- Enhance error handling and validation of uploaded images.
- Integrate with Inditex’s official cart system for product purchases.

---

## 📜 License

This project is licensed under the MIT License. See the LICENSE file for more details.
