import random
from datetime import timedelta
from django.utils import timezone
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

# Remplace 'nom_de_ton_app' par le nom exact du dossier de ton application
from support.models import Ticket, TicketMessage

User = get_user_model()

class Command(BaseCommand):
    help = 'Génère des tickets de support et des conversations de test'

    def handle(self, *args, **kwargs):
        users = list(User.objects.filter(is_staff=False)) # Utilisateurs normaux
        
        if not users:
            self.stdout.write(self.style.ERROR("❌ Aucun utilisateur normal trouvé !"))
            return

        self.stdout.write("🚀 Lancement de la génération du Support Client...")

        # 1. Création ou récupération d'un compte "Support / Admin"
        support_agent, _ = User.objects.get_or_create(
            email="support@dropship.ma",
            defaults={
                "username": "Support_Team",
                "is_staff": True,
                "is_superuser": True
            }
        )
        support_agent.set_password("Admin1234!")
        support_agent.save()

        # 2. Scénarios de tickets réalistes pour ton application
        ticket_scenarios = [
            {
                "subject": "Bug avec le calculateur de marge",
                "message": "Bonjour, quand je rentre un prix d'achat à 50 MAD, le calcul de la taxe bloque. Pouvez-vous vérifier ?",
                "status": "IN_PROGRESS",
                "agent_reply": "Bonjour, merci pour votre retour. Nos développeurs sont en train d'enquêter sur ce souci d'arrondi avec les dirhams."
            },
            {
                "subject": "Question sur l'abonnement VIP",
                "message": "Salut, si je prends l'abonnement VIP annuel, est-ce que j'ai accès aux produits cachés ?",
                "status": "RESOLVED",
                "agent_reply": "Bonjour ! Oui absolument, le forfait VIP vous donne un accès illimité et en avant-première à tous nos produits gagnants."
            },
            {
                "subject": "Comment lier ma boutique Shopify ?",
                "message": "Je ne trouve pas le bouton pour exporter les produits vers ma boutique Shopify.",
                "status": "CLOSED",
                "agent_reply": "Bonjour, cette fonctionnalité arrivera dans la V2 de l'application le mois prochain. Restez à l'écoute !"
            },
            {
                "subject": "Problème de connexion",
                "message": "Mon application crash quand j'essaie de me connecter avec Google.",
                "status": "OPEN",
                "agent_reply": None # L'agent n'a pas encore répondu
            }
        ]

        created_count = 0

        # 3. Création des tickets pour quelques utilisateurs au hasard
        for i in range(5):
            user = random.choice(users)
            scenario = random.choice(ticket_scenarios)

            # Création du ticket principal
            ticket = Ticket.objects.create(
                user=user,
                subject=scenario["subject"],
                message=scenario["message"],
                status=scenario["status"]
            )
            
            # Antidater le ticket (pour éviter que tout soit créé à la même seconde)
            fake_ticket_date = timezone.now() - timedelta(days=random.randint(1, 5), hours=random.randint(1, 12))
            ticket.created_at = fake_ticket_date
            ticket.save(update_fields=['created_at'])

            # Le premier message du ticket (celui de l'utilisateur)
            msg_user = TicketMessage.objects.create(
                ticket=ticket,
                sender=user,
                message=scenario["message"]
            )
            msg_user.created_at = fake_ticket_date
            msg_user.save(update_fields=['created_at'])

            # Si l'agent a répondu, on crée son message un peu plus tard
            if scenario["agent_reply"]:
                reply_date = fake_ticket_date + timedelta(hours=random.randint(1, 5))
                msg_agent = TicketMessage.objects.create(
                    ticket=ticket,
                    sender=support_agent,
                    message=scenario["agent_reply"]
                )
                msg_agent.created_at = reply_date
                msg_agent.save(update_fields=['created_at'])
                
                # Si le ticket est résolu, l'utilisateur a peut-être dit merci
                if scenario["status"] in ["RESOLVED", "CLOSED"]:
                    thanks_date = reply_date + timedelta(minutes=random.randint(30, 120))
                    msg_thanks = TicketMessage.objects.create(
                        ticket=ticket,
                        sender=user,
                        message="Super, merci beaucoup pour votre aide rapide !"
                    )
                    msg_thanks.created_at = thanks_date
                    msg_thanks.save(update_fields=['created_at'])

            created_count += 1

        self.stdout.write(self.style.SUCCESS(f"🎉 {created_count} Tickets générés avec des conversations !"))