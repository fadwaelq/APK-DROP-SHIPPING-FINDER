from django.urls import path
from .views import PostListCreateView, EventListView, EventRegisterView

urlpatterns = [
    # Routes Communauté
    path('community/posts/', PostListCreateView.as_view(), name='post-list-create'),
    
    # Routes Événements
    path('events/', EventListView.as_view(), name='event-list'),
    path('events/<int:pk>/register/', EventRegisterView.as_view(), name='event-register'),
]