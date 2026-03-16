from django.urls import path
from .views import (
    PostListCreateView, 
    EventListCreateView, 
    EventDetailView, 
    EventRegisterView
)
urlpatterns = [
    # Routes Communauté
    path('community/posts/', PostListCreateView.as_view(), name='post-list-create'),
    
    # Routes Événements
    path('events/', EventListCreateView.as_view(), name='event-list-create'),
    path('events/<int:pk>/', EventDetailView.as_view(), name='event-detail'),
    path('events/<int:pk>/register/', EventRegisterView.as_view(), name='event-register'),
    
]