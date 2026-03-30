from rest_framework.permissions import BasePermission

class IsProUser(BasePermission):
    message = "Upgrade to PRO to access this feature"

    def has_permission(self, request, view):
        user = request.user

        if not user.is_authenticated:
            return False

        if not hasattr(user, 'subscription'):
            return False

        return user.subscription.plan != 'FREE'