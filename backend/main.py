# main.py (FastAPI server)
from fastapi import FastAPI, UploadFile, File, Request
from fastapi.responses import JSONResponse
import shutil
import json
import os

from inditex_api import InditexVisualSearchAPI
from url_image_uploader import FirebaseStorageManager
from scrapper2 import InditexScraper, get_scrapper_key
from utils import generate_login_url
from auth import get_keycloak_tokens, use_kc_openid
import secrets

SESSION = {}

app = FastAPI()

inditex_api = InditexVisualSearchAPI()

cred_path = 'config/visualsearchhackupc-firebase-adminsdk-fbsvc-9483e6d9c2.json'
bucket_name = 'visualsearchhackupc.firebasestorage.app'
uploader = FirebaseStorageManager(cred_path, bucket_name)

def update_scrapping_cache(web_url, image_url):
    with open('caches/scrapping_cache.json', 'r') as f:
        cache_scraping = json.load(f)
    cache_scraping[web_url] = image_url
    with open('caches/scrapping_cache.json', 'w') as f:
        json.dump(cache_scraping, f)

def image_scrapped_cached(web_url):
    # if the cache file does not exist, create one with '[]' as content
    if not os.path.exists('caches/scrapping_cache.json'):
        with open('caches/scrapping_cache.json', 'w') as f:
            f.write('{}')
    with open('caches/scrapping_cache.json', 'rb') as f:
        cache_scraping = json.load(f)
    for web_url_cached, image_url in cache_scraping.items():
        if web_url_cached == web_url:
            return image_url
    return None

def add_image_url(json_response):
    """
    Helper function to get the image URL from the JSON response.
    """
    for item in json_response:
        web_url = item['link']
        cached_image = image_scrapped_cached(web_url)
        if cached_image:
            item['image_url'] = cached_image
            print("Scrapped image from cache")
        else:
            scrapper = InditexScraper(api_key=get_scrapper_key())
            response = scrapper.scrape_image(name=item['name'], link=item['link'])
            if 'error' in response:
                raise Exception(response['error'])
            else:
                item['image_url'] = response['image_url']
                update_scrapping_cache(web_url, response['image_url'])
    return json_response

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
    json_response = add_image_url(json_response)
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
    if id_token is None or access_token is None:
        return JSONResponse("Invalid user", status_code=404)
    
    SESSION['access_token'] = access_token
    SESSION['refresh_token'] = refresh_token
    SESSION['id_token'] = id_token

    return JSONResponse("User logged in successfully", status_code=200)




@app.get("/home/register")
async def register():
    """
    Simple home, shows a welcome, login and register message.
    """
    return {"message": "Welcome to the Visual Search API! Please login or register."}

@app.get("/home/logout")
async def logout():
    """Logs out, clears session and redirects to home."""
    refresh_token = SESSION.get("refresh_token")
    SESSION.clear()
    if refresh_token:
        kcopenid = use_kc_openid()
        kcopenid.logout(refresh_token)
    return JSONResponse(content={"message": "Logged out successfully", "navigate_to": "/home"}, status_code=200)