# Email OTP Verification - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### 1. Configure Email (Optional)

By default, emails are printed to console. To use real email:

Edit `.env`:
```env
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=noreply@dropshippingfinder.com
```

### 2. Start Django Server

```bash
python manage.py runserver
```

### 3. Test OTP Endpoints

#### Option A: Using cURL

```bash
# 1. Send OTP
curl -X POST http://localhost:8000/api/auth/send-otp/ \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com"}'

# Response:
# {
#   "message": "OTP sent successfully to your email",
#   "email": "user@example.com",
#   "expires_in": "10 minutes"
# }
```

```bash
# 2. Verify OTP (check console for code if using console backend)
curl -X POST http://localhost:8000/api/auth/verify-otp/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "otp_code": "123456"
  }'

# Response:
# {
#   "message": "Email verified successfully.",
#   "email": "user@example.com",
#   "verified": true
# }
```

```bash
# 3. Register with OTP
curl -X POST http://localhost:8000/api/auth/register-with-otp/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "user@example.com",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "first_name": "John",
    "last_name": "Doe",
    "otp_code": "123456"
  }'

# Response:
# {
#   "user": { ... },
#   "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
#   "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
#   "message": "Registration successful!"
# }
```

#### Option B: Using Postman

1. Import `OTP_Postman_Collection.json`
2. Set `test_email` variable
3. Run requests in order:
   - 1. Send OTP Code
   - 2. Verify OTP Code
   - 4. Register with OTP

#### Option C: Using Postman UI

1. Open Postman
2. Create new requests:
   - POST `http://localhost:8000/api/auth/send-otp/`
   - POST `http://localhost:8000/api/auth/verify-otp/`
   - POST `http://localhost:8000/api/auth/register-with-otp/`

---

## 🔍 How to Find OTP Code (Console Backend)

When using console backend, check your terminal:

```
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: Your Dropshipping Finder OTP Code
From: noreply@dropshippingfinder.com
To: user@example.com
Date: Mon, 27 Jan 2026 10:30:00 -0000
Message-ID: <...>

[16:30:45] Body:
Thank you for registering with Dropshipping Finder!

Your verification code is:

===============================
            123456
===============================

This code will expire in 10 minutes.
```

Copy the 6-digit code and use in verify endpoint.

---

## 📋 API Endpoints Reference

```
POST /api/auth/send-otp/
  Body: { "email": "user@example.com" }
  Response: { "message": "...", "email": "...", "expires_in": "10 minutes" }

POST /api/auth/verify-otp/
  Body: { "email": "user@example.com", "otp_code": "123456" }
  Response: { "message": "...", "email": "...", "verified": true }

POST /api/auth/resend-otp/
  Body: { "email": "user@example.com" }
  Response: { "message": "...", "email": "...", "expires_in": "10 minutes" }

POST /api/auth/register-with-otp/
  Body: {
    "username": "johndoe",
    "email": "user@example.com",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "first_name": "John",
    "last_name": "Doe",
    "otp_code": "123456"
  }
  Response: { "user": {...}, "token": "...", "refresh": "...", "message": "..." }
```

---

## ⚠️ Common Issues

### Issue: "Email already registered"
**Solution**: Use a different email address

### Issue: "OTP has expired"
**Solution**: Call `/auth/resend-otp/` to get a new code

### Issue: "Too many attempts"
**Solution**: Resend OTP and try again with new code

### Issue: "Invalid OTP code"
**Solution**: Check the code from email/console, copy exactly

### Issue: "Passwords do not match"
**Solution**: Ensure password and password_confirm are identical

---

## 🎯 Testing Workflow

### Step 1: Send OTP
```
→ POST /auth/send-otp/
← Check console/email for OTP code
```

### Step 2: Verify OTP
```
→ POST /auth/verify-otp/ (with OTP code)
← Should see success message
```

### Step 3: Register
```
→ POST /auth/register-with-otp/ (with same OTP)
← Get JWT tokens
```

### Step 4: Use Tokens
```
→ Use "token" in Authorization header
Authorization: Bearer {token}
```

---

## 📊 Testing with Different Emails

You can test multiple times with different emails:

```bash
# Test 1: user1@example.com
curl ... -d '{"email": "user1@example.com"}'

# Test 2: user2@example.com
curl ... -d '{"email": "user2@example.com"}'

# Test 3: user3@example.com
curl ... -d '{"email": "user3@example.com"}'
```

Each email gets its own OTP code and registration.

---

## 🔐 Production Checklist

Before deploying to production:

- [ ] Configure real email provider (Gmail, SendGrid, etc.)
- [ ] Set strong SECRET_KEY in settings
- [ ] Set DEBUG=False in settings
- [ ] Update ALLOWED_HOSTS
- [ ] Configure database (PostgreSQL recommended)
- [ ] Set secure email credentials in .env
- [ ] Test email sending with production email
- [ ] Set up rate limiting on OTP endpoints
- [ ] Enable HTTPS
- [ ] Set CSRF_TRUSTED_ORIGINS

---

## 📚 Documentation

- **Detailed Guide**: See `OTP_EMAIL_VERIFICATION_GUIDE.md`
- **Implementation Details**: See `OTP_IMPLEMENTATION_SUMMARY.md`
- **Postman Collection**: See `OTP_Postman_Collection.json`

---

## ❓ Need Help?

Check the error response in API response. Common error fields:

```json
{
  "error": "Error description",
  "email": ["Email validation error"],
  "otp_code": ["OTP validation error"]
}
```

---

## ✅ Verify Installation

Run Django check:
```bash
python manage.py check
```

Should see: **System check identified no issues (0 silenced).**

---

## 🚀 You're Ready!

That's it! You now have a complete email OTP verification system.

Start the server and test the endpoints!

