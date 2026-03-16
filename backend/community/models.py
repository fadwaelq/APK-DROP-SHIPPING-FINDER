from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

# --- PUBLICATIONS ---
class Post(models.Model):
    CATEGORY_CHOICES = (
        ('GENERAL', 'Général'),
        ('QUESTION', 'Question'),
        ('TUTORIAL', 'Tutoriel'),
        ('SUCCESS', 'Succès/Avis'),
    )
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts')
    content = models.TextField(help_text="Contenu de la publication")
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default='GENERAL')
    image_url = models.URLField(max_length=500, blank=True, null=True, help_text="Lien de l'image (optionnel)")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Post de {self.author.username} - {self.category}"

# --- INTERACTIONS ---
class PostLike(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='liked_posts')
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='likes')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'post')

class PostComment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='post_comments')
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

class PostShare(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='shared_posts')
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='shares')
    created_at = models.DateTimeField(auto_now_add=True)

# --- STORIES (LA CLASSE MANQUANTE) ---
class Story(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='stories')
    image = models.ImageField(upload_to='stories/')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name_plural = "Stories"

# --- ÉVÉNEMENTS ---
class Event(models.Model):
    creator = models.ForeignKey(User, on_delete=models.CASCADE, related_name='created_events')
    title = models.CharField(max_length=200)
    description = models.TextField()
    event_date = models.DateTimeField(help_text="Date et heure de l'événement")
    location = models.CharField(max_length=255, help_text="Lieu ou lien visio", blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

class EventRegistration(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='registrations')
    registered_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'event')