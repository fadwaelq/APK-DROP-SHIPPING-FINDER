import os
from celery import Celery

# On indique à Celery où se trouve le fichier settings de ton projet
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')

# On crée l'application Celery (on lui donne le nom de ton dossier principal)
app = Celery('backend')

# On charge les configurations depuis le settings.py (toutes les variables commençant par CELERY_)
app.config_from_object('django.conf:settings', namespace='CELERY')

# On demande à Celery de chercher automatiquement les fichiers tasks.py dans tes apps (ex: scraper)
app.autodiscover_tasks()