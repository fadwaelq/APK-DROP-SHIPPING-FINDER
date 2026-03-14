from django.urls import path
from .views import RewardSummaryView, ApplyReferralCodeView

urlpatterns = [
    path('', RewardSummaryView.as_view(), name='reward-summary'),
    path('apply-code/', ApplyReferralCodeView.as_view(), name='apply-code'),
]