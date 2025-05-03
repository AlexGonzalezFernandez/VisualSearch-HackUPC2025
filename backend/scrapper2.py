import requests
from bs4 import BeautifulSoup
import json

def get_scrapper_key():
    """
    Reads the Scraper API key from a file.
    """
    try:
        with open('config/scraper_key.txt', 'r') as file:
            return file.read().strip()
    except FileNotFoundError:
        raise Exception("Scraper API key file not found. Please create 'config/scraper_key.txt' with your API key.")

class InditexScraper:
    def __init__(self, api_key):
        self.api_key = api_key
        self.base_url = 'https://api.scraperapi.com/'

    def get_modified_link(self, name, link):
        name_slug = name.lower().replace(' ', '-')
        modified_link = link.replace('/en/', f'/en/{name_slug}')
        return modified_link

    def scrape_image(self, name, link):
        try:
            # Generate the modified link
            modified_link = self.get_modified_link(name, link)

            # Prepare the payload for the Scraper API
            payload = {
                'api_key': self.api_key,
                'url': modified_link,
                'render': 'true',
                'retry_404': 'true'
            }

            # Make the request to the Scraper API
            response = requests.get(self.base_url, params=payload)
            response.raise_for_status()  # Raise an exception for HTTP errors

            # Parse the HTML response
            soup = BeautifulSoup(response.text, 'html.parser')
            image_tag = soup.find('img', class_='media-image__image media__wrapper--media')

            # Extract the image URL if available
            image_url = image_tag['src'] if image_tag and 'src' in image_tag.attrs else None

            # Return the result as a dictionary
            return {
                'modified_link': modified_link,
                'image_url': image_url
            }
        except Exception as e:
            # Handle errors and return the error message
            return {
                'modified_link': link,
                'image_url': None,
                'error': str(e)
            }

# Example usage
if __name__ == "__main__":
    # Example JSON input
    json_input = {'name': 'SHORT SLEEVE INTERLOCK T-SHIRT', 'link': 'https://zara.com/es/en/-P04174378.html'}

    # Initialize the scraper
    scraper = InditexScraper(api_key=get_scrapper_key())

    # Scrape the image and modified link
    result = scraper.scrape_image(json_input['name'], json_input['link'])

    # Print the result
    print(json.dumps(result, indent=4))