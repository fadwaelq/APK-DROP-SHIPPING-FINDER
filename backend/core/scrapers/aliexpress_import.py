import requests
from bs4 import BeautifulSoup
import re
import json

def import_product_from_aliexpress(url: str) -> dict | None:
    """
    Scrape real product data from AliExpress URL
    Returns: {title, price, images, url}
    """
    try:
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                          "(KHTML, like Gecko) Chrome/117 Safari/537.36"
        }

        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code != 200:
            return None

        soup = BeautifulSoup(response.text, "lxml")

        # Extract title from og:title meta tag
        title = "No title found"
        og_title = soup.find("meta", property="og:title")
        if og_title:
            title = og_title.get("content", "No title found")
            # Clean up title if it contains " - AliExpress"
            title = title.split(" - AliExpress")[0] if " - AliExpress" in title else title

        # Extract images from og:image or from imagePathList in script
        images = []
        
        # Try og:image first
        og_image = soup.find("meta", property="og:image")
        if og_image:
            images.append(og_image.get("content"))

        # Try to extract imagePathList from window._d_c_.DCData
        scripts = soup.find_all("script")
        for script in scripts:
            if script.string and "imagePathList" in script.string:
                try:
                    # Find the JSON-like structure
                    match = re.search(r'"imagePathList":\s*\[(.*?)\]', script.string)
                    if match:
                        images_str = "[" + match.group(1) + "]"
                        img_list = json.loads(images_str)
                        images.extend(img_list)
                except:
                    pass

        # Remove duplicates and limit to 5
        images = list(dict.fromkeys(images))[:5]

        # Price extraction (AliExpress typically loads it dynamically, so we'll note this)
        price = None
        # Price is usually loaded via JavaScript, would need Selenium or API
        price_text = soup.find(class_=re.compile(r"price|cost"))
        if price_text:
            price = price_text.get_text(strip=True)

        return {
            "title": title,
            "price": price or "See product page for price",
            "images": images,
            "url": url
        }

    except Exception as e:
        print(f"Scraping error: {e}")
        return None


# Test URL for testing
TEST_URL = "https://www.aliexpress.com/item/1005008365025184.html"

if __name__ == "__main__":
    result = import_product_from_aliexpress(TEST_URL)
    if result:
        print("✓ Product scraped successfully:")
        print(f"  Title: {result['title']}")
        print(f"  Price: {result['price']}")
        print(f"  Images: {len(result['images'])} found")
        if result['images']:
            print(f"  First image: {result['images'][0][:80]}...")
    else:
        print("✗ Failed to scrape product")