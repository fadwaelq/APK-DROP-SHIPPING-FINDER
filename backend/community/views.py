from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from django.shortcuts import get_object_or_404
from django.utils import timezone
from datetime import timedelta

# Importation de tes modèles
from .models import Post, Event, EventRegistration, PostLike, PostComment, PostShare, Story
# Importation de tes serializers
from .serializers import PostSerializer, EventSerializer

# --- Permissions ---
class IsCreatorOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        owner = getattr(obj, 'creator', getattr(obj, 'author', None))
        return owner == request.user

# --- Posts (List/Create) ---
class PostListCreateView(generics.ListCreateAPIView):
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)

# --- Like / Unlike (Séparés comme demandé P2) ---
class PostLikeView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    @extend_schema(tags=["Community"])
    def post(self, request, pk):
        post = get_object_or_404(Post, pk=pk)
        PostLike.objects.get_or_create(user=request.user, post=post)
        return Response({"success": True, "likes_count": post.likes.count()}, status=status.HTTP_200_OK)

class PostUnlikeView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    @extend_schema(tags=["Community"])
    def post(self, request, pk):
        post = get_object_or_404(Post, pk=pk)
        PostLike.objects.filter(user=request.user, post=post).delete()
        return Response({"success": True, "likes_count": post.likes.count()}, status=status.HTTP_200_OK)

# --- Commentaires ---
class PostCommentView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    @extend_schema(tags=["Community"])
    def get(self, request, pk):
        comments = PostComment.objects.filter(post_id=pk)
        return Response({
            "comments": [{"id": c.id, "user": c.user.username, "text": c.text, "date": c.created_at} for c in comments]
        }, status=status.HTTP_200_OK)

    def post(self, request, pk):
        post = get_object_or_404(Post, pk=pk)
        text = request.data.get('text')
        if not text: 
            return Response({"error": "Texte requis"}, status=status.HTTP_400_BAD_REQUEST)
        PostComment.objects.create(user=request.user, post=post, text=text)
        return Response({"success": True}, status=status.HTTP_201_CREATED)

# --- Partage ---
class PostShareView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    @extend_schema(tags=["Community"])
    def post(self, request, pk):
        post = get_object_or_404(Post, pk=pk)
        PostShare.objects.create(user=request.user, post=post)
        return Response({"success": True, "share_count": post.shares.count()}, status=status.HTTP_201_CREATED)

# --- Stories (24h d'expiration) ---
class StoryListCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    @extend_schema(tags=["Community"])
    def get(self, request):
        yesterday = timezone.now() - timedelta(hours=24)
        stories = Story.objects.filter(created_at__gt=yesterday)
        return Response({
            "stories": [{"id": s.id, "user": s.user.username, "image": s.image.url} for s in stories]
        }, status=status.HTTP_200_OK)

    def post(self, request):
        image = request.FILES.get('image')
        if not image: 
            return Response({"error": "Image requise"}, status=status.HTTP_400_BAD_REQUEST)
        Story.objects.create(user=request.user, image=image)
        return Response({"success": True}, status=status.HTTP_201_CREATED)

# --- Events ---
class EventListCreateView(generics.ListCreateAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_create(self, serializer): 
        serializer.save(creator=self.request.user)

class EventDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticated, IsCreatorOrReadOnly]

class EventRegisterView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request, pk):
        event = get_object_or_404(Event, pk=pk)
        EventRegistration.objects.get_or_create(user=request.user, event=event)
        return Response({"success": True, "message": "Inscription réussie !"}, status=status.HTTP_201_CREATED)