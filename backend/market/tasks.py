from celery import shared_task

from market.models import Order
from market.services.notifications import send_order_notification


@shared_task
def send_pickup_reminder(order_id: int) -> bool:
    order = Order.objects.filter(id=order_id).first()
    if not order:
        return False
    send_order_notification(
        order.user.email,
        "Pickup reminder",
        f"Reminder: Order #{order.id} pickup window {order.pickup_window}",
    )
    return True
