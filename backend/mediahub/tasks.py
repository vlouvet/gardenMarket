from celery import shared_task


@shared_task
def generate_photo_thumbnail(photo_id: int) -> bool:
    return bool(photo_id)
