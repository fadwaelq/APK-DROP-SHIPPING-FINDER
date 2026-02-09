# 📊 AliExpress to CSV Scraper - Complete Guide

## 🚀 Quick Start

### Install Dependencies (one-time)
```bash
cd backend
pip install beautifulsoup4 lxml requests urllib3
```

### Scrape and Export to CSV

**Windows GUI (Easiest)**
```bash
scrape_to_csv.bat
# Then follow the interactive menu
```

**Command Line**
```bash
# Basic (smartwatch, 1 page)
python scrape_to_csv.py --query "smartwatch"

# With multiple pages
python scrape_to_csv.py --query "smartwatch" --pages 3

# Custom output filename
python scrape_to_csv.py --query "wireless earbuds" --output earbuds.csv

# Everything customized
python scrape_to_csv.py --query "phone case" --pages 2 --output sales/products.csv --limit 50
```

---

## 📋 CSV Columns Explained

| Column | Description | Example |
|--------|-------------|---------|
| **Product ID** | AliExpress product ID | 1005008365025184 |
| **Title** | Product name | Wireless Earbuds Bluetooth 5.3 |
| **Price ($)** | Current price | 12.99 |
| **Original Price ($)** | Regular price | 39.99 |
| **Savings (%)** | Discount percentage | 68 |
| **Rating (★)** | Customer rating | 4.7 |
| **Reviews** | Number of reviews | 2543 |
| **Orders** | Number of orders/sales | 8234 |
| **Category** | Auto-detected category | Electronics |
| **URL** | Product link | https://www.aliexpress.com/item/... |
| **Image URL** | Product image | https://ae-pic-a.aliexpress-svc.com/... |
| **Search Keyword** | What you searched for | smartwatch |
| **Scraped Date** | When it was scraped | 2026-02-05 14:30:45 |
| **Profit Margin (%)** | Estimated profit | 70 |

---

## 📊 Usage Examples

### Example 1: Scrape Smartwatches
```bash
python scrape_to_csv.py --query "smartwatch" --pages 2 --output smartwatches.csv
```

**Output**: `smartwatches.csv` with 30-50 products

### Example 2: Scrape for Business
```bash
python scrape_to_csv.py --query "wireless earbuds" --pages 5 --output inventory/earbuds.csv --limit 100
```

**Output**: `inventory/earbuds.csv` with up to 100 products

### Example 3: Daily Scraping
```bash
# Smartwatch products
python scrape_to_csv.py --query "smartwatch" --pages 2 --output data/smartwatch_%date%.csv

# Earbuds products
python scrape_to_csv.py --query "wireless earbuds" --pages 2 --output data/earbuds_%date%.csv

# Phone cases
python scrape_to_csv.py --query "phone case" --pages 2 --output data/phones_%date%.csv
```

---

## 💻 Command-line Options

```
--query TEXT        Search keyword (REQUIRED)
--pages INT        Number of pages (default: 1)
--limit INT        Product limit (default: 100)
--output TEXT      Output CSV filename (default: auto-generated)
--timeout INT      Request timeout (default: 15s)
--retries INT      Number of retries (default: 3)
```

### Parameter Details

**--query** (Required)
- What to search for
- Examples: "smartwatch", "wireless earbuds", "phone case"

**--pages**
- Number of search pages to scrape
- 1 page ≈ 20-30 products
- Higher = more products but slower

**--limit**
- Stop after finding this many products
- Useful to avoid scraping too much

**--output**
- Filename for CSV export
- Can include path: `sales/products.csv`
- Default: `aliexpress_products_YYYYMMDD_HHMMSS.csv`

---

## 📂 Output Files

All CSV files are saved in the backend folder by default:

```
backend/
├── aliexpress_products_20260205_143045.csv
├── smartwatches.csv
├── earbuds.csv
└── sales/
    └── products.csv
```

---

## 🎯 Practical Use Cases

### Use Case 1: Market Research
```bash
python scrape_to_csv.py --query "smartwatch" --pages 3 --output market_research.csv
# Open in Excel → Analyze pricing, competition, ratings
```

### Use Case 2: Product Sourcing
```bash
python scrape_to_csv.py --query "phone case" --pages 5 --output suppliers.csv
# Find best suppliers based on price and ratings
```

### Use Case 3: Dropshipping Inventory
```bash
python scrape_to_csv.py --query "electronics" --pages 10 --output inventory.csv
# Add products to your store from CSV
```

### Use Case 4: Competitor Analysis
```bash
python scrape_to_csv.py --query "smartwatch" --pages 2 --output competitors.csv
python scrape_to_csv.py --query "smart bracelet" --pages 2 --output competitors.csv
# Compare with your products
```

---

## 📈 Opening CSV Files

### Option 1: Microsoft Excel
1. Open Excel
2. File → Open
3. Select CSV file
4. Click Open

### Option 2: Google Sheets
1. Go to [sheets.google.com](https://sheets.google.com)
2. New → Upload file
3. Select CSV file
4. Open in Sheets

### Option 3: Text Editor
- Right-click → Open With → Notepad/VS Code
- Use for quick viewing or editing

### Option 4: Python/Pandas
```python
import pandas as pd

df = pd.read_csv('smartwatches.csv')
print(df)  # View all data
print(df.head(10))  # First 10 rows
print(df.describe())  # Statistics
```

---

## 🔍 Analyzing CSV Data

### In Excel

**Sort by Price**
- Click column header → Data → Sort
- Find cheapest products

**Sort by Rating**
- Find highest-rated products
- Filter by rating >= 4.5 stars

**Sort by Orders**
- Find most popular products
- Best sellers in category

**Create Pivot Table**
- Analyze by category
- Calculate average price
- Count products per seller

### In Python

```python
import pandas as pd

# Load CSV
df = pd.read_csv('smartwatches.csv')

# Most expensive
print(df.nlargest(5, 'Price ($)'))

# Highest rated
print(df.nlargest(5, 'Rating (★)'))

# Best sellers
print(df.nlargest(5, 'Orders'))

# Average price
print(f"Average price: ${df['Price ($)'].astype(float).mean():.2f}")

# By category
print(df['Category'].value_counts())
```

---

## 🔧 Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'bs4'"
**Solution:**
```bash
pip install beautifulsoup4 lxml requests urllib3
```

### Issue: "No products found"
**Solution:**
- Check internet connection
- Try different keyword
- Increase --pages
- Check logs: `type scrape_csv.log`

### Issue: "CSV file is empty"
**Solution:**
- Run again with different keyword
- Check if products were found in logs
- Try increasing --pages

### Issue: "Connection timeout"
**Solution:**
```bash
python scrape_to_csv.py --query "smartwatch" --timeout 30
```

---

## 📝 Example CSV Output

First 5 rows of a real CSV export:

```csv
Product ID,Title,Price ($),Original Price ($),Savings (%),Rating (★),Reviews,Orders,Category,URL,Image URL,Search Keyword,Scraped Date,Profit Margin (%)
1005008365025184,Wireless Earbuds Bluetooth 5.3 TWS,12.99,39.99,68,4.7,2543,8234,Electronics,https://www.aliexpress.com/item/...,https://ae-pic-a.aliexpress-svc.com/...,smartwatch,2026-02-05 14:30:45,70
1005006123456789,Smart Watch Fitness Tracker Heart Rate,24.99,79.99,69,4.5,1876,6543,Electronics,https://www.aliexpress.com/item/...,https://ae-pic-a.aliexpress-svc.com/...,smartwatch,2026-02-05 14:31:12,70
1005004517345890,LED Strip Lights RGB 10M Smart WiFi,15.99,49.99,68,4.8,3421,12456,Home,https://www.aliexpress.com/item/...,https://ae-pic-a.aliexpress-svc.com/...,smartwatch,2026-02-05 14:32:01,70
```

---

## ⚙️ Advanced Usage

### Daily Automation (Windows Task Scheduler)

**Create batch file** `daily_scrape.bat`:
```batch
@echo off
cd C:\path\to\backend
python scrape_to_csv.py --query "smartwatch" --pages 2 --output data\smartwatch_%date%.csv
python scrape_to_csv.py --query "wireless earbuds" --pages 2 --output data\earbuds_%date%.csv
```

**Schedule with Task Scheduler:**
1. Press `Win + R`, type `taskschd.msc`
2. Create Basic Task
3. Set trigger: Daily at 2:00 AM
4. Set action: `daily_scrape.bat`

### Daily Automation (Linux/Mac)

**Add to crontab:**
```bash
crontab -e

# Add this line
0 2 * * * cd /path/to/backend && python scrape_to_csv.py --query "smartwatch" --pages 2 --output data/smartwatch_$(date +\%Y\%m\%d).csv
```

---

## 💡 Best Practices

✅ Start with 1-2 pages for testing
✅ Use descriptive filenames: `smartwatches_2026.csv`
✅ Save to organized folders: `data/`, `sales/`, etc.
✅ Check CSV content before processing
✅ Back up important CSV files
✅ Respect AliExpress terms of service
✅ Space out scraping requests

---

## 📞 Support

**Check Logs:**
```bash
type scrape_csv.log
# or
Get-Content scrape_csv.log -Tail 20
```

**Test Connection:**
```bash
python -c "import requests; print(requests.get('https://www.aliexpress.com').status_code)"
```

---

## 🎉 You're Ready!

Ready to export your first CSV? Run:

```bash
python scrape_to_csv.py --query "smartwatch" --pages 2
```

The CSV file will be created in your backend folder! 📊✨
