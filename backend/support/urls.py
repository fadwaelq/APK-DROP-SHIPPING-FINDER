from django.urls import path
from .views import (
    TicketDetailView, 
    TicketListCreateView, 
    TicketReplyView,
    TicketCloseView,
    SupportCategoriesView
)

urlpatterns = [
    path('tickets/', TicketListCreateView.as_view(), name='ticket-list-create'),
    path('tickets/<int:pk>/', TicketDetailView.as_view(), name='ticket-detail'),
    path('tickets/<int:pk>/reply/', TicketReplyView.as_view(), name='ticket-reply'),
    
    # Permet de clôturer un ticket
    path('tickets/<int:pk>/close/', TicketCloseView.as_view(), name='ticket-close'),

    # --- DERNIÈRE ROUTE (Bloc Support) ---
    # GET /api/support/categories/
    path('categories/', SupportCategoriesView.as_view(), name='support-categories'),
]