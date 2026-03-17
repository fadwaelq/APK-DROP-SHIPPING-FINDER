from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from django.utils import timezone
from datetime import timedelta
from drf_spectacular.utils import extend_schema

from .models import SubscriptionPlan, UserSubscription, PaymentMethod
from .serializers import SubscriptionPlanSerializer, PaymentInputSerializer 

# ==========================================
# GESTION DES FORFAITS
# ==========================================

class PlanListView(generics.ListAPIView):
    """ Liste tous les forfaits actifs """
    queryset = SubscriptionPlan.objects.filter(is_active=True)
    serializer_class = SubscriptionPlanSerializer
    permission_classes = [permissions.AllowAny]

class MyPlanView(APIView):
    """ GET /api/subscriptions/my-plan : Détails de l'abonnement actuel """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Subscriptions"])
    def get(self, request):
        try:
            subscription = UserSubscription.objects.get(user=request.user)
            return Response({
                "is_active": subscription.is_active,
                "plan_name": subscription.plan.name if subscription.plan else "Gratuit",
                "start_date": subscription.start_date,
                "end_date": subscription.end_date,
                "days_remaining": (subscription.end_date - timezone.now()).days if subscription.end_date else 0
            }, status=status.HTTP_200_OK)
        except UserSubscription.DoesNotExist:
            return Response({
                "is_active": False,
                "plan_name": "Gratuit",
                "start_date": None,
                "end_date": None,
                "days_remaining": 0
            }, status=status.HTTP_200_OK)

# ==========================================
# PAIEMENT ET VALIDATION
# ==========================================

class CheckoutView(APIView):
    """ POST /api/subscriptions/checkout/ : Initier un paiement """
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = PaymentInputSerializer 

    @extend_schema(tags=["Subscriptions"])
    def post(self, request):
        plan_id = request.data.get('plan_id')
        try:
            plan = SubscriptionPlan.objects.get(id=plan_id, is_active=True)
            return Response({
                "detail": "Paiement initié avec succès.",
                "plan_name": plan.name,
                "price": str(plan.price),
                "payment_url": "https://lien-vers-la-banque.com/pay/12345"
            }, status=status.HTTP_200_OK)
        except SubscriptionPlan.DoesNotExist:
            return Response({"detail": "Forfait introuvable."}, status=status.HTTP_404_NOT_FOUND)

class VerifyPaymentView(APIView):
    """ POST /api/subscriptions/verify/ : Valider la transaction """
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = PaymentInputSerializer 

    @extend_schema(tags=["Subscriptions"])
    def post(self, request):
        plan_id = request.data.get('plan_id')
        # transaction_id = request.data.get('transaction_id') # À utiliser avec ton service de paiement

        try:
            plan = SubscriptionPlan.objects.get(id=plan_id, is_active=True)
        except SubscriptionPlan.DoesNotExist:
            return Response({"detail": "Forfait introuvable."}, status=status.HTTP_404_NOT_FOUND)

        end_date = timezone.now() + timedelta(days=plan.duration_days)
        subscription, created = UserSubscription.objects.get_or_create(user=request.user)
        subscription.plan = plan
        subscription.start_date = timezone.now()
        subscription.end_date = end_date
        subscription.is_active = True
        subscription.save()

        return Response({
            "detail": "Paiement validé ! Le compte est maintenant Premium.",
            "plan_name": plan.name,
            "end_date": subscription.end_date.strftime("%Y-%m-%d %H:%M:%S")
        }, status=status.HTTP_200_OK)

# ==========================================
# GESTION DES CARTES (MODES DE PAIEMENT)
# ==========================================

class ListPaymentMethodsView(APIView):
    """ GET /api/subscriptions/cards/ : Liste les cartes enregistrées """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Subscriptions"])
    def get(self, request):
        cards = PaymentMethod.objects.filter(user=request.user)
        data = [{
            "id": c.id,
            "brand": c.card_brand,
            "last4": c.card_number_masked[-4:],
            "expiry": f"{c.exp_month}/{c.exp_year}",
            "is_default": c.is_default
        } for c in cards]
        return Response(data, status=status.HTTP_200_OK)

class DeletePaymentMethodView(APIView):
    """ DELETE /api/subscriptions/cards/{id}/ : Supprimer une carte """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Subscriptions"])
    def delete(self, request, pk):
        try:
            # Sécurité : On ne peut supprimer que ses propres cartes
            card = PaymentMethod.objects.get(pk=pk, user=request.user)
            card.delete()
            return Response({
                "success": True, 
                "message": "Carte bancaire supprimée."
            }, status=status.HTTP_200_OK)
        except PaymentMethod.DoesNotExist:
            return Response({
                "error": "Carte introuvable."
            }, status=status.HTTP_404_NOT_FOUND)

# ==========================================
# GESTION DU CYCLE DE VIE & FACTURATION
# ==========================================

class CancelSubscriptionView(APIView):
    """ POST /api/subscriptions/cancel/ : Désactiver le renouvellement automatique """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Subscriptions"])
    def post(self, request):
        try:
            subscription = UserSubscription.objects.get(user=request.user)
            if not subscription.is_active:
                return Response({"detail": "Aucun abonnement actif trouvé."}, status=status.HTTP_400_BAD_REQUEST)
            
            # Ici, tu passes is_active à False ou tu gères la date de fin
            subscription.is_active = False 
            subscription.save()
            
            return Response({
                "message": "Le renouvellement automatique a été annulé. Vous restez Premium jusqu'à la fin de la période en cours.",
                "end_date": subscription.end_date
            }, status=status.HTTP_200_OK)
        except UserSubscription.DoesNotExist:
            return Response({"error": "Abonnement introuvable."}, status=status.HTTP_404_NOT_FOUND)

class InvoiceListView(APIView):
    """ GET /api/subscriptions/invoices/ : Historique des reçus/factures PDF """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Subscriptions"])
    def get(self, request):
        # ou directement de l'API Stripe/PayPal.
        mock_invoices = [
            {
                "id": "INV-2026-001",
                "date": timezone.now().strftime("%Y-%m-%d"),
                "amount": "199.00 MAD", # À remplacer par le montant réel de la transaction
                "status": "Payé",
                "download_url": "https://ton-backend.com/media/invoices/inv_sample.pdf"
            }
        ]
        return Response(mock_invoices, status=status.HTTP_200_OK)