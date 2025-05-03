# main.py (FastAPI server)
from fastapi import FastAPI, UploadFile, File, Request
from fastapi.responses import JSONResponse
import shutil
import json
from inditex_api import InditexVisualSearchAPI
from url_image_uploader import FirebaseStorageManager
from utils import generate_login_url
from auth import get_keycloak_tokens
import secrets

SESSION = {}

app = FastAPI()

inditex_api = InditexVisualSearchAPI()

cred_path = 'config/visualsearchhackupc-firebase-adminsdk-fbsvc-9483e6d9c2.json'
bucket_name = 'visualsearchhackupc.firebasestorage.app'
uploader = FirebaseStorageManager(cred_path, bucket_name)

with open('../url.txt', 'r') as file:
    URL_PREFIX = file.read().strip()

with open('config/marc_keys.json', 'r') as file:
    keys = json.load(file)
    CLIENT_ID = keys.get("client_id")
    KEYCLOAK_REALM = keys.get("realm_name")
    secret = keys

@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    """
    Endpoint to receive an uploaded image file.
    Returns products as JSON.
    """
    image_path = f"images/{file.filename}"
    with open(image_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    image_url = uploader.upload_image(image_path)
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
async def home(request: Request):
    """
    Simple home, shows a welcome message with login and register links.
    """
    return {
        "message": "Welcome to the Visual Search API!",
        "actions": {
            "login": f"{URL_PREFIX}/home/login",
            "register": f"{URL_PREFIX}/home/register"
        }
    }



@app.get("/home/login")
async def login():
    """Login logic page."""
    state = secrets.token_urlsafe(16)
    SESSION['state'] = state
    login_url = generate_login_url(state=state)
    return {"login_url": login_url}



@app.get("/home/login/callback")
async def login_callback(request: Request):
    """
    Keycloak callback logic page.
    """
    #Get the state
    received_state = request.query_params.get("state")
    stored_state = SESSION.get("state")  # Retrieve & remove state
    SESSION.pop("state", None)
    code = request.query_params.get("code")
    #Check the state
    if received_state != stored_state or not code:
        return JSONResponse("Invalid user", status_code=404)
    
    tokens = get_keycloak_tokens(code, KEYCLOAK_REALM, CLIENT_ID, secret, f"{URL_PREFIX}/callback")

    id_token = tokens.get('id_token')
    access_token = tokens.get('access_token')
    refresh_token = tokens.get('refresh_token')

    # Store user details in the session
    request.session["authenticated"] = True
    request.session["username"] = id_token.get("preferred_username")
    request.session["id_token"] = id_token
    request.session["access_token"] = access_token
    request.session["refresh_token"] = refresh_token

    return JSONResponse("User logged in successfully", status_code=200)




@app.get("/home/register")
async def register():
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