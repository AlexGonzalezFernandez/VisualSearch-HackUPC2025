# main.py (FastAPI server)
from fastapi import FastAPI, UploadFile, File, Request
from fastapi.responses import JSONResponse

app = FastAPI()

@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    """
    Endpoint to receive an uploaded image file.
    Returns mock product information as JSON.
    """
    # (Here you could read/process the image: content = await file.read())
    dummy_data = {
        "product_name": "Example Shirt",
        "price": "29.99",
        "link": "https://example.com/product/123"
    }
    return JSONResponse(content=dummy_data)


@app.get("/profile/{user_id}")
async def get_user_profile(user_id: int):
    """
    Endpoint to get user profile information from keycloak.
    Returns mock user profile data as JSON.
    """
    # (Here you could fetch user profile data from Keycloak)
    return {"Hello": "User", "user_id": user_id, "profile": "Mock profile data"}

@app.get("/home")
async def home(request: Request):
    """
    Simple home, shows a welcome message with login and register links.
    """
    base_url = f"{request.url.scheme}://{request.headers['host']}"
    return {
        "message": "Welcome to the Visual Search API!",
        "actions": {
            "login": f"{base_url}/home/login",
            "register": f"{base_url}/home/register"
        }
    }


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