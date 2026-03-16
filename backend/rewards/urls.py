from django.urls import path
from .views import (
    RewardSummaryView, 
    ApplyReferralCodeView,
    DailyMissionsView, 
    WeeklyMissionsView, 
    CompleteMissionView,
    UserXPView, 
    UserLevelView, 
    AddXPView
)

urlpatterns = [
    # Parrainage et Résumé global
    path('', RewardSummaryView.as_view(), name='reward-summary'),
    path('apply-code/', ApplyReferralCodeView.as_view(), name='apply-code'),
    
    # Missions
    path('missions/daily/', DailyMissionsView.as_view(), name='missions-daily'),
    path('missions/weekly/', WeeklyMissionsView.as_view(), name='missions-weekly'),
    path('missions/<int:mission_id>/complete/', CompleteMissionView.as_view(), name='mission-complete'),
    
    # XP & Niveaux
    path('user/xp/', UserXPView.as_view(), name='user-xp'),
    path('user/level/', UserLevelView.as_view(), name='user-level'),
    path('user/xp/add/', AddXPView.as_view(), name='user-xp-add'),
]