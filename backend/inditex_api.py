import requests
import json
import os

from requests.auth import HTTPBasicAuth


def request_jwt_token():
    """
    Requests a JWT token from the Inditex API and saves it to a file.
    """
    with open('config/promotion_detail.json', 'r') as f:
        data = json.load(f)

    token_url = data.get('oauth2_accesstoken_url')
    scopes = data.get('scopes')
    client_id = data.get('oauth2_client_id')
    client_secret = data.get('oauth2_secret')
    headers = {
        "User-Agent": "OpenPlatform/1.0",
        "Content-Type": "application/x-www-form-urlencoded"
    }
    data = {
        "grant_type": "client_credentials",
        "scope": scopes
    }

    response = requests.post(
        token_url,
        headers=headers,
        data=data,
        auth=HTTPBasicAuth(client_id, client_secret)
    )

    if response.status_code == 200:
        with open('config/token.json', 'w') as f:
            json.dump(response.json(), f)
    else:
        raise Exception(f"Failed to get JWT token ({response.status_code}): {response.text}")

def get_jwt_token():
    if not os.path.exists('config/token.json'):
        request_jwt_token()

    with open('config/token.json', 'r') as f:
        data = json.load(f)

    return data.get("id_token")

class InditexVisualSearchAPI:
    def __init__(self):
        self.jwt_token = get_jwt_token()
        self.base_url = "https://api.inditex.com/pubvsearch"

        self.headers = {
            "Authorization": f"Bearer {self.jwt_token}",
            "Content-Type": "application/json",
            "User-Agent": "OpenPlatform/1.0"
        }

    def search_product_by_image_url(self, image_url: str) -> dict:
        """
        Calls the Inditex Visual Search API with an image URL and returns the response JSON.
        """
        endpoint = f"{self.base_url}/products"
        params = {"image": image_url}

        response = requests.get(endpoint, headers=self.headers, params=params)

        if response.status_code == 200:
            return response.json()
        elif response.status_code == 401:
            os.remove("config/token.json")
            request_jwt_token()
            self.headers = {
                "Authorization": f"Bearer {get_jwt_token()}",
                "Content-Type": "application/json",
                "User-Agent": "OpenPlatform/1.0"
            }
            response = requests.get(endpoint, headers=self.headers, params=params)
            return response.json()
        else:
            raise Exception(f"API call failed ({response.status_code}): {response.text}")