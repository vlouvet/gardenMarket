from rest_framework import permissions


class IsOwnerGardener(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.gardener.user_id == request.user.id
