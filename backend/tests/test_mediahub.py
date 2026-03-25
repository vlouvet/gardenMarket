from io import BytesIO

import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from PIL import Image
from rest_framework import status

from gardens.models import GardenerProfile


@pytest.mark.django_db
def test_create_post_and_photo(api_client, gardener_user):
    gardener = GardenerProfile.objects.get(user=gardener_user)
    api_client.force_authenticate(user=gardener_user)

    response = api_client.post(
        "/api/posts/",
        data={"gardener": gardener.id, "text": "Fresh basil"},
        format="json",
    )
    assert response.status_code == status.HTTP_201_CREATED
    post_id = response.data["id"]

    buf = BytesIO()
    Image.new("RGB", (1, 1), color="red").save(buf, format="PNG")
    buf.seek(0)
    image = SimpleUploadedFile("test.png", buf.read(), content_type="image/png")
    response = api_client.post(
        "/api/photos/", data={"post": post_id, "image": image}, format="multipart"
    )
    assert response.status_code == status.HTTP_201_CREATED, response.data
