from django.urls import path

from scraper.views.ads import AdsMonitoringAPIView
from .views.search import (
    LiveSearchAPIView, 
    BulkLiveSearchAPIView,
    ScrapeAsyncAPIView,
    BulkScrapeAsyncAPIView, 
    ScrapeStatusAPIView
)

urlpatterns = [
    # API endpoints for live search and scraping
    path('search/', LiveSearchAPIView.as_view(), name='live-search'),
    # API endpoint for bulk live search
    path('bulk-search/', BulkLiveSearchAPIView.as_view(), name='bulk-live-search'),
    # API endpoints for asynchronous scraping with Puppeteer
    path('products/scrape/', ScrapeAsyncAPIView.as_view(), name='scrape-async'),
    # API endpoint for bulk asynchronous scraping with Puppeteer
    path('bulk-scrape-puppeteer/', BulkScrapeAsyncAPIView.as_view(), name='bulk-scrape-async'),
    # API endpoint to check the status of an asynchronous scraping task
    path('scrape-status/<str:task_id>/', ScrapeStatusAPIView.as_view(), name='scrape-status'),
    # API endpoint for ads monitoring
    path('ads/monitoring/', AdsMonitoringAPIView.as_view(), name='ads-monitoring'),
]