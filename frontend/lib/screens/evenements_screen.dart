import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EvenementsScreen extends StatefulWidget {
  const EvenementsScreen({super.key});

  @override
  State<EvenementsScreen> createState() => _EvenementsScreenState();
}

class _EvenementsScreenState extends State<EvenementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDay = 13;

  final List<int> _days = [11, 12, 13, 14, 15, 16, 17];
  final List<String> _weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static final List<Map<String, dynamic>> _events = [
    {
      'tag': 'Nouveau',
      'tagColor': Colors.orange,
      'imageUrl': 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=800&auto=format&fit=crop',
      'imageColor': Colors.orange,
      'title': 'Lancement de Casque Sans-Fil Premium',
      'desc': 'Découvrez notre nouveau casque avec une réduction de 30%.',
      'date': '13 Mars 2026',
      'time': '14:00',
      'location': 'En ligne',
      'participants': '184 / 500',
      'progress': 0.37,
      'price': 'Pro',
      'priceColor': Colors.orange,
    },
    {
      'tag': 'Populaire',
      'tagColor': Colors.purple,
      'imageUrl': 'https://images.unsplash.com/photo-1540317580384-e5d43867caa6?w=800&auto=format&fit=crop',
      'imageColor': Colors.blue,
      'title': 'Webinaire: Tendances Tech 2026',
      'desc': 'Analysez les meilleures tendances et opportunités.',
      'date': '15 Mars 2026',
      'time': '10:30',
      'location': 'Zoom',
      'participants': '441 / 1000',
      'progress': 0.44,
      'price': 'Gratuit',
      'priceColor': Colors.green,
    },
    {
      'tag': 'Nouveau',
      'tagColor': Colors.orange,
      'imageUrl': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&auto=format&fit=crop',
      'imageColor': Colors.grey,
      'title': 'Flash Sale: Montres Connectées',
      'desc': 'Accès VIP aux ventes stockées de montres connectées.',
      'date': '20 Mars 2026',
      'time': '09:00',
      'location': 'Application',
      'participants': '99 / 200',
      'progress': 0.50,
      'price': 'Enquête',
      'priceColor': Colors.orange,
    },
    {
      'tag': 'Conférence',
      'tagColor': Colors.blue,
      'imageUrl': 'https://images.unsplash.com/photo-1475721025505-c31da16b1f99?w=800&auto=format&fit=crop',
      'imageColor': Colors.deepPurple,
      'title': 'Conférence E-commerce 2026',
      'desc': 'La plus grande conférence e-commerce de France.',
      'date': '25 Mars 2026',
      'time': '08:00',
      'location': 'Paris',
      'participants': '532 / 900',
      'progress': 0.59,
      'price': '89€',
      'priceColor': Colors.orange,
    },
    {
      'tag': 'Atelier',
      'tagColor': Colors.teal,
      'imageUrl': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&auto=format&fit=crop',
      'imageColor': Colors.green,
      'title': 'Atelier: Marketing Produits',
      'desc': 'Apprenez à marketer vos produits efficacement.',
      'date': '22 Mars 2026',
      'time': '15:00',
      'location': 'En ligne',
      'participants': '78 / 150',
      'progress': 0.52,
      'price': 'Gratuit',
      'priceColor': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildCalendarStrip(),
          const SizedBox(height: 12),
          _buildTabs(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _events.length,
              itemBuilder: (ctx, i) => _buildEventCard(_events[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'Événements',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.white),
              const SizedBox(width: 12),
              const Icon(Icons.add_box_outlined, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mars 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              TextButton(
                onPressed: () {},
                child: const Text('Voir Calendrier', style: TextStyle(color: AppColors.primary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_days.length, (i) {
              final isSelected = _days[i] == _selectedDay;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = _days[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekDays[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_days[i]}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabChip('Tous', 0),
          const SizedBox(width: 8),
          _buildTabChip('Lancements', 1),
          const SizedBox(width: 8),
          _buildTabChip('Webinaires', 2),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () => setState(() => _tabController.index = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: (event['imageColor'] as Color).withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    event['imageUrl'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: event['imageColor'] as Color,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: event['tagColor'] as Color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    event['tag'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                  ),
                  child: Icon(Icons.play_circle_outline, color: event['imageColor'] as Color, size: 18),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  event['desc'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(event['date'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(event['time'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(event['location'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: event['progress'] as double,
                              color: AppColors.primary,
                              backgroundColor: Colors.grey[200],
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${event['participants']} participants',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Share
                    const Icon(Icons.share_outlined, size: 20, color: Colors.grey),
                    const SizedBox(width: 10),
                    // Register button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: (event['priceColor'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        event['price'] as String,
                        style: TextStyle(
                          color: event['priceColor'] as Color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
