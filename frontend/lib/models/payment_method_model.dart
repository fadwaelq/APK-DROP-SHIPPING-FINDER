class PaymentMethod {
  final int id;
  final String cardType;
  final String lastFour;
  final String expiryDate;
  final bool isDefault;
  final String colorHex;

  PaymentMethod({
    required this.id,
    required this.cardType,
    required this.lastFour,
    required this.expiryDate,
    required this.isDefault,
    required this.colorHex,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      cardType: json['card_type'] ?? 'VISA',
      lastFour: json['last_four'] ?? '0000',
      expiryDate: json['expiry_date'] ?? '00/00',
      isDefault: json['is_default'] ?? false,
      colorHex: json['color_hex'] ?? '#1A3A8A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_type': cardType,
      'last_four': lastFour,
      'expiry_date': expiryDate,
      'is_default': isDefault,
      'color_hex': colorHex,
    };
  }
}
