from django.shortcuts import render

from rest_framework import generics
from .models import Product
from .serializers import ProductSerializer

# view for the API endpoint that lists all products
class ProductListAPIView(generics.ListAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer