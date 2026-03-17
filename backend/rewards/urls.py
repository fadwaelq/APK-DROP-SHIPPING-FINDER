from django.urls import path
from .views import (
    RewardSummaryView, 
    ApplyReferralCodeView,
    ReferralInviteView,    
    UserReferralsView,     
    DailyMissionsView, 
    WeeklyMissionsView, 
    CompleteMissionView,
    UserXPView, 
    UserLevelView, 
    AddXPView,
    UserStreakView,         
    UpdateStreakView,       
    DashboardChartDataView,
    # --- NOUVELLES VUES (Growth & Viralité) ---
    ReferralLeaderboardView,
    ReferralRewardsView,
    ClaimReferralRewardView
)

urlpatterns = [
    # ==========================================
    # PARRAINAGE & GROWTH (Bloc 3)
    # ==========================================
    path('', RewardSummaryView.as_view(), name='reward-summary'),
    path('apply-code/', ApplyReferralCodeView.as_view(), name='apply-code'),
    path('user/referral-invite/', ReferralInviteView.as_view(), name='referral-invite'),
    path('user/referrals/', UserReferralsView.as_view(), name='user-referrals'),
    
    # --- LES 3 NOUVELLES ROUTES ---
    path('user/referral-leaderboard/', ReferralLeaderboardView.as_view(), name='referral-leaderboard'),
    path('user/referral/rewards/', ReferralRewardsView.as_view(), name='referral-rewards'),
    path('user/referral/claim-reward/', ClaimReferralRewardView.as_view(), name='claim-referral-reward'),
    
    # ==========================================
    # MISSIONS (Bloc 2 - P1)
    # ==========================================
    path('missions/daily/', DailyMissionsView.as_view(), name='missions-daily'),
    path('missions/weekly/', WeeklyMissionsView.as_view(), name='missions-weekly'),
    path('missions/<int:mission_id>/complete/', CompleteMissionView.as_view(), name='mission-complete'),
    
    # ==========================================
    # XP & NIVEAUX
    # ==========================================
    path('user/xp/', UserXPView.as_view(), name='user-xp'),
    path('user/level/', UserLevelView.as_view(), name='user-level'),
    path('user/xp/add/', AddXPView.as_view(), name='user-xp-add'),

    # ==========================================
    # DASHBOARD & STREAK (Bloc 2 - Gamification)
    # ==========================================
    path('user/streak/', UserStreakView.as_view(), name='user-streak'),
    path('user/streak/update/', UpdateStreakView.as_view(), name='streak-update'),
    path('user/dashboard/chart-data/', DashboardChartDataView.as_view(), name='dashboard-chart-data'),
]