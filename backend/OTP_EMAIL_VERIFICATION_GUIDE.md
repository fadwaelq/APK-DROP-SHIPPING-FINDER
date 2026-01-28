# Email OTP Verification System - API Documentation

## Overview
The Email OTP Verification system provides secure user registration with email verification using One-Time Passwords (OTP). This ensures that users have valid email addresses before completing registration.

## Authentication
No authentication required for OTP endpoints (open endpoints)

## Base URL
```
http://localhost:8000/api
```

---

## Endpoints

### 1. Send OTP Code
Send an OTP code to user's email for verification during registration.

**Endpoint:** `POST /auth/send-otp/`

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (Success - 200):**
```json
{
  "message": "OTP sent successfully to your email",
  "email": "user@example.com",
  "expires_in": "10 minutes"
}
```

**Response (Error):**
```json
{
  "error": "Email already registered"
}
```

**Error Codes:**
- `400`: Email already registered or invalid email
- `400`: OTP could not be sent

---

### 2. Verify OTP Code
Verify the OTP code sent to user's email.

**Endpoint:** `POST /auth/verify-otp/`

**Request Body:**
```json
{
  "email": "user@example.com",
  "otp_code": "123456"
}
```

**Response (Success - 200):**
```json
{
  "message": "Email verified successfully.",
  "email": "user@example.com",
  "verified": true
}
```

**Response (Error):**
```json
{
  "error": "OTP has expired. Please request a new one."
}
```

**Error Messages:**
- `"OTP has expired"` - OTP is no longer valid (10 minutes expiry)
- `"OTP has already been verified"` - OTP was already used
- `"Too many attempts"` - More than 5 failed attempts
- `"Invalid OTP code"` - Wrong OTP code

---

### 3. Resend OTP Code
Resend OTP code if the user didn't receive it or it expired.

**Endpoint:** `POST /auth/resend-otp/`

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (Success - 200):**
```json
{
  "message": "OTP resent successfully.",
  "email": "user@example.com",
  "expires_in": "10 minutes"
}
```

**Response (Error):**
```json
{
  "error": "OTP has expired. Please register again."
}
```

---

### 4. Register with OTP
Register a new user after email verification with OTP.

**Endpoint:** `POST /auth/register-with-otp/`

**Request Body:**
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "password_confirm": "SecurePass123!",
  "first_name": "John",
  "last_name": "Doe",
  "otp_code": "123456"
}
```

**Response (Success - 201):**
```json
{
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "name": "John Doe"
  },
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "message": "Registration successful!"
}
```

**Response (Error):**
```json
{
  "password": ["Passwords do not match"],
  "otp_code": ["Please verify your OTP first"]
}
```

**Validations:**
- Username must be unique
- Email must be valid and verified with OTP
- Passwords must match
- OTP must be verified before registration

---

## Complete Registration Flow

### Step 1: Send OTP
```bash
curl -X POST http://localhost:8000/api/auth/send-otp/ \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com"}'
```

### Step 2: User receives OTP in email (e.g., 123456)

### Step 3: Verify OTP
```bash
curl -X POST http://localhost:8000/api/auth/verify-otp/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "otp_code": "123456"
  }'
```

### Step 4: Register with verified OTP
```bash
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
```

### Step 5: Use the returned token for authenticated requests
```bash
curl -X GET http://localhost:8000/api/users/me/ \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

---

## Configuration

### Email Backend Settings (.env file)
```env
# Email Configuration
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=noreply@dropshippingfinder.com
```

### For Development (Console Backend)
To test OTP without sending real emails, use console backend:
```env
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
```
This will print emails to console instead.

### Gmail Setup
1. Enable 2-Factor Authentication on your Gmail account
2. Generate an App Password at https://myaccount.google.com/apppasswords
3. Use the app password in `EMAIL_HOST_PASSWORD`

---

## Security Features

1. **OTP Expiration**: OTP codes expire after 10 minutes
2. **Attempt Limit**: Maximum 5 failed verification attempts
3. **Rate Limiting**: Users can resend OTP multiple times (recommended: implement rate limiting)
4. **Email Validation**: Email must not be already registered
5. **Verified Flag**: Email must be verified before registration completion

---

## Error Handling

### Common Errors

| Status | Error | Cause |
|--------|-------|-------|
| 400 | Email already registered | Trying to send OTP to registered email |
| 400 | Invalid OTP code | Wrong OTP provided or doesn't exist |
| 400 | OTP has expired | OTP older than 10 minutes |
| 400 | Too many attempts | More than 5 failed attempts |
| 400 | Passwords do not match | password != password_confirm |
| 400 | Please verify your OTP first | Trying to register without verifying OTP |

---

## Testing with Postman

A Postman collection for OTP endpoints is available. Import the provided JSON file and set variables:
- `base_url`: http://localhost:8000/api
- `test_email`: your-test-email@example.com

---

## Database Models

### EmailOTP Model
```python
class EmailOTP(models.Model):
    user = OneToOneField(User)  # Optional, populated after registration
    email = EmailField()  # Target email for verification
    otp_code = CharField(max_length=6)  # 6-digit OTP
    is_verified = BooleanField()  # Verification status
    attempts = IntegerField()  # Failed attempt counter
    created_at = DateTimeField()  # Creation timestamp
    expires_at = DateTimeField()  # Expiration time
    verified_at = DateTimeField()  # Verification timestamp
```

---

## Email Template

The OTP email is formatted as HTML with:
- Clear header and instructions
- Highlighted OTP code (32pt, bold)
- Expiration time notice
- Professional footer

---

## Next Steps

1. Configure email backend in `.env`
2. Run migrations: `python manage.py migrate`
3. Test endpoints using provided Postman collection
4. Implement rate limiting for resend endpoint
5. Add email template customization
6. Implement OTP history/audit logging

