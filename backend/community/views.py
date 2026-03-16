from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from django.shortcuts import get_object_or_404
from django.utils import timezone
from datetime import timedelta

from .models import Post, Event, EventRegistration, PostLike, PostComment, PostShare, Story
from .serializers import PostSerializer, EventSerializer

# --- Permissions ---
class IsCreatorOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        # Gère 'creator' pour Event et 'author' pour Post
        owner = getattr(obj, 'creator', getattr(obj, 'author', None))
        return owner == request.user

# --- Posts (List/Create/Like/Comment/Share) ---
class PostListCreateView(generics.ListCreateAPIView):
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)

class PostLikeToggleView(APIView):
    """ Like/Unlike """
    permission_classes = [permissions.IsAuthenticated]
    @extend_schema(tags=["Community"])
    def post(self, request, pk):
        post = get_object_or_404(Post, pk=pk)
        like, created = PostLike.objects.get_or_create(user=request.user, post=post)
        if not created:
            like.delete()
            return Response({"message": "Like retiré", "likes_count": post.likes.count()}, status=200)
        return Response({"message": "Post liké", "likes_count": post.likes.count()}, status=201)

class PostCommentView(APIView):
    """  Commentaires """
    permission_classes = [permissions.IsAuthenticated]
    @extend_schema(tags=["Community"])
    def get(self, request, pk):
        comments = PostComment.objects.filter(post_id=pk)
        return Response({
            "comments": [{"user": c.user.username, "text": c.text, "date": c.created_at} for c in comments]
        }, status=200)

    def post(self, request, pk):
        post = get_object_or_404(Post, pk=pk)
        text = request.data.get('text')
        if not text: return Response({"error": "Texte requis"}, status=400)
        PostComment.objects.create(user=request.user, post=post, text=text)
        return Response({"success": True}, status=201)

class PostShareView(APIView):
    """ Partage """
    permission_classes = [permissions.IsAuthenticated]
    @extend_schema(tags=["Community"])
    def post(self, request, pk):
        post = get_object_or_404(Post, pk=pk)
        PostShare.objects.create(user=request.user, post=post)
        return Response({"success": True, "share_count": post.shares.count()}, status=201)

# --- Stories (Ligne 5) ---
class StoryListCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    @extend_schema(tags=["Community"])
    def get(self, request):
        yesterday = timezone.now() - timedelta(hours=24)
        stories = Story.objects.filter(created_at__gt=yesterday)
        return Response({
            "stories": [{"id": s.id, "user": s.user.username, "image": s.image.url} for s in stories]
        })

    def post(self, request):
        image = request.FILES.get('image')
        if not image: return Response({"error": "Image requise"}, status=400)
        Story.objects.create(user=request.user, image=image)
        return Response({"success": True}, status=201)

# --- Events (Tes vues existantes) ---
class EventListCreateView(generics.ListCreateAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticated]
    def perform_create(self, serializer): serializer.save(creator=self.request.user)

class EventDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticated, IsCreatorOrReadOnly]

class EventRegisterView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    def post(self, request, pk):
        event = get_object_or_404(Event, pk=pk)
        EventRegistration.objects.get_or_create(user=request.user, event=event)
        return Response({"message": "Inscription réussie !"}, status=201)