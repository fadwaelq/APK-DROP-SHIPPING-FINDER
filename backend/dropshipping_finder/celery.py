"""
Celery configuration for background tasks
"""
import os
from celery import Celery
from celery.schedules import crontab

# Set default Django settings
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dropshipping_finder.settings')

app = Celery('dropshipping_finder')

# Load config from Django settings
app.config_from_object('django.conf:settings', namespace='CELERY')

# Auto-discover tasks from all installed apps
app.autodiscover_tasks()

# Periodic tasks schedule
app.conf.beat_schedule = {
    'scrape-aliexpress-daily': {
        'task': 'core.tasks.scrape_aliexpress_products',
        'schedule': crontab(hour=2, minute=0),  # Run at 2 AM daily
    },
    'update-product-scores-hourly': {
        'task': 'core.tasks.update_product_scores',
        'schedule': crontab(minute=0),  # Run every hour
    },
    'detect-trending-products': {
        'task': 'core.tasks.detect_trending_products',
        'schedule': crontab(hour='*/6'),  # Run every 6 hours
    },
    'send-trend-alerts': {
        'task': 'core.tasks.send_trend_alerts',
        'schedule': crontab(hour=9, minute=0),  # Run at 9 AM daily
    },
}

@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')
