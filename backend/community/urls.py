from django.urls import path
from .views import (
    PostListCreateView, 
    PostLikeToggleView, 
    PostCommentView,    
    PostShareView,     
    StoryListCreateView, 
    EventListCreateView, 
    EventDetailView, 
    EventRegisterView
)

urlpatterns = [
    # --- Routes Communauté (Posts & Interactions) ---
    path('community/posts/', PostListCreateView.as_view(), name='post-list-create'),
    path('community/posts/<int:pk>/like/', PostLikeToggleView.as_view(), name='post-like'),
    path('community/posts/<int:pk>/comments/', PostCommentView.as_view(), name='post-comments'), 
    path('community/posts/<int:pk>/share/', PostShareView.as_view(), name='post-share'),       
    
    # --- Routes Stories  ---
    path('community/stories/', StoryListCreateView.as_view(), name='story-list-create'),

    # --- Routes Événements ---
    path('events/', EventListCreateView.as_view(), name='event-list-create'),
    path('events/<int:pk>/', EventDetailView.as_view(), name='event-detail'),
    path('events/<int:pk>/register/', EventRegisterView.as_view(), name='event-register'),
]