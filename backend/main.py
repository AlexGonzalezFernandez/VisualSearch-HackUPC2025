# main.py (FastAPI server)
from fastapi import FastAPI, UploadFile, File
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
        "product_name": "Example Jumper",
        "price": "29.99",
        "link": "https://example.com/product/123"
    }
    return JSONResponse(content=dummy_data)