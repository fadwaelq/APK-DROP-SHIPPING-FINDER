from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator, MaxValueValidator


class UserProfile(models.Model):
    """Extended user profile with subscription and analytics"""
    SUBSCRIPTION_CHOICES = [
        ('free', 'Free'),
        ('starter', 'Starter'),
        ('pro', 'Pro'),
        ('premium', 'Premium'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)
    subscription_plan = models.CharField(max_length=20, choices=SUBSCRIPTION_CHOICES, default='free')
    subscription_expiry_date = models.DateTimeField(null=True, blank=True)
    profitability_score = models.IntegerField(default=0, validators=[MinValueValidator(0), MaxValueValidator(100)])
    notifications_enabled = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.username} - {self.subscription_plan}"
    
    @property
    def favorite_count(self):
        return self.user.favorites.count()
    
    @property
    def view_count(self):
        return ProductView.objects.filter(user=self.user).count()


class Product(models.Model):
    """Product model with AI scoring and analytics"""
    SOURCE_CHOICES = [
        ('aliexpress', 'AliExpress'),
        ('amazon', 'Amazon'),
        ('shopify', 'Shopify'),
    ]
    
    CATEGORY_CHOICES = [
        ('tech', 'Tech'),
        ('sport', 'Sport'),
        ('home', 'Maison'),
        ('fashion', 'Mode'),
        ('beauty', 'Beauté'),
        ('toys', 'Jouets'),
        ('health', 'Santé'),
    ]
    
    # Basic Info
    name = models.CharField(max_length=500)
    description = models.TextField()
    source = models.CharField(max_length=20, choices=SOURCE_CHOICES)
    source_url = models.URLField()
    source_id = models.CharField(max_length=200)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    
    # Pricing
    price = models.DecimalField(max_digits=10, decimal_places=2)
    cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    profit = models.DecimalField(max_digits=10, decimal_places=2)
    
    # Media
    image_url = models.URLField()
    images = models.JSONField(default=list, blank=True)
    available_colors = models.JSONField(default=list, blank=True)
    
    # AI Scoring
    score = models.IntegerField(default=0, validators=[MinValueValidator(0), MaxValueValidator(100)])
    demand_level = models.IntegerField(default=0, validators=[MinValueValidator(0), MaxValueValidator(100)])
    popularity = models.IntegerField(default=0, validators=[MinValueValidator(0), MaxValueValidator(100)])
    competition = models.IntegerField(default=0, validators=[MinValueValidator(0), MaxValueValidator(100)])
    profitability = models.IntegerField(default=0, validators=[MinValueValidator(0), MaxValueValidator(100)])
    
    # Trends
    trend_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    is_trending = models.BooleanField(default=False)
    
    # Supplier Info
    supplier_name = models.CharField(max_length=200)
    supplier_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    supplier_review_count = models.IntegerField(default=0)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_scraped_at = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        ordering = ['-score', '-created_at']
        indexes = [
            models.Index(fields=['source', 'source_id']),
            models.Index(fields=['category', 'score']),
            models.Index(fields=['-is_trending', '-score']),
        ]
    
    def __str__(self):
        return f"{self.name} ({self.source})"
    
    @property
    def performance_metrics(self):
        return {
            'demand_level': self.demand_level,
            'popularity': self.popularity,
            'competition': self.competition,
            'profitability': self.profitability,
        }
    
    @property
    def supplier(self):
        return {
            'name': self.supplier_name,
            'rating': float(self.supplier_rating),
            'review_count': self.supplier_review_count,
        }


class Favorite(models.Model):
    """User favorites for products"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='favorites')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='favorited_by')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ('user', 'product')
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.username} - {self.product.name}"


class ProductView(models.Model):
    """Track product views for analytics"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='product_views')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='views')
    viewed_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-viewed_at']
    
    def __str__(self):
        return f"{self.user.username} viewed {self.product.name}"


class SearchHistory(models.Model):
    """Track user search history"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='search_history')
    query = models.CharField(max_length=500)
    filters = models.JSONField(default=dict, blank=True)
    results_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name_plural = 'Search histories'
    
    def __str__(self):
        return f"{self.user.username} searched '{self.query}'"


class TrendAlert(models.Model):
    """Alerts for trending products or categories"""
    ALERT_TYPE_CHOICES = [
        ('product', 'Product'),
        ('category', 'Category'),
        ('niche', 'Niche'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='trend_alerts')
    alert_type = models.CharField(max_length=20, choices=ALERT_TYPE_CHOICES)
    title = models.CharField(max_length=200)
    message = models.TextField()
    product = models.ForeignKey(Product, on_delete=models.CASCADE, null=True, blank=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.alert_type}: {self.title}"


class ScrapingJob(models.Model):
    """Track scraping jobs for data collection"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('running', 'Running'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]
    
    source = models.CharField(max_length=20)
    category = models.CharField(max_length=50, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    products_scraped = models.IntegerField(default=0)
    products_created = models.IntegerField(default=0)
    products_updated = models.IntegerField(default=0)
    error_message = models.TextField(blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.source} - {self.status}"
