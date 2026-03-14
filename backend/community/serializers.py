from rest_framework import serializers
from .models import Post, Event, EventRegistration

class PostSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source='author.username', read_only=True)
    created_at_formatted = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = ['id', 'author', 'author_name', 'content', 'created_at_formatted']
        read_only_fields = ['author']

    def get_created_at_formatted(self, obj):
        return obj.created_at.strftime("%d/%m/%Y %H:%M")

class EventSerializer(serializers.ModelSerializer):
    is_registered = serializers.SerializerMethodField()
    participants_count = serializers.IntegerField(source='registrations.count', read_only=True)

    class Meta:
        model = Event
        fields = ['id', 'title', 'description', 'event_date', 'location', 'participants_count', 'is_registered']

    def get_is_registered(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return EventRegistration.objects.filter(user=request.user, event=obj).exists()
        return False