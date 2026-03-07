"""
Configuration for AliExpress scraper.

IMPORTANT: AliExpress has aggressive anti-bot measures.
Without residential proxies, scraping will be blocked.

Recommended Proxy Providers (2026):
- BrightData (formerly Luminati): https://brightdata.com
- Oxylabs: https://oxylabs.io
- SmartProxy: https://smartproxy.com
- IPRoyal: https://iproyal.com

Proxy format: http://username:password@proxy-host:port
"""

import os
from typing import List, Optional

# =============================================================================
# Proxy Configuration
# =============================================================================

# Single proxy (for testing)
# Format: "http://user:pass@host:port" or "socks5://user:pass@host:port"
PROXY_URL: Optional[str] = os.environ.get("ALIEXPRESS_PROXY_URL", None)

# Rotating proxy list (for production)
PROXY_LIST: List[str] = [
    # Add your proxies here or load from environment/file
    # "http://user:pass@proxy1.example.com:8080",
    # "http://user:pass@proxy2.example.com:8080",
]

# Load proxies from environment variable (comma-separated)
if os.environ.get("ALIEXPRESS_PROXY_LIST"):
    PROXY_LIST = os.environ.get("ALIEXPRESS_PROXY_LIST", "").split(",")


# =============================================================================
# Scraping Configuration
# =============================================================================

# Maximum pages to scrape per request
MAX_PAGES = 10

# Delay between requests (seconds)
MIN_DELAY = 3
MAX_DELAY = 8

# Request timeout (seconds)
REQUEST_TIMEOUT = 30000

# Enable demo/mock mode (returns sample data without making requests)
# Useful for development and testing
DEMO_MODE = os.environ.get("ALIEXPRESS_DEMO_MODE", "false").lower() == "true"


# =============================================================================
# Browser Configuration
# =============================================================================

# Use headless browser
HEADLESS = True

# Use Firefox (sometimes better for anti-detection)
USE_FIREFOX = False

# Save debug screenshots
DEBUG_SCREENSHOTS = False
