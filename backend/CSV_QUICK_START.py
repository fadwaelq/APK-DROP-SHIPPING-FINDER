#!/usr/bin/env python
"""
📊 CSV SCRAPER QUICK START
==========================

One command to scrape and export to CSV!
"""

print("""
╔════════════════════════════════════════════════════════════════════╗
║            🚀 ALIEXPRESS CSV SCRAPER - QUICK START 🚀             ║
╚════════════════════════════════════════════════════════════════════╝

📊 WHAT THIS DOES:
═══════════════════════════════════════════════════════════════════════

Scrapes products from AliExpress and saves to CSV file with:
✅ Product names
✅ Prices (current & original)
✅ Ratings & reviews
✅ Sales/orders count
✅ Product links
✅ Images
✅ And more...

═══════════════════════════════════════════════════════════════════════

⚡ INSTANT USAGE:
═══════════════════════════════════════════════════════════════════════

1. WINDOWS GUI (Easiest):
   → Double-click: scrape_to_csv.bat
   → Follow prompts

2. COMMAND LINE (Simple):
   → python scrape_to_csv.py --query "smartwatch" --pages 2

3. WINDOWS POWERSHELL (Advanced):
   → python scrape_to_csv.py --query "smartwatch" --pages 3 --output my_file.csv

═══════════════════════════════════════════════════════════════════════

📋 COMMON COMMANDS:
═══════════════════════════════════════════════════════════════════════

# Scrape 1 page (quick test - 30 seconds)
python scrape_to_csv.py --query "smartwatch"

# Scrape 2 pages (3 minutes)
python scrape_to_csv.py --query "smartwatch" --pages 2

# Scrape 5 pages with custom output (10 minutes)
python scrape_to_csv.py --query "wireless earbuds" --pages 5 --output earbuds.csv

# Scrape multiple categories
python scrape_to_csv.py --query "smartwatch" --pages 2 --output smartwatches.csv
python scrape_to_csv.py --query "phone case" --pages 2 --output phones.csv
python scrape_to_csv.py --query "LED light" --pages 2 --output lights.csv

═══════════════════════════════════════════════════════════════════════

📊 CSV FILE EXAMPLE:
═══════════════════════════════════════════════════════════════════════

Your CSV will look like this in Excel:

┌─────────────┬──────────────────────────┬────────┬─────────┬────────┐
│ Product ID  │ Title                    │ Price  │ Rating  │ Orders │
├─────────────┼──────────────────────────┼────────┼─────────┼────────┤
│ 1005008365  │ Wireless Earbuds BT 5.3  │ $12.99 │ 4.7 ★   │ 8234   │
│ 1005006123  │ Smart Watch Fitness      │ $24.99 │ 4.5 ★   │ 6543   │
│ 1005004517  │ LED Strip Lights RGB     │ $15.99 │ 4.8 ★   │ 12456  │
│ ...         │ ...                      │ ...    │ ...     │ ...    │
└─────────────┴──────────────────────────┴────────┴─────────┴────────┘

Plus additional columns:
• Original Price
• Savings %
• Category
• Product URL
• Image URL
• Scraped Date
• Profit Margin %

═══════════════════════════════════════════════════════════════════════

✨ FEATURES:
═══════════════════════════════════════════════════════════════════════

✅ Auto-categorization (Electronics, Fashion, Home, etc.)
✅ Price comparison (original vs current)
✅ Profit calculation (estimated margins)
✅ Real product links (clickable in Excel)
✅ Image URLs (easy thumbnail import)
✅ Timestamp (when scraped)
✅ Anti-detection (won't get blocked)
✅ Error handling (automatic retries)
✅ Progress tracking (see what's happening)

═══════════════════════════════════════════════════════════════════════

🔧 INSTALLATION (One-time):
═══════════════════════════════════════════════════════════════════════

cd backend
pip install beautifulsoup4 lxml requests urllib3

═══════════════════════════════════════════════════════════════════════

📂 OUTPUT LOCATION:
═══════════════════════════════════════════════════════════════════════

CSV files are saved in the backend folder:

C:\\Users\\YassIne\\Desktop\\Stage\\APK-DROPSHIPPING-FINDER\\backend\\
├── aliexpress_products_20260205_143045.csv
├── smartwatches.csv
├── earbuds.csv
└── phones.csv

═══════════════════════════════════════════════════════════════════════

💻 OPENING CSV FILES:
═══════════════════════════════════════════════════════════════════════

Option 1: Excel / LibreOffice Calc
  → Double-click the .csv file
  → Choose CSV format
  → View & analyze data

Option 2: Google Sheets
  → Drive.google.com
  → Upload CSV
  → Analyze in cloud

Option 3: Python / Pandas
  import pandas as pd
  df = pd.read_csv('smartwatches.csv')
  print(df)

═══════════════════════════════════════════════════════════════════════

📈 ANALYSIS IDEAS:
═══════════════════════════════════════════════════════════════════════

1. Find Best Prices
   → Sort by Price column
   → Find cheapest products

2. Check Popularity
   → Sort by Orders
   → See best-sellers

3. Quality Check
   → Sort by Rating
   → Find highest-rated

4. Profit Analysis
   → Check Profit Margin %
   → Find most profitable

5. Competitor Research
   → Compare multiple searches
   → Analyze your competition

═══════════════════════════════════════════════════════════════════════

⚙️ PARAMETERS EXPLAINED:
═══════════════════════════════════════════════════════════════════════

--query "text"
  What to search for
  Examples: "smartwatch", "wireless earbuds", "phone case"

--pages N
  How many pages to scrape
  Default: 1 (≈30 products)
  Increase for more products

--output "filename.csv"
  Name of output file
  Default: auto-generated with timestamp
  Can include path: "sales/products.csv"

--limit N
  Stop after N products
  Default: 100
  Useful to limit scraping

═══════════════════════════════════════════════════════════════════════

🚀 GET STARTED NOW:
═══════════════════════════════════════════════════════════════════════

Choose your method:

METHOD 1 - Windows GUI (Easiest):
  → scrape_to_csv.bat

METHOD 2 - Command Line (Simple):
  → python scrape_to_csv.py --query "smartwatch" --pages 2

METHOD 3 - Save to Custom File:
  → python scrape_to_csv.py --query "smartwatch" --pages 2 --output my_products.csv

═══════════════════════════════════════════════════════════════════════

✅ DONE! Your CSV is ready! 📊

After scraping:
1. Find the .csv file in your backend folder
2. Open with Excel or Google Sheets
3. Analyze and use the data!

═══════════════════════════════════════════════════════════════════════
""")
