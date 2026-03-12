from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

# On demande à Django d'afficher ton CustomUser dans le panel d'administration
admin.site.register(CustomUser, UserAdmin)