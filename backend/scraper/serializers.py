from rest_framework import serializers

class SearchRequestSerializer(serializers.Serializer):
    query = serializers.CharField(
        help_text="Mot-clé ou URL (ex: Montre connectée, https://...)", 
        required=True
    )
    platform = serializers.CharField(
        default="aliexpress", 
        help_text="Plateforme cible"
    )

class BulkSearchRequestSerializer(serializers.Serializer):
    items = serializers.ListField(
        child=serializers.CharField(),
        help_text="Liste de mots-clés ou d'URLs",
        required=True
    )
    platform = serializers.CharField(
        default="aliexpress",
        help_text="Plateforme cible"
    )