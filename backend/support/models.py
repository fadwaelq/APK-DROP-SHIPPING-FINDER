from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Ticket(models.Model):
    STATUS_CHOICES = [
        ('OPEN', 'Ouvert'),
        ('IN_PROGRESS', 'En cours'),
        ('RESOLVED', 'Résolu'),
        ('CLOSED', 'Fermé'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tickets')
    subject = models.CharField(max_length=255, help_text="Sujet du problème")
    message = models.TextField(help_text="Description détaillée")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='OPEN')
    
    # Timestamps demandés par le frontend
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = "Ticket de support"
        verbose_name_plural = "Tickets de support"

    def __str__(self):
        return f"Ticket #{self.id} - {self.subject} ({self.get_status_display()})"
    
# Modèle pour les messages associés à un ticket, permettant une communication entre l'utilisateur et le support
class TicketMessage(models.Model):
    ticket = models.ForeignKey(Ticket, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(User, on_delete=models.CASCADE)
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"Message de {self.sender.username} sur le ticket #{self.ticket.id}"