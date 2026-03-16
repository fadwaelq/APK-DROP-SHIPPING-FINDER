from django.urls import path
from .views import DeletePaymentMethodView, ListPaymentMethodsView, PlanListView, CheckoutView, VerifyPaymentView

urlpatterns = [
    path('plans/', PlanListView.as_view(), name='plans-list'),
    path('checkout/', CheckoutView.as_view(), name='checkout'),

    path('webhook/', VerifyPaymentView.as_view(), name='verify-payment'),

    # Cartes bancaires
    path('cards/', ListPaymentMethodsView.as_view(), name='list-cards'),
    path('cards/<int:pk>/', DeletePaymentMethodView.as_view(), name='delete-card'),
]