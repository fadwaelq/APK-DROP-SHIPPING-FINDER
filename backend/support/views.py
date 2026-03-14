from rest_framework import generics, permissions
from drf_spectacular.utils import extend_schema
from .models import Ticket
from .serializers import TicketSerializer

class TicketListCreateView(generics.ListCreateAPIView):
    """
    GET /api/support/tickets : Lister les tickets de l'utilisateur connecté.
    POST /api/support/tickets : Créer un nouveau ticket.
    """
    serializer_class = TicketSerializer
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Support"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(tags=["Support"])
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def get_queryset(self):
        # Sécurité : Un utilisateur ne voit que SES propres tickets
        return Ticket.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        # Sécurité : On force l'ID de l'utilisateur connecté lors de la création
        serializer.save(user=self.request.user)