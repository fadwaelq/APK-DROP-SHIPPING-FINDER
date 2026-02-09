"""
Test Discovery Scraper
Multiple testing methods: CLI, API, PowerShell
"""

import asyncio
import json
import requests
import sys
from datetime import datetime

# ============================================
# METHOD 1: DIRECT ASYNC TEST
# ============================================

async def test_discovery_async():
    """Test discovery scraper directly (Python async)"""
    print("\n" + "="*70)
    print("TEST 1: DIRECT ASYNC DISCOVERY TEST")
    print("="*70)
    
    try:
        from core.scrapers.discovery_scraper import DiscoveryScraper
        
        scraper = DiscoveryScraper(headless=True)
        await scraper.initialize()
        
        # Test keyword search
        print("\n🔍 Searching for: 'smartwatch'")
        urls = await scraper.discover_by_keyword('smartwatch', pages=1)
        print(f"✅ Found {len(urls)} products")
        print(f"   Sample URLs:")
        for url in urls[:3]:
            print(f"   - {url}")
        
        # Test trending
        print("\n📈 Discovering trending products...")
        trending = await scraper.discover_trending(pages=1)
        print(f"✅ Found {len(trending)} trending products")
        
        # Test full discovery
        print("\n🎯 Full discovery (multiple keywords)...")
        all_products = await scraper.discover_all(
            keywords=['smartwatch', 'power bank'],
            pages=1
        )
        print(f"✅ Total discovered: {len(all_products)} unique products")
        
        await scraper.close()
        
        print("\n✅ ASYNC TEST PASSED\n")
        return True
        
    except Exception as e:
        print(f"\n❌ ASYNC TEST FAILED: {e}\n")
        import traceback
        traceback.print_exc()
        return False


# ============================================
# METHOD 2: API TEST
# ============================================

def test_discovery_api(base_url="http://localhost:8000/api", token=None):
    """Test discovery via REST API"""
    print("\n" + "="*70)
    print("TEST 2: API ENDPOINT TEST")
    print("="*70)
    
    headers = {
        "Content-Type": "application/json",
    }
    
    if token:
        headers["Authorization"] = f"Bearer {token}"
    
    endpoint = f"{base_url}/products/discovery-scrape/"
    
    test_cases = [
        {
            "name": "Basic Discovery (Default Keywords)",
            "payload": {"pages": 1}
        },
        {
            "name": "Custom Keywords",
            "payload": {
                "keywords": ["smartwatch", "wireless earbuds"],
                "pages": 1
            }
        },
    ]
    
    for test_case in test_cases:
        print(f"\n📌 {test_case['name']}")
        print(f"   Payload: {test_case['payload']}")
        print("-" * 70)
        
        try:
            print("   ⏳ Sending request... (this may take 1-2 minutes)")
            response = requests.post(
                endpoint,
                json=test_case['payload'],
                headers=headers,
                timeout=180  # 3 minute timeout
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"   ✅ Status: {data.get('status')}")
                print(f"   ✅ Discovered: {data.get('discovered_count')} products")
                urls = data.get('urls', [])
                print(f"   ✅ Sample URLs:")
                for url in urls[:3]:
                    print(f"      - {url}")
            else:
                print(f"   ❌ Status Code: {response.status_code}")
                print(f"   Error: {response.text[:200]}")
                
        except requests.exceptions.Timeout:
            print(f"   ⏱️  TIMEOUT: Scraping is running but took longer than 3 minutes")
            print(f"      This is normal - discovery takes time!")
        except requests.exceptions.ConnectionError:
            print(f"   ❌ CONNECTION ERROR: Is Django running on {base_url}?")
            print(f"      Start it with: python manage.py runserver")
        except Exception as e:
            print(f"   ❌ ERROR: {e}")


# ============================================
# METHOD 3: POSTMAN CURL
# ============================================

def get_curl_command(token=None):
    """Get curl command for PowerShell"""
    base_url = "http://localhost:8000/api"
    
    headers_curl = '-H "Content-Type: application/json"'
    if token:
        headers_curl += f' -H "Authorization: Bearer {token}"'
    
    cmd = f'''$headers = @{{
    "Content-Type" = "application/json"
}}

$body = @{{
    "keywords" = @("smartwatch", "power bank")
    "pages" = 1
}} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "{base_url}/products/discovery-scrape/" `
    -Method POST `
    -Headers $headers `
    -Body $body

Write-Host "Status Code: $($response.StatusCode)"
Write-Host "Response: $($response.Content)"
'''
    
    return cmd


# ============================================
# METHOD 4: SYNC TEST (Easy)
# ============================================

def test_discovery_sync():
    """Test using sync wrapper (easiest method)"""
    print("\n" + "="*70)
    print("TEST 3: SYNC WRAPPER TEST (EASIEST)")
    print("="*70)
    
    try:
        from core.scrapers.discovery_scraper import discover_products_sync
        
        print("\n🔍 Discovering products... (this takes 1-2 minutes)")
        print("-" * 70)
        
        result = discover_products_sync(
            keywords=['smartwatch', 'power bank'],
            pages=1
        )
        
        if result['status'] == 'error':
            print(f"❌ Error: {result['error']}")
            return False
        
        print(f"✅ Status: {result['status']}")
        print(f"✅ Discovered: {result['discovered_count']} products")
        print(f"✅ Sample URLs:")
        for url in result['urls'][:5]:
            print(f"   - {url}")
        
        print("\n✅ SYNC TEST PASSED\n")
        return True
        
    except Exception as e:
        print(f"❌ SYNC TEST FAILED: {e}")
        import traceback
        traceback.print_exc()
        return False


# ============================================
# MAIN
# ============================================

if __name__ == "__main__":
    print("""
╔════════════════════════════════════════════════════════════════════════════╗
║                 DISCOVERY SCRAPER - TEST GUIDE                             ║
║                  4 Different Testing Methods                               ║
╚════════════════════════════════════════════════════════════════════════════╝
    """)
    
    if len(sys.argv) > 1:
        cmd = sys.argv[1].lower()
        
        if cmd == "async":
            print("\n📋 METHOD 1: ASYNC TEST")
            print("   Runs discovery directly in Python async")
            asyncio.run(test_discovery_async())
        
        elif cmd == "api":
            print("\n📋 METHOD 2: API TEST")
            print("   Tests via REST API endpoint")
            
            token = None
            if len(sys.argv) > 3 and sys.argv[2] == "--token":
                token = sys.argv[3]
            
            test_discovery_api(token=token)
        
        elif cmd == "sync":
            print("\n📋 METHOD 3: SYNC WRAPPER TEST (RECOMMENDED)")
            print("   Easiest method - synchronous wrapper")
            test_discovery_sync()
        
        elif cmd == "curl":
            print("\n📋 METHOD 4: POWERSHELL CURL")
            print("-" * 70)
            
            token = None
            if len(sys.argv) > 3 and sys.argv[2] == "--token":
                token = sys.argv[3]
            
            print(get_curl_command(token))
        
        else:
            print(f"❌ Unknown command: {cmd}")
            print("\nAvailable commands:")
            print("  python test_discovery_scraper.py async")
            print("  python test_discovery_scraper.py api")
            print("  python test_discovery_scraper.py sync")
            print("  python test_discovery_scraper.py curl")
    
    else:
        print("""
Usage:
  python test_discovery_scraper.py <method>

Methods:
  async   - Test discovery directly (Python async)
  api     - Test via REST API endpoint
  sync    - Test using sync wrapper (EASIEST - RECOMMENDED)
  curl    - Get PowerShell curl command

Examples:
  python test_discovery_scraper.py sync
  python test_discovery_scraper.py api --token YOUR_JWT_TOKEN
  python test_discovery_scraper.py async
  python test_discovery_scraper.py curl

⏱️  Note: Discovery takes 1-2 minutes per keyword

        """)
