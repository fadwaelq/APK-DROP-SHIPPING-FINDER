from django.urls import path
from . import views

urlpatterns = [
    path('scrape-product/', views.ScrapeProductView.as_view(), name='scrape-product'),
    path('bulk-scrape/', views.BulkScrapeView.as_view(), name='bulk-scrape'),
]