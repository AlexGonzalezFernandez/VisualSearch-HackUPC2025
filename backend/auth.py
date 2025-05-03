from backend.config import *
import json
from keycloak import KeycloakOpenID

# Load Keycloak configuration from JSON file
with open('config/marc_config.json', 'r') as config_file:
    config = json.load(config_file)

KEYCLOAK_SERVER_URL = config.get("server_url")
KEYCLOAK_CLIENT_ID = config.get("client_id")
KEYCLOAK_REALM = config.get("realm_name")
KEYCLOAK_CLIENT_SECRET = config.get("client_secret")

def use_kc_openid():
    keycloak_openid = KeycloakOpenID(
        server_url=KEYCLOAK_SERVER_URL,
        client_id=KEYCLOAK_CLIENT_ID,
        realm_name=KEYCLOAK_REALM,
        client_secret_key=KEYCLOAK_CLIENT_SECRET,
    )
    return keycloak_openid

def get_keycloak_tokens(code, realm, client_id, secret, redirect_uri):
    # Example implementation to use the parameters
    keycloak_openid = use_kc_openid()
    token_data = keycloak_openid.token(grant_type="authorization_code", code=code, redirect_uri=redirect_uri)
    refresh_token=token_data.get("refresh_token")
    access_token = token_data.get("access_token")
    # ID token is also verified in the decode_token method
    id_decoded = keycloak_openid.decode_token(token_data.get("id_token"))

    return {
        "access_token": access_token,
        "id_token": id_decoded,
        "refresh_token":refresh_token,
    }