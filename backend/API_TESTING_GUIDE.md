# 🔧 API Testing Guide - Fixed Issues

## ✅ Issues Fixed

### 1. **TypeError: Decimal/float conversion** ✔️
- **Problem**: Scoring engine couldn't multiply Decimal with float
- **Solution**: Convert all numeric values to float in scoring methods
- **Files**: `ai_engine/scoring.py` (all scoring methods)

### 2. **401 Unauthorized Error** ✔️
- **Problem**: Missing or invalid JWT token
- **Solution**: Always authenticate first, then use token in headers

---

## 🚀 Step-by-Step Testing

### Step 1: Login & Get Token
```bash
POST http://localhost:8000/api/auth/login/
Content-Type: application/json

{
  "username": "testuser",
  "password": "testpass123"
}
```

**Response:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {...},
  "profile": {...}
}
```

### Step 2: Copy the Token
Save the `token` value from the response.

### Step 3: Use Token in Requests
```bash
GET http://localhost:8000/api/products/1/analyze/
Authorization: Bearer YOUR_TOKEN_HERE
```

---

## 📋 Headers Required for All Endpoints

```
Authorization: Bearer {token}
Content-Type: application/json
```

---

## 🧪 Test Endpoints (with curl)

### Register
```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "new@example.com",
    "password": "pass123",
    "password_confirm": "pass123",
    "first_name": "New",
    "last_name": "User"
  }'
```

### Login
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "testpass123"
  }'
```

### Analyze Product (with token)
```bash
curl -X GET http://localhost:8000/api/products/1/analyze/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Category Trends
```bash
curl -X GET "http://localhost:8000/api/products/category_trends/?category=tech" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Trending Products
```bash
curl -X GET http://localhost:8000/api/products/trending/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Top Rated Products
```bash
curl -X GET http://localhost:8000/api/products/top_rated/ \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### List Products (filtered)
```bash
curl -X GET "http://localhost:8000/api/products/?category=tech&ordering=-score" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Search Products
```bash
curl -X GET "http://localhost:8000/api/products/?search=watch" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Import Product
```bash
curl -X POST http://localhost:8000/api/products/import/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "url": "https://aliexpress.com/item/1005006123456"
  }'
```

---

## 📊 Postman Quick Setup

1. **Import** `Postman_Collection.json`
2. **Set Variables:**
   - `base_url` = `http://localhost:8000/api`
   - `token` = Your JWT token (after login)
   - `product_id` = `1`
3. **Test** each endpoint

---

## 🔍 Example Response: Product Analysis

```json
{
  "scores": {
    "demand_level": 88,
    "popularity": 82,
    "competition": 70,
    "profitability": 90,
    "trend": 85,
    "overall": 85
  },
  "insights": [
    {
      "type": "positive",
      "title": "Forte demande",
      "message": "Ce produit bénéficie d'une demande élevée sur le marché"
    },
    {
      "type": "positive",
      "title": "Marge importante",
      "message": "Potentiel de profit élevé avec de bonnes marges"
    }
  ],
  "recommendations": [
    "Excellent produit - Lancement recommandé",
    "Analyser la concurrence locale"
  ],
  "risk_level": "low",
  "is_recommended": true
}
```

---

## 🔗 Category Trends Response

```json
{
  "category": "tech",
  "average_score": 80,
  "average_trend": 21.9,
  "total_products": 4,
  "top_products": [
    {
      "score": 85,
      "trend_percentage": 25.5,
      "name": "Smart Watch Pro X",
      "id": 1
    }
  ],
  "is_growing": true,
  "recommendation": "Catégorie en forte croissance - Opportunité excellente"
}
```

---

## 🐛 Troubleshooting

### Error: "401 Unauthorized"
❌ **Cause**: Missing or invalid token
✅ **Fix**: 
1. Login to get a new token
2. Add `Authorization: Bearer {token}` header
3. Ensure token is not expired

### Error: "TypeError: unsupported operand type"
❌ **Cause**: Decimal/float mismatch (FIXED ✔️)
✅ **Fix**: Restart server - changes applied to scoring.py

### Error: "Product not found"
❌ **Cause**: Invalid product ID
✅ **Fix**: Use `GET /api/products/` to list all products and get valid IDs

---

## 📌 Test Data

**Test User:**
```
Username: testuser
Password: testpass123
Email: testuser@test.com
```

**Available Products:**
- ID 1-11 with scores 65-85
- Categories: tech, sport, home, beauty
- 6 trending products

---

## ✅ API Status

✔️ Authentication (Login/Register)
✔️ Product Analysis (AI Scoring)
✔️ Trending Products
✔️ Top Rated Products
✔️ Category Trends
✔️ Product Filtering & Search
✔️ Import Products
✔️ Favorites Management
✔️ Dashboard Statistics

**All endpoints tested and working!** 🚀
