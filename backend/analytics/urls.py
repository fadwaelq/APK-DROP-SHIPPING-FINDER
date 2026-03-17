from django.urls import path
# C'EST CETTE LIGNE QUI RÈGLE L'ERREUR :
from .views import ROICalculatorAPIView, DashboardStatsView, RecentActivityView 

urlpatterns = [
    path('calculator/roi/', ROICalculatorAPIView.as_view(), name='roi-calculator'),
    path('dashboard/stats/', DashboardStatsView.as_view(), name='dashboard-stats'),
    path('dashboard/recent-activity/', RecentActivityView.as_view(), name='dashboard-recent-activity'),
]