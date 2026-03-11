
from django.contrib import admin
from .models import ScrapingLog

@admin.register(ScrapingLog)
class ScrapingLogAdmin(admin.ModelAdmin):
    list_display = ('url', 'status', 'results_count', 'created_at') # Les colonnes à afficher
    search_fields = ('url',) # Barre de recherche
    list_filter = ('status', 'created_at') # Filtre par statut et date
