from django.contrib import admin
from .models import Mission, RewardProfile, Referral
# Register your models here.

admin.site.register(RewardProfile, admin.ModelAdmin)
admin.site.register(Referral, admin.ModelAdmin)
admin.site.register(Mission, admin.ModelAdmin)
