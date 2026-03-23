import random
from datetime import timedelta
from django.utils import timezone
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.core.files.base import ContentFile

# Remplace 'nom_de_ton_app' par le vrai nom de ton application !
from community.models import Post, PostLike, PostComment, PostShare, Story, Event, EventRegistration

User = get_user_model()

class Command(BaseCommand):
    help = 'Génère des publications, des événements et des interactions de test'

    def handle(self, *args, **kwargs):
        users = list(User.objects.all())
        
        if not users:
            self.stdout.write(self.style.ERROR("❌ Aucun utilisateur trouvé ! Lance d'abord 'python manage.py seed_users'"))
            return

        self.stdout.write("🚀 Lancement de la création de la communauté...")

        # --- 1. CRÉATION DES ÉVÉNEMENTS ---
        events_data = [
            {"title": "Masterclass : Q4 Scaling", "desc": "Comment exploser ses ventes pour le Q4.", "days": 5},
            {"title": "Live Q&A Dropshipping", "desc": "Je réponds à toutes vos questions sur les Facebook Ads.", "days": 2},
        ]
        
        created_events = []
        for e in events_data:
            event, created = Event.objects.get_or_create(
                title=e["title"],
                defaults={
                    "creator": random.choice(users),
                    "description": e["desc"],
                    "event_date": timezone.now() + timedelta(days=e["days"]),
                    "location": "https://zoom.us/j/demo1234"
                }
            )
            created_events.append(event)
            
            # Inscription aléatoire de quelques utilisateurs à l'événement
            attendees = random.sample(users, min(len(users), random.randint(1, 3)))
            for attendee in attendees:
                EventRegistration.objects.get_or_create(user=attendee, event=event)

        self.stdout.write(f"✅ {len(created_events)} Événements créés avec leurs participants !")

        # --- 2. CRÉATION DES POSTS (PUBLICATIONS) ---
        posts_data = [
            {"cat": "SUCCESS", "text": "J'ai passé la barre des 10k MAD ce mois-ci grâce à un produit Winner ! 💸", "img": "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?auto=format&fit=crop&w=500"},
            {"cat": "QUESTION", "text": "Salut l'équipe, quelqu'un utilise Stripe au Maroc ? J'ai des blocages... 🤯", "img": None},
            {"cat": "TUTORIAL", "text": "Voici ma stratégie exacte pour tester un produit avec 50$ sur TikTok Ads 👇", "img": "https://images.unsplash.com/photo-1611162617474-5b21e879e113?auto=format&fit=crop&w=500"},
            {"cat": "GENERAL", "text": "N'oubliez pas les gars, la consistance bat le talent. Ne lâchez rien ! 💪", "img": None},
        ]

        created_posts = []
        for p in posts_data:
            post = Post.objects.create(
                author=random.choice(users),
                content=p["text"],
                category=p["cat"],
                image_url=p["img"]
            )
            created_posts.append(post)

        self.stdout.write(f"✅ {len(created_posts)} Publications créées !")

        # --- 3. CRÉATION DES INTERACTIONS (Likes, Commentaires, Partages) ---
        comments_pool = ["Bravo frérot !", "Merci pour le partage 🔥", "Je suis preneur de plus d'infos", "Totalement d'accord", "Quelqu'un peut m'aider en DM ?"]

        for post in created_posts:
            # Ajouter 1 à 4 likes au hasard
            likers = random.sample(users, min(len(users), random.randint(1, 4)))
            for liker in likers:
                PostLike.objects.get_or_create(user=liker, post=post)
            
            # Ajouter 1 à 2 commentaires au hasard
            for _ in range(random.randint(1, 2)):
                PostComment.objects.create(
                    user=random.choice(users),
                    post=post,
                    text=random.choice(comments_pool)
                )

        self.stdout.write("✅ Interactions (Likes & Commentaires) ajoutées !")

        # --- 4. CRÉATION DES STORIES ---
        # Comme tu utilises un ImageField (qui attend un vrai fichier), on crée un faux fichier à la volée
        for user in users[:2]: # On crée des stories juste pour 2 utilisateurs pour tester
            story = Story(user=user)
            # Création d'un faux fichier image pour remplir le champ sans crasher
            dummy_image = ContentFile(b"Ceci est une fausse image de test", name=f"story_{user.username}.jpg")
            story.image.save(f"story_{user.username}.jpg", dummy_image)
        
        self.stdout.write("✅ Stories de test générées !")
        self.stdout.write(self.style.SUCCESS("🎉 Base de données Communauté peuplée avec succès !"))