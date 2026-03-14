from rest_framework import serializers
from .models import Ticket

class TicketSerializer(serializers.ModelSerializer):
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    created_at_formatted = serializers.SerializerMethodField()

    class Meta:
        model = Ticket
        fields = ['id', 'subject', 'message', 'status', 'status_display', 'created_at', 'updated_at', 'created_at_formatted']
        # On empêche l'utilisateur de modifier le statut lui-même ou les dates
        read_only_fields = ['id', 'status', 'created_at', 'updated_at']

    def get_created_at_formatted(self, obj):
        return obj.created_at.strftime("%d/%m/%Y %H:%M")