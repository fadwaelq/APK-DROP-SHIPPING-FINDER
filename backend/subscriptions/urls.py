from django.urls import path
from .views import PlanListView, CheckoutView, VerifyPaymentView

urlpatterns = [
    path('plans/', PlanListView.as_view(), name='plans-list'),
    path('checkout/', CheckoutView.as_view(), name='checkout'),

    path('webhook/', VerifyPaymentView.as_view(), name='verify-payment'),
]