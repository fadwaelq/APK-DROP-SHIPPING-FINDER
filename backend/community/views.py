from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema
from .models import Post, Event, EventRegistration
from .serializers import PostSerializer, EventSerializer

# ==========================================
# PERMISSION PERSONNALISÉE
# ==========================================
class IsCreatorOrReadOnly(permissions.BasePermission):
    """
    Autorise tout le monde à voir (GET).
    Autorise uniquement le créateur à modifier/supprimer (PUT, PATCH, DELETE).
    """
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.creator == request.user

# ==========================================
# VUES POUR LA COMMUNAUTÉ (POSTS)
# ==========================================
class PostListCreateView(generics.ListCreateAPIView):
    """ GET: Liste des posts (avec pagination) | POST: Créer un post """
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Community"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(tags=["Community"])
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)

# ==========================================
# VUES POUR LES ÉVÉNEMENTS
# ==========================================
class EventListCreateView(generics.ListCreateAPIView):
    """ GET: Liste des événements à venir | POST: Créer un événement """
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Events"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(tags=["Events"])
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def perform_create(self, serializer):
        # On assigne automatiquement le créateur lors du POST
        serializer.save(creator=self.request.user)

class EventDetailView(generics.RetrieveUpdateDestroyAPIView):
    """ 
    GET: Voir les détails d'un événement
    PUT/PATCH: Modifier un événement (Créateur uniquement)
    DELETE: Supprimer un événement (Créateur uniquement)
    """
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    #  On applique la permission de sécurité ici
    permission_classes = [permissions.IsAuthenticated, IsCreatorOrReadOnly]

    @extend_schema(tags=["Events"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(tags=["Events"])
    def put(self, request, *args, **kwargs):
        return super().put(request, *args, **kwargs)

    @extend_schema(tags=["Events"])
    def patch(self, request, *args, **kwargs):
        return super().patch(request, *args, **kwargs)

    @extend_schema(tags=["Events"])
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)

class EventRegisterView(APIView):
    """ POST /api/events/{id}/register : S'inscrire à un événement """
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Events"])
    def post(self, request, pk):
        try:
            event = Event.objects.get(pk=pk)
        except Event.DoesNotExist:
            return Response({"error": "Événement introuvable"}, status=status.HTTP_404_NOT_FOUND)

        # Vérifier si l'utilisateur est déjà inscrit
        if EventRegistration.objects.filter(user=request.user, event=event).exists():
            return Response({"message": "Vous êtes déjà inscrit à cet événement."}, status=status.HTTP_400_BAD_REQUEST)

        # Créer l'inscription
        EventRegistration.objects.create(user=request.user, event=event)
        return Response({"message": "Inscription réussie !"}, status=status.HTTP_201_CREATED)