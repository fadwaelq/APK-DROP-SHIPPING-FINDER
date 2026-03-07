from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import Product

# compte super user : admin@test.com
# password : tata1234@
# username : diabate

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('title', 'price', 'created_at') # Les colonnes à afficher
    search_fields = ('title',) # Barre de recherche
    list_filter = ('created_at',) # Filtre par date