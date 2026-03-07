from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

class CustomUserAdmin(UserAdmin):
    # Précise le modèle à utiliser
    model = CustomUser
    
    # Les colonnes qui s'afficheront dans le tableau principal
    list_display = ('email', 'full_name', 'is_verified', 'is_staff', 'is_active', 'otp_code')
    
    # Les champs sur lesquels on peut faire une recherche
    search_fields = ('email', 'full_name')
    
    # L'ordre d'affichage par défaut
    ordering = ('-date_joined',)

    # Configuration de la page de MODIFICATION d'un utilisateur
    fieldsets = (
        ('Identifiants', {'fields': ('email', 'password')}),
        ('Informations Personnelles', {'fields': ('full_name',)}),
        ('Sécurité & OTP', {'fields': ('is_verified', 'otp_code', 'otp_created_at')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Dates', {'fields': ('last_login', 'date_joined')}),
    )

    # Configuration de la page de CRÉATION d'un utilisateur
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'full_name', 'password', 'is_verified', 'is_staff', 'is_superuser')}
        ),
    )

# Enregistre notre modèle avec sa configuration visuelle
admin.site.register(CustomUser, CustomUserAdmin)