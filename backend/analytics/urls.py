from django.urls import path
from .views import ROICalculatorAPIView

urlpatterns = [
    path('calculator/roi/', ROICalculatorAPIView.as_view(), name='roi-calculator'),
]