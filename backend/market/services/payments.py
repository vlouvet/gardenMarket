from django.conf import settings
import stripe

stripe.api_key = getattr(settings, "STRIPE_SECRET_KEY", "")


def create_payment_intent(amount_cents: int, currency: str, metadata: dict):
    return stripe.PaymentIntent.create(
        amount=amount_cents,
        currency=currency,
        metadata=metadata,
    )


def construct_webhook_event(payload: bytes, sig_header: str):
    return stripe.Webhook.construct_event(
        payload=payload,
        sig_header=sig_header,
        secret=getattr(settings, "STRIPE_WEBHOOK_SECRET", ""),
    )


def create_refund(payment_intent_id: str):
    return stripe.Refund.create(payment_intent=payment_intent_id)
