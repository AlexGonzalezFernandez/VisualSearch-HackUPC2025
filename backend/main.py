# main.py (FastAPI server)
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse

from backend.inditex_api import InditexVisualSearchAPI

app = FastAPI()

inditex_api = InditexVisualSearchAPI()

@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    """
    Endpoint to receive an uploaded image file.
    Returns products as JSON.
    """
    # (Here you could read/process the image: content = await file.read())
    image_url = "https://cdn.pixabay.com/photo/2017/10/29/13/17/jacket-2899729_1280.png"
    json_response = inditex_api.search_product_by_image_url(image_url)
    return JSONResponse(content=json_response)

@app.get("/profile/{user_id}")
async def get_user_profile(user_id: int):
    """
    Endpoint to get user profile information from keycloak.
    Returns mock user profile data as JSON.
    """
    # (Here you could fetch user profile data from Keycloak)
    return {"Hello": "User", "user_id": user_id, "profile": "Mock profile data"}

@app.get("/home")
async def home():
    """
    Simple home, shows a welcome, login and register message.
    """
    return {"message": "Welcome to the Visual Search API! Please login or register."}
@app.get("/home/login")
async def login():
    """
    Simple home, shows a welcome, login and register message.
    """
    return {"message": "Welcome to the Visual Search API! Please login or register."}
@app.get("/home/register")
async def register():
    """
    Simple home, shows a welcome, login and register message.
    """
    return {"message": "Welcome to the Visual Search API! Please login or register."}
@app.get("/home/login/callback")
async def login_callback():
    """
    Simple home, shows a welcome, login and register message.
    """
    return {"message": "Welcome to the Visual Search API! Please login or register."}
@app.get("/home/logout")
async def logout():
    """
    Simple home, shows a welcome, login and register message.
    """
    return {"message": "Welcome to the Visual Search API! Please login or register."}