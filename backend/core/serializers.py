from rest_framework import serializers

class StatsDataSerializer(serializers.Serializer):
    balance_coins = serializers.DecimalField(max_digits=10, decimal_places=2)
    products_found = serializers.IntegerField()
    missions_done = serializers.IntegerField()
    xp = serializers.IntegerField()

class StreakSerializer(serializers.Serializer):
    count = serializers.IntegerField()
    message = serializers.CharField()

class DashboardStatsSerializer(serializers.Serializer):
    stats = StatsDataSerializer()
    streak = StreakSerializer()

class DashboardChartsSerializer(serializers.Serializer):
    day = serializers.CharField()
    amount = serializers.IntegerField()

class DashboardChartsListSerializer(serializers.Serializer):
    chart_data = DashboardChartsSerializer(many=True)
    period = serializers.CharField()
    total_period = serializers.IntegerField()