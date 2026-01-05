from django.contrib import admin
from .models import (
    UserProfile, Product, Favorite, ProductView,
    SearchHistory, TrendAlert, ScrapingJob
)


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'subscription_plan', 'profitability_score', 'created_at']
    list_filter = ['subscription_plan', 'notifications_enabled']
    search_fields = ['user__username', 'user__email']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ['name', 'source', 'category', 'price', 'profit', 'score', 'is_trending', 'created_at']
    list_filter = ['source', 'category', 'is_trending', 'is_active']
    search_fields = ['name', 'description', 'source_id']
    readonly_fields = ['created_at', 'updated_at', 'last_scraped_at']
    ordering = ['-score', '-created_at']
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'description', 'source', 'source_url', 'source_id', 'category')
        }),
        ('Pricing', {
            'fields': ('price', 'cost', 'profit')
        }),
        ('Media', {
            'fields': ('image_url', 'images', 'available_colors')
        }),
        ('AI Scoring', {
            'fields': ('score', 'demand_level', 'popularity', 'competition', 'profitability')
        }),
        ('Trends', {
            'fields': ('trend_percentage', 'is_trending')
        }),
        ('Supplier', {
            'fields': ('supplier_name', 'supplier_rating', 'supplier_review_count')
        }),
        ('Metadata', {
            'fields': ('is_active', 'created_at', 'updated_at', 'last_scraped_at')
        }),
    )


@admin.register(Favorite)
class FavoriteAdmin(admin.ModelAdmin):
    list_display = ['user', 'product', 'created_at']
    list_filter = ['created_at']
    search_fields = ['user__username', 'product__name']
    readonly_fields = ['created_at']


@admin.register(ProductView)
class ProductViewAdmin(admin.ModelAdmin):
    list_display = ['user', 'product', 'viewed_at']
    list_filter = ['viewed_at']
    search_fields = ['user__username', 'product__name']
    readonly_fields = ['viewed_at']


@admin.register(SearchHistory)
class SearchHistoryAdmin(admin.ModelAdmin):
    list_display = ['user', 'query', 'results_count', 'created_at']
    list_filter = ['created_at']
    search_fields = ['user__username', 'query']
    readonly_fields = ['created_at']


@admin.register(TrendAlert)
class TrendAlertAdmin(admin.ModelAdmin):
    list_display = ['user', 'alert_type', 'title', 'is_read', 'created_at']
    list_filter = ['alert_type', 'is_read', 'created_at']
    search_fields = ['user__username', 'title', 'message']
    readonly_fields = ['created_at']


@admin.register(ScrapingJob)
class ScrapingJobAdmin(admin.ModelAdmin):
    list_display = ['source', 'category', 'status', 'products_scraped', 'started_at', 'completed_at']
    list_filter = ['source', 'status', 'created_at']
    readonly_fields = ['created_at', 'started_at', 'completed_at']
    
    fieldsets = (
        ('Job Information', {
            'fields': ('source', 'category', 'status')
        }),
        ('Statistics', {
            'fields': ('products_scraped', 'products_created', 'products_updated')
        }),
        ('Error Information', {
            'fields': ('error_message',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'started_at', 'completed_at')
        }),
    )
