# 🖥 Backend - FastAPI (Python)

This is the backend server that receives clothing images and communicates with the Inditex Visual Search API.

---

## 🔧 Setup

1. **(Optional) Create a virtual environment**  
   It's recommended to use a virtual environment for Python. If you don't have one, create it by running:
   ```bash
   python -m venv venv

2. **Activate the virtual environment**
   ```bash
   # macOS/Linux
   source venv/bin/activate

   # Windows
   venv\Scripts\activate
   ```
3. **Install dependencies**
   Install the required Python packages listed in `requirements.txt`:
   ```bash
   pip install -r requirements.txt
   ```
4. **Run the server**
   Start the FastAPI server using uvicorn:
   ```bash
   uvicorn main:app --host

5. Test the API
   Open your browser or Postman to test the server:
   ```bash
   http://<your-ip>:8000/docs
   ```
   Note: Replace `<your-ip>` with the actual IP address of your local machine.

---
