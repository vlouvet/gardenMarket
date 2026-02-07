from moderation.models import AdminAuditLog


def log_admin_action(admin_user, action: str, target_type: str = "", target_id: str = "") -> None:
    if not admin_user or not admin_user.is_authenticated:
        return
    AdminAuditLog.objects.create(
        admin_user=admin_user,
        action=action,
        target_type=target_type,
        target_id=str(target_id) if target_id else "",
    )
