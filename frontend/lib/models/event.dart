class Event {
  final String id;
  final String title;
  final String description;
  final DateTime? eventDate;
  final String? location;
  final int participantsCount;
  final bool isRegistered;
  final String? imageUrl;
  final String? tag;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.eventDate,
    this.location,
    this.participantsCount = 0,
    this.isRegistered = false,
    this.imageUrl,
    this.tag,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eventDate: json['event_date'] != null ? DateTime.parse(json['event_date']) : null,
      location: json['location'],
      participantsCount: json['participants_count'] ?? 0,
      isRegistered: json['is_registered'] ?? false,
      imageUrl: json['image_url'],
      tag: json['tag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate?.toIso8601String(),
      'location': location,
      'participants_count': participantsCount,
      'is_registered': isRegistered,
      'image_url': imageUrl,
      'tag': tag,
    };
  }
}
