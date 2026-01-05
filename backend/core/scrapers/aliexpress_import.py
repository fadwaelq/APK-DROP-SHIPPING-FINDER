import requests
from bs4 import BeautifulSoup

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

        response = requests.get(url, headers=headers)
        if response.status_code != 200:
            return None

        soup = BeautifulSoup(response.text, "lxml")

        # TITLE
        title = soup.find("h1")
        title = title.get_text(strip=True) if title else "No title found"

        # PRICE (plusieurs structures possibles)
        price = None
        for cls in ["product-price-value", "uniform-banner-box-price", "product-price-current"]:
            tag = soup.find(class_=cls)
            if tag:
                price = tag.get_text(strip=True)
                break

        # IMAGES
        images = []
        for img in soup.find_all("img"):
            src = img.get("src")
            if src and "jpg" in src and src not in images:
                images.append(src)

        return {
            "title": title,
            "price": price,
            "images": images[:5],
            "url": url
        }

    except Exception as e:
        print(f"Scraping error: {e}")
        return None
