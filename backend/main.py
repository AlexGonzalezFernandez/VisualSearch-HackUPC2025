# main.py (FastAPI server)
from typing import Optional

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
def add_favorite(image_url, web_url, price, name):
    print("adding favorite")
    # if the cache file does not exist, create one with '{}' as content
    if not os.path.exists('caches/favorites_cache.json'):
        with open('caches/favorites_cache.json', 'w') as f:
            f.write('[]')
    with open('caches/favorites_cache.json', 'r') as f:
        cache_favorites = json.load(f)

    print("Cache before adding favorite", cache_favorites)

    dict_favorite = {
        "image_url": image_url,
        "web_url": web_url,
        "price": price,
        "name": name
    }
    if not dict_favorite in cache_favorites:
        cache_favorites.append(dict_favorite)
    with open('caches/favorites_cache.json', 'w') as f:
        json.dump(cache_favorites, f, indent=4)

    print("Cache after adding favorite", cache_favorites)


def remove_favorite(image_url, web_url, price, name):
    print("removing favorite")
    # if the cache file does not exist, create one with '{}' as content
    with open('caches/favorites_cache.json', 'r') as f:
        cache_favorites = json.load(f)

    print("Cache before removing favorite", cache_favorites)

    dict_favorite = {
        "image_url": image_url,
        "web_url": web_url,
        "price": price,
        "name": name
    }
    print("dict_favorite", dict_favorite)
    if dict_favorite in cache_favorites:
        print("dict_favorite exists")
    else:
        print("dict_favorite does not exist")
    cache_favorites.remove(dict_favorite)
    with open('caches/favorites_cache.json', 'w') as f:
        json.dump(cache_favorites, f, indent=4)

    print("Cache after adding favorite", cache_favorites)



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
    for i, item in enumerate(json_response):
        web_url = item['link']
        cached_image = image_scrapped_cached(web_url)
        if cached_image:
            item['image_url'] = cached_image
            print("Scrapped image from cache")
        else:
            print("Getting image URL by scrapping")
            scrapper = InditexScraper(api_key=get_scrapper_key())
            response = scrapper.scrape_image(name=item['name'], link=item['link'])
            print("Scrapper response:", response)
            if 'error' in response:
                print("Error in scrapper response:", response['error'])
                item['image_url'] = "https://storage.googleapis.com/visualsearchhackupc.firebasestorage.app/images/35.jpg"
            else:
                item['image_url'] = response['image_url']
                update_scrapping_cache(web_url, response['image_url'])
        print("Finished", i, "of", len(json_response)-1)
    return json_response

def firebase_url_to_api_response(firebase_url):
    json_response = image_inditex_cached(firebase_url)
    if json_response:
        print("Inditex response from cache")
    else:
        print("Obtaining Inditex response")
        json_response = inditex_api.search_product_by_image_url(firebase_url)
        json_response = add_image_url(json_response)
        update_inditex_cache(firebase_url, json_response)
    print("Inditex response:", json_response)
    return json_response

def path_to_firebase_url(file):
    image_path = f"images/{file.filename}"
    with open(image_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    firebase_url = image_firebase_cached(image_path)
    if firebase_url:
        print("Firebase URL from cache")
    else:
        print("Obtaining Firebase URL")
        firebase_url = uploader.upload_image(image_path)
        update_firebase_cache(image_path, firebase_url)
    print("Firebase URL:", firebase_url)
    return firebase_url


#########################################################################################
# API endpoints                                                                         #
#########################################################################################


class PriceValue(BaseModel):
    current: float
    original: Optional[float] = None

class Price(BaseModel):
    currency: str
    value: PriceValue

class Item(BaseModel):
    name: str
    link: str
    image_url: str
    price: Price

@app.post("/new-favorite/")
async def create_item(item: Item):
    print("Received item:", item)
    # FastAPI automatically parses and validates the JSON body into a Pydantic model
    price = {
        "currency": item.price.currency,
        "value": {
            "current": item.price.value.current,
            "original": item.price.value.original
        }
    }
    add_favorite(item.image_url, item.link, price, item.name)
    return {
        "message": "Item received successfully",
        "item": item
    }

@app.post("/delete-favorite/")
async def delete_item(item: Item):
    print("Received item:", item)
    # FastAPI automatically parses and validates the JSON body into a Pydantic model
    price = {
        "currency": item.price.currency,
        "value": {
            "current": item.price.value.current,
            "original": item.price.value.original
        }
    }
    remove_favorite(item.image_url, item.link, price, item.name)
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
    # Change the key 'web_url' name to 'link' name
    for i, item in enumerate(cache_favorites):
        item['link'] = item.pop('web_url')
    return JSONResponse(content=cache_favorites)

@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    """
    Endpoint to receive an uploaded image file.
    Returns products as JSON.
    """

    # PATH -> firebase url
    firebase_url = path_to_firebase_url(file)

    # firebase url -> json response of inditex api
    api_response = firebase_url_to_api_response(firebase_url)

    # Add image URL to the JSON response
    json_response = add_image_url(api_response)
    return JSONResponse(content=json_response)