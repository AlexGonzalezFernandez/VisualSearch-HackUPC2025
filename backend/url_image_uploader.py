import firebase_admin
from firebase_admin import credentials, storage
import uuid

class FirebaseStorageManager:
    def __init__(self, cred_path, bucket_name):
        # Inicializar la aplicación de Firebase con las credenciales
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred, {'storageBucket': bucket_name})
        self.bucket = storage.bucket()

    def upload_image(self, image_path):
        # Crear una referencia al blob en el bucket
        blob = self.bucket.blob(image_path)
        # Subir la imagen al blob
        blob.upload_from_filename(image_path)
        blob.make_public() # Hacer el blob público
        # Obtener la URL pública de la imagen
        image_url = blob.public_url
        return image_url