import url_image_uploader

cred_path = '../config/visualsearchhackupc-firebase-adminsdk-fbsvc-9483e6d9c2.json'
bucket_name = 'visualsearchhackupc.firebasestorage.app'  # Corrected bucket name, without gs://
image_path = 'images/test.jpg'

try:
    storage_manager = url_image_uploader.FirebaseStorageManager(cred_path, bucket_name)
    image_url = storage_manager.upload_image(image_path)
    
    print(f"Image URL: {image_url}")
except Exception as e:
    print(f"Error uploading image: {e}")
    print(f"Exception details: {e}")