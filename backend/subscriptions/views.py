# subscriptions/views.py
from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from django.utils import timezone
from datetime import timedelta

from .models import SubscriptionPlan, UserSubscription
from .serializers import SubscriptionPlanSerializer, PaymentInputSerializer 

class PlanListView(generics.ListAPIView):
    queryset = SubscriptionPlan.objects.filter(is_active=True)
    serializer_class = SubscriptionPlanSerializer
    permission_classes = [permissions.AllowAny]

class CheckoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    # CETTE LIGNE DIT À SWAGGER : "Affiche un formulaire pour ce serializer"
    serializer_class = PaymentInputSerializer 

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
    permission_classes = [permissions.IsAuthenticated]
    # CETTE LIGNE AUSSI
    serializer_class = PaymentInputSerializer 

    def post(self, request):
        plan_id = request.data.get('plan_id')
        transaction_id = request.data.get('transaction_id')

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
    


class MyPlanView(APIView):
    """ GET /api/subscriptions/my-plan : Obtenir les détails de l'abonnement actuel  """
    permission_classes = [permissions.IsAuthenticated]

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