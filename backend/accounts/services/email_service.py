from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.conf import settings


def send_otp_email(user, otp, template_name, subject):
    html_content = render_to_string(template_name, {
        "username": user.username,
        "otp": otp
    })

    email = EmailMultiAlternatives(
        subject=subject,
        body=f"Votre code OTP est : {otp}",
        from_email=settings.DEFAULT_FROM_EMAIL,
        to=[user.email],
    )

    email.attach_alternative(html_content, "text/html")
    email.send()