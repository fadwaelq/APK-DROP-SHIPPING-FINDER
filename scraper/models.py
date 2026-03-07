from django.db import models
from django.conf import settings

class ScrapingLog(models.Model):
    url = models.URLField(max_length=500)
    status = models.CharField(max_length=20, default='pending') # pending, success, failed
    results_count = models.IntegerField(default=0)
    error_message = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.url} - {self.status}"