# main.py (FastAPI server)
from fastapi import FastAPI, UploadFile, File, Request
from fastapi.responses import JSONResponse
import shutil
import json
import os

from inditex_api import InditexVisualSearchAPI
from url_image_uploader import FirebaseStorageManager
from scrapper2 import InditexScraper, get_scrapper_key

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