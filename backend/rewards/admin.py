from django.contrib import admin
from .models import RewardProfile, Referral
# Register your models here.

admin.site.register(RewardProfile, admin.ModelAdmin)
admin.site.register(Referral, admin.ModelAdmin)
