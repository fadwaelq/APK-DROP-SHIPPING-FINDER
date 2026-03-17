from django.urls import path
from .views import (
    DeletePaymentMethodView, 
    ListPaymentMethodsView, 
    PlanListView, 
    CheckoutView, 
    VerifyPaymentView,
    CancelSubscriptionView,
    InvoiceListView,
    MyPlanView
)

urlpatterns = [
    # Forfaits et État de l'abonnement
    path('plans/', PlanListView.as_view(), name='plans-list'),
    path('my-plan/', MyPlanView.as_view(), name='my-plan'),

    # Processus de paiement
    path('checkout/', CheckoutView.as_view(), name='checkout'),
    path('webhook/', VerifyPaymentView.as_view(), name='verify-payment'), # Ou 'verify/' selon ton choix

    # --- GESTION BUSINESS & CLIENT (CRITIQUE) ---
    path('cancel/', CancelSubscriptionView.as_view(), name='subscription-cancel'),
    path('invoices/', InvoiceListView.as_view(), name='subscription-invoices'),

    # Cartes bancaires
    path('cards/', ListPaymentMethodsView.as_view(), name='list-cards'),
    path('cards/<int:pk>/', DeletePaymentMethodView.as_view(), name='delete-card'),
]