# 👗 Inditex Visual Search Hackathon App

This project is a full-stack solution for visual search in fashion, developed for the HackUPC 2025. The app allows users to take a photo of a clothing item and receive product information from Inditex brands like Zara, Pull&Bear, and more.

---

## 📂 Project Structure

```plaintext
VisualSearch-HackUPC2025/
├── backend/                  # FastAPI backend (Python)
│   ├── main.py               # FastAPI app entry point
│   ├── requirements.txt      # Python dependencies
│   └── README.md             # Backend-specific setup
│
├── frontend/                 # Flutter mobile app (Dart)
│   ├── lib/                  # Flutter source code
│   ├── pubspec.yaml          # Flutter dependencies
│   └── README.md             # Frontend-specific setup
│
└── README.md                 # General project overview (this file)
```

---

## 🚀 How It Works

1. **User Interaction**: The user takes a photo of a clothing item using the Flutter app.
2. **Backend Processing**: The app sends the image to the FastAPI backend, which forwards it to Inditex's Visual Search API.
3. **Product Matching**: The backend processes the response and sends product details back to the app.
4. **Results Display**: The app displays the product name, price, and a link to purchase.

---

## 🔧 Tech Stack

### Frontend
- **Flutter (Dart)**: Cross-platform mobile app development.
- **Packages**: `image_picker`, `http`, `url_launcher`.

### Backend
- **FastAPI (Python)**: High-performance backend framework.
- **Integrations**: Inditex Visual Search API, Firebase (mocked).

---

## 🛠️ Setup & Execution

### 1. Clone the Repository
```bash
git clone https://github.com/AlexGonzalezFernandez/VisualSearch-HackUPC2025.git
cd VisualSearch-HackUPC2025/
```
The backend and the fronted are separated and they need to be executed at the same time sepratedly.
You will see further details in the specific README files of the backend and frontend folders.

### Backend
Navigate to the `backend` folder and follow the instructions in its [README](backend/README.md).
The backend uses python 3.10.13 

### Frontend
Navigate to the `frontend` folder and follow the instructions in its [README](frontend/README.md).
The frontend uses flutter

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🌟 Devpost Description

Check out the full project description and demo on [Devpost](https://devpost.com/software/hackchallenge2025).
