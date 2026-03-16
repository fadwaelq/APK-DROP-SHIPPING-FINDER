from django.contrib import admin
from .models import Post, Event, EventRegistration, PostLike
# Register your models here.
admin.site.register(Post, admin.ModelAdmin)  # Affiche les champs de Post dans le panel d'administration
admin.site.register(Event, admin.ModelAdmin)  # Affiche les champs de Event dans le panel d'administration
admin.site.register(EventRegistration, admin.ModelAdmin)  # Affiche les champs de EventRegistration dans le panel d'administration
admin.site.register(PostLike, admin.ModelAdmin)  # Affiche les champs de PostLike dans le panel d'administration