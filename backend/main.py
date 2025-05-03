# main.py (FastAPI server)
from fastapi import FastAPI, UploadFile, File, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel
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


########################################################################################
#  Cache management                                                                    #
########################################################################################
def update_favorites(user_id, new_favorite):
    # if the cache file does not exist, create one with '{}' as content
    if not os.path.exists('caches/favorites_cache.json'):
        with open('caches/favorites_cache.json', 'w') as f:
            f.write('{}')
    with open('caches/favorites_cache.json', 'r') as f:
        cache_favorites = json.load(f)
    if str(user_id) in cache_favorites:
        cache_favorites[str(user_id)].append(new_favorite)
    else:
        cache_favorites[str(user_id)] = [new_favorite]
    with open('caches/favorites_cache.json', 'w') as f:
        json.dump(cache_favorites, f, indent=4)

def update_scrapping_cache(web_url, image_url):
    with open('caches/scrapping_cache.json', 'r') as f:
        cache_scraping = json.load(f)
    cache_scraping[web_url] = image_url
    with open('caches/scrapping_cache.json', 'w') as f:
        json.dump(cache_scraping, f, indent=4)

def update_firebase_cache(image_path, firebase_url):
    with open('caches/firebase_cache.json', 'r') as f:
        cache_firebase = json.load(f)
    cache_firebase[image_path] = firebase_url
    with open('caches/firebase_cache.json', 'w') as f:
        json.dump(cache_firebase, f, indent=4)

def update_inditex_cache(firebase_url, json_response):
    with open('caches/inditex_cache.json', 'r') as f:
        cache_inditex = json.load(f)
    cache_inditex[firebase_url] = json_response
    with open('caches/inditex_cache.json', 'w') as f:
        json.dump(cache_inditex, f, indent=4)

def image_scrapped_cached(web_url):
    # if the cache file does not exist, create one with '{}' as content
    if not os.path.exists('caches/scrapping_cache.json'):
        with open('caches/scrapping_cache.json', 'w') as f:
            f.write('{}')
    with open('caches/scrapping_cache.json', 'rb') as f:
        cache_scraping = json.load(f)
    for web_url_cached, image_url in cache_scraping.items():
        if web_url_cached == web_url:
            return image_url
    return None

def image_firebase_cached(image_path):
    # if the cache file does not exist, create one with '{}' as content
    if not os.path.exists('caches/firebase_cache.json'):
        with open('caches/firebase_cache.json', 'w') as f:
            f.write('{}')
    with open('caches/firebase_cache.json', 'rb') as f:
        cache_firebase = json.load(f)
    for image_path_cached, firebase_url in cache_firebase.items():
        if image_path_cached == image_path:
            return firebase_url
    return None

def image_inditex_cached(firebase_url):
    # if the cache file does not exist, create one with '{}' as content
    if not os.path.exists('caches/inditex_cache.json'):
        with open('caches/inditex_cache.json', 'w') as f:
            f.write('{}')
    with open('caches/inditex_cache.json', 'rb') as f:
        cache_inditex = json.load(f)
    for firebase_url_cached, json_response in cache_inditex.items():
        if firebase_url_cached == firebase_url:
            return json_response
    return None


##########################################################################################
# Helper functions                                                                       #
##########################################################################################

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


#########################################################################################
# API endpoints                                                                         #
#########################################################################################


# Define the expected structure of the JSON
class Item(BaseModel):
    id: str
    name: str
    price: dict
    link: str
    image_url: str

@app.post("/new-favorite/")
async def create_item(item: Item):
    # FastAPI automatically parses and validates the JSON body into a Pydantic model
    update_favorites(1, item.image_url)
    return {
        "message": "Item received successfully",
        "item": item
    }

@app.get("/favorites/")
async def get_favorites():
    """
    Endpoint to get the list of favorite items.
    Returns a JSON response with the list of items.
    """
    # Read the cache file
    if not os.path.exists('caches/favorites_cache.json'):
        with open('caches/favorites_cache.json', 'w') as f:
            f.write('{}')
    with open('caches/favorites_cache.json', 'r') as f:
        cache_favorites = json.load(f)
    return JSONResponse(content=cache_favorites[1])

@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    """
    Endpoint to receive an uploaded image file.
    Returns products as JSON.
    """

    # PATH -> firebase url
    image_path = f"images/{file.filename}"
    with open(image_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    firebase_url = image_firebase_cached(image_path)
    if firebase_url:
        print("Firebase URL from cache")
    else:
        firebase_url = uploader.upload_image(image_path)
        update_firebase_cache(image_path, firebase_url)

    # firebase url -> json response of inditex api
    json_response = image_inditex_cached(firebase_url)
    if json_response:
        print("Inditex response from cache")
    else:
        json_response = inditex_api.search_product_by_image_url(firebase_url)
        json_response = add_image_url(json_response)
        update_inditex_cache(firebase_url, json_response)

    # Add image URL to the JSON response
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