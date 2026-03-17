from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema

from .models import Ticket, TicketMessage
from .serializers import TicketSerializer, TicketDetailSerializer

class TicketListCreateView(generics.ListCreateAPIView):
    """ GET: Lister ses tickets | POST: Créer un nouveau ticket """
    serializer_class = TicketSerializer
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Support"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(tags=["Support"])
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def get_queryset(self):
        return Ticket.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class TicketDetailView(generics.RetrieveAPIView):
    """ GET /api/support/tickets/{id}/ : Voir les détails d'un ticket et ses messages """
    serializer_class = TicketDetailSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'pk'

    @extend_schema(tags=["Support"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_queryset(self):
        return Ticket.objects.filter(user=self.request.user)

class TicketReplyView(APIView):
    """ POST /api/support/tickets/{id}/reply/ : Ajouter un message à un ticket """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Support"])
    def post(self, request, pk):
        try:
            # Sécurité : on vérifie que le ticket appartient bien à l'utilisateur
            ticket = Ticket.objects.get(pk=pk, user=request.user)
        except Ticket.DoesNotExist:
            return Response({"error": "Ticket introuvable ou accès non autorisé"}, status=status.HTTP_404_NOT_FOUND)

        message_text = request.data.get('message')
        if not message_text:
            return Response({"error": "Le message ne peut pas être vide"}, status=status.HTTP_400_BAD_REQUEST)

        # Création de la réponse
        reply = TicketMessage.objects.create(
            ticket=ticket,
            sender=request.user,
            message=message_text
        )

        # Logique métier : si le ticket était fermé, le fait de répondre le rouvre
        if ticket.status == 'CLOSED' or ticket.status == 'RESOLVED':
            ticket.status = 'OPEN'
            ticket.save()

        return Response({
            "success": True,
            "reply_id": str(reply.id),
            "timestamp": reply.created_at,
            "ticket_status": ticket.status
        }, status=status.HTTP_201_CREATED)

# ==========================================
# NOUVELLE VUE : FERMER UN TICKET
# ==========================================
class TicketCloseView(APIView):
    """ POST /api/support/tickets/{id}/close/ : Clôturer un ticket """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Support"])
    def post(self, request, pk):
        try:
            ticket = Ticket.objects.get(pk=pk, user=request.user)
        except Ticket.DoesNotExist:
            return Response({"error": "Ticket introuvable"}, status=status.HTTP_404_NOT_FOUND)

        if ticket.status == 'CLOSED':
            return Response({"message": "Ce ticket est déjà fermé."}, status=status.HTTP_200_OK)

        ticket.status = 'CLOSED'
        ticket.save()

        return Response({
            "success": True,
            "message": "Ticket fermé avec succès.",
            "ticket_id": ticket.id,
            "new_status": ticket.status
        }, status=status.HTTP_200_OK)

# ==========================================
# CONFIGURATION SUPPORT
# ==========================================

class SupportCategoriesView(APIView):
    """ GET /api/support/categories : Liste des catégories pour le formulaire de ticket """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Support"])
    def get(self, request):
        # On définit les catégories ici. Si tu as un modèle Ticket avec des CHOICES,
        # tu pourrais aussi les extraire dynamiquement.
        categories = [
            {"id": "TECH", "label": "Problème Technique"},
            {"id": "BILLING", "label": "Paiement & Coins"},
            {"id": "ACCOUNT", "label": "Mon Compte"},
            {"id": "PRODUCT", "label": "Question sur un produit"},
            {"id": "OTHER", "label": "Autre demande"}
        ]
        return Response({"categories": categories}, status=status.HTTP_200_OK)