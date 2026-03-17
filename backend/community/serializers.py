from rest_framework import serializers
from .models import Post, Event, EventRegistration, PostLike

class PostSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source='author.username', read_only=True)
    created_at_formatted = serializers.SerializerMethodField()
    
    # Nouveaux champs calculés pour les likes
    likes_count = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = Post
        # Ajout de category, image_url, likes_count et is_liked dans la liste !
        fields = [
            'id', 'author', 'author_name', 'content', 'category', 
            'image_url', 'created_at_formatted', 'likes_count', 'is_liked'
        ]
        read_only_fields = ['author']

    def get_created_at_formatted(self, obj):
        return obj.created_at.strftime("%d/%m/%Y %H:%M")

    # Méthode pour compter les likes
    def get_likes_count(self, obj):
        return obj.likes.count()

    # Méthode pour dire au front si l'utilisateur actuel a liké ce post
    def get_is_liked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return PostLike.objects.filter(user=request.user, post=obj).exists()
        return False


class EventSerializer(serializers.ModelSerializer):
    is_registered = serializers.SerializerMethodField()
    participants_count = serializers.IntegerField(source='registrations.count', read_only=True)
    
    # On renvoie aussi le nom de l'organisateur (puisqu'on l'a ajouté au modèle plus tôt)
    creator_name = serializers.CharField(source='creator.username', read_only=True)

    class Meta:
        model = Event
        fields = ['id', 'title', 'description', 'event_date', 'location', 'participants_count', 'is_registered', 'creator_name']

    def get_is_registered(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return EventRegistration.objects.filter(user=request.user, event=obj).exists()
        return False