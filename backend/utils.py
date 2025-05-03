from auth import use_kc_openid

with open('../url.txt', 'r') as file:
    URL_PREFIX = file.read().strip()


def generate_login_url(state: str):
    """Creates the url for the idp."""
    kcopenid = use_kc_openid()
    url = kcopenid.auth_url(
        redirect_uri=f"{URL_PREFIX}/callback",
        scope="openid",
        state=state
        )
    return url