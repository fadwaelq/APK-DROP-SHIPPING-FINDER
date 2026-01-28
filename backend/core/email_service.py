"""Email service for sending OTP and notifications"""
import random
import string
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.conf import settings
from datetime import timedelta
from django.utils import timezone
from .models import EmailOTP
from django.contrib.auth.models import User


def generate_otp(length=6):
    """Generate a random OTP code"""
    return ''.join(random.choices(string.digits, k=length))


def send_otp_email(email, otp_code):
    """Send OTP code via email"""
    subject = 'Your Dropshipping Finder OTP Code'
    
    html_message = f"""
    <html>
        <body style="font-family: Arial, sans-serif;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h2 style="color: #333;">Email Verification</h2>
                <p style="color: #666; font-size: 16px;">
                    Thank you for registering with Dropshipping Finder!
                </p>
                <p style="color: #666; font-size: 16px;">
                    Your verification code is:
                </p>
                <div style="background-color: #f0f0f0; padding: 20px; border-radius: 5px; margin: 20px 0;">
                    <p style="font-size: 32px; font-weight: bold; color: #007bff; letter-spacing: 5px; margin: 0;">
                        {otp_code}
                    </p>
                </div>
                <p style="color: #666; font-size: 14px;">
                    This code will expire in 10 minutes.
                </p>
                <p style="color: #666; font-size: 14px;">
                    If you didn't request this code, please ignore this email.
                </p>
                <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
                <p style="color: #999; font-size: 12px;">
                    Dropshipping Finder Team
                </p>
            </div>
        </body>
    </html>
    """
    
    plain_message = strip_tags(html_message)
    
    try:
        send_mail(
            subject=subject,
            message=plain_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[email],
            html_message=html_message,
            fail_silently=False,
        )
        return True
    except Exception as e:
        print(f"Error sending email to {email}: {str(e)}")
        return False


def create_otp_for_email(email, user=None):
    """Create or update OTP for email"""
    otp_code = generate_otp()
    expires_at = timezone.now() + timedelta(minutes=10)
    
    if user:
        # If user exists, update or create OTP
        otp, created = EmailOTP.objects.update_or_create(
            user=user,
            defaults={
                'email': email,
                'otp_code': otp_code,
                'is_verified': False,
                'attempts': 0,
                'expires_at': expires_at,
            }
        )
    else:
        # For new registration, create OTP without user
        otp = EmailOTP.objects.create(
            email=email,
            otp_code=otp_code,
            expires_at=expires_at,
        )
    
    # Send OTP email
    send_otp_email(email, otp_code)
    
    return otp


def verify_otp(email, otp_code):
    """Verify OTP code for email"""
    try:
        otp = EmailOTP.objects.get(email=email, otp_code=otp_code)
        
        # Check if OTP is expired
        if otp.is_expired:
            return {'success': False, 'error': 'OTP has expired. Please request a new one.'}
        
        # Check if already verified
        if otp.is_verified:
            return {'success': False, 'error': 'OTP has already been verified.'}
        
        # Check attempts (max 5 attempts)
        if otp.attempts >= 5:
            return {'success': False, 'error': 'Too many attempts. Please request a new OTP.'}
        
        # Verify OTP
        otp.is_verified = True
        otp.verified_at = timezone.now()
        otp.save()
        
        return {'success': True, 'message': 'Email verified successfully.'}
        
    except EmailOTP.DoesNotExist:
        # Increment attempts
        try:
            otp = EmailOTP.objects.get(email=email)
            otp.attempts += 1
            otp.save()
        except EmailOTP.DoesNotExist:
            pass
        
        return {'success': False, 'error': 'Invalid OTP code.'}


def resend_otp(email):
    """Resend OTP code to email"""
    try:
        otp = EmailOTP.objects.get(email=email, is_verified=False)
        
        # Check if not expired yet
        if not otp.is_expired:
            # Generate new OTP
            otp.otp_code = generate_otp()
            otp.expires_at = timezone.now() + timedelta(minutes=10)
            otp.attempts = 0
            otp.save()
            
            # Send email
            send_otp_email(email, otp.otp_code)
            return {'success': True, 'message': 'OTP resent successfully.'}
        else:
            return {'success': False, 'error': 'OTP has expired. Please register again.'}
    except EmailOTP.DoesNotExist:
        return {'success': False, 'error': 'No OTP found for this email.'}
