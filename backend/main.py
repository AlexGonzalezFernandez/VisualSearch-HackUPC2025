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