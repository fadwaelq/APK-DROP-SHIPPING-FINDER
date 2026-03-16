from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .models import Ticket, TicketMessage
from .serializers import TicketSerializer, TicketDetailSerializer

class TicketListCreateView(generics.ListCreateAPIView):
    """ GET: Lister ses tickets | POST: Créer un ticket """
    serializer_class = TicketSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Ticket.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class TicketDetailView(generics.RetrieveAPIView):
    """ Ligne 17: GET /api/support/tickets/{ticketId}/ """
    serializer_class = TicketDetailSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'pk' # Utilise l'ID du ticket

    def get_queryset(self):
        return Ticket.objects.filter(user=self.request.user)

class TicketReplyView(APIView):
    """ Ligne 18: POST /api/support/tickets/{ticketId}/reply/ """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Support"])
    def post(self, request, pk):
        try:
            # Sécurité : on vérifie que le ticket appartient à l'user
            ticket = Ticket.objects.get(pk=pk, user=request.user)
        except Ticket.DoesNotExist:
            return Response({"error": "Ticket introuvable"}, status=status.HTTP_404_NOT_FOUND)

        message_text = request.data.get('message')
        if not message_text:
            return Response({"error": "Message vide"}, status=status.HTTP_400_BAD_REQUEST)

        # Création du message
        reply = TicketMessage.objects.create(
            ticket=ticket,
            sender=request.user,
            message=message_text
        )

        # Logique métier : réouverture auto si fermé
        if ticket.status == 'CLOSED':
            ticket.status = 'OPEN'
            ticket.save()

        # Réponse conforme au tableau de Fadwa
        return Response({
            "success": True,
            "reply_id": str(reply.id),
            "timestamp": reply.created_at
        }, status=status.HTTP_201_CREATED)