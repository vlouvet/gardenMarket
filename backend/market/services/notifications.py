from django.conf import settings
from django.core.mail import send_mail


def send_order_notification(email: str, subject: str, message: str) -> None:
    if not email:
        return
    send_mail(
        subject,
        message,
        getattr(settings, "DEFAULT_FROM_EMAIL", "no-reply@gardenmarket.local"),
        [email],
        fail_silently=True,
    )


def send_sms_notification(_phone: str, _message: str) -> None:
    # Placeholder for SMS integrations (Twilio, etc.).
    return
