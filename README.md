# 👗 Inditex Visual Search Hackathon App

This app takes a photo of a clothing item and returns product information using the Inditex Visual Search API.

---

## 🔧 Tech Stack

### Frontend (Mobile App)
- **Flutter** (Dart)
- Packages used:
  - `image_picker` (capture/select image)
  - `http` (send image to backend)

### Backend
- **FastAPI** (Python)
- Handles image upload and API forwarding to Inditex

---

## 🚀 How It Works

1. User takes a photo of clothing with the app.
2. App sends the image to a locally running FastAPI backend.
3. Backend forwards the image to Inditex's Visual Search API.
4. Response with product info is sent back to the app.
5. Product info is shown in the app.

---

inditex-visual-search/
├── backend/                  ← FastAPI backend (Python)
│   ├── main.py               ← FastAPI app
│   ├── requirements.txt      ← Python dependencies
│   └── README.md             ← Backend-specific setup
│
├── frontend/                 ← Flutter mobile app (Dart)
│   ├── lib/
│   │   └── main.dart         ← Flutter UI + logic
│   ├── pubspec.yaml          ← Flutter dependencies
│   └── README.md             ← Frontend-specific setup
│
└── README.md                 ← Master README for whole project


## EXECUTION

cd backend/
uvicorn main:app --host 0.0.0.0 --port 8000

//Otra terminal

studio # alias para el android studio (y abrir el mobil)

//Otra terminal

cd frontend/
flutter pub get
flutter run
