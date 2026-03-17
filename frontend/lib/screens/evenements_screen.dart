import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';

class EvenementsScreen extends StatefulWidget {
  const EvenementsScreen({super.key});

  @override
  State<EvenementsScreen> createState() => _EvenementsScreenState();
}

class _EvenementsScreenState extends State<EvenementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDay = 13;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _eventsList = [];

  final List<int> _days = [11, 12, 13, 14, 15, 16, 17];
  
  String _getWeekDay(int i) {
    // Basic mapping for mock data
    switch (i) {
      case 0: return 'Lun';
      case 1: return 'Mar';
      case 2: return 'Mer';
      case 3: return 'Jeu';
      case 4: return 'Ven';
      case 5: return 'Sam';
      case 6: return 'Dim';
      default: return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchEvents();
  }

  int _upcomingCount = 0;
  int _registeredCount = 0;
  int _thisWeekCount = 0;

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _apiService.getEvents();

    if (result['success'] == true) {
      final List<dynamic> data = result['data'] ?? [];
      final now = DateTime.now();
      final weekFromNow = now.add(const Duration(days: 7));
      
      int upcoming = 0;
      int registered = 0;
      int thisWeek = 0;

      final mapped = data.map((e) {
        DateTime? date;
        try {
          date = DateTime.parse(e['event_date']);
        } catch (_) {}

        if (date != null && date.isAfter(now)) {
          upcoming++;
          if (date.isBefore(weekFromNow)) {
            thisWeek++;
          }
        }
        
        if (e['is_registered'] == true) {
          registered++;
        }

        String displayDate = 'À venir';
        String displayTime = '12:00';
        if (date != null) {
          displayDate = "${date.day} ${_getMonthName(date.month)} ${date.year}";
          displayTime = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
        }

        return {
          'id': e['id'],
          'title': e['title'] ?? 'Sans titre',
          'desc': e['description'] ?? '',
          'date': displayDate,
          'time': displayTime,
          'location': e['location'] ?? 'En ligne',
          'is_registered': e['is_registered'] ?? false,
          'participants': '${e['participants_count'] ?? 0} / 500',
          'progress': (e['participants_count'] ?? 0) / 500.0,
          'price': 'Gratuit',
          'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&q=80',
          'imageColor': AppColors.primary,
          'category': e['title']?.toString().contains('Lancement') == true ? 'Lancements' : 'Webinaires',
          'tag': e['tag'] ?? 'Nouveau',
        };
      }).toList();

      setState(() {
        _eventsList = mapped;
        _upcomingCount = upcoming;
        _registeredCount = registered;
        _thisWeekCount = thisWeek;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Erreur lors du chargement des événements';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_tabController.index == 0) return _eventsList;
    String category = _tabController.index == 1 ? 'Lancements' : 'Webinaires';
    return _eventsList.where((e) => e['category'] == category).toList();
  }


  String _getMonthName(int month) {
    const months = ['Jan', 'Féb', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }

  Future<void> _showFullCalendar(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 3, _selectedDay),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDay = picked.day;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEvents;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchEvents,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 11), textAlign: TextAlign.center),
                        ),
                      _buildStatsCards(),
                      _buildCalendarStrip(),
                      _buildTabs(),
                      _buildEventList(filtered),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
          // Navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: -1,
              onTap: (index) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
            child: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          ),
          const Text(
            'Événements',
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.grey, size: 24),
              const SizedBox(width: 15),
              Stack(
                children: [
                  const Icon(Icons.notifications_none, color: Colors.grey, size: 24),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  const SizedBox(height: 15),
                  const Text('À venir', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('$_upcomingCount', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('+ $_thisWeekCount cette semaine', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1D5CFF), // Blue card
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.trending_up, color: Colors.white, size: 20),
                  const SizedBox(height: 15),
                  const Text('Inscriptions', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('$_registeredCount', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('2 cette semaine', style: TextStyle(color: Colors.white70, fontSize: 10)), // Static mock for now
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mars 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              TextButton(
                onPressed: () => _showFullCalendar(context),
                child: const Text('Voir calendrier', style: TextStyle(color: Colors.orange, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_days.length, (i) {
              final isSelected = _days[i] == _selectedDay;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = _days[i]),
                child: Container(
                  width: 44,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getWeekDay(i)[0], // L, M, M, J...
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_days[i]}',
                        style: TextStyle(
                          fontSize: 14,
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
    final tabs = ['Tous', 'Lancements', 'Webinaires'];
    final icons = [Icons.calendar_today, Icons.trending_up, Icons.people_outline];
    
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          bool isSelected = _tabController.index == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _tabController.index = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(icons[index], size: 16, color: isSelected ? Colors.white : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: Text('Aucun événement trouvé')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: events.length,
      itemBuilder: (ctx, i) => _buildEventCard(events[i]),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image logic
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  event['imageUrl'] as String,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Tags
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    _buildCardTag('Lancement produit', Colors.white, Colors.black87),
                    const SizedBox(width: 8),
                    _buildCardTag('Tendance', Colors.orange, Colors.white, icon: Icons.trending_up),
                  ],
                ),
              ),
              // Bookmark
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.bookmark_border, size: 20, color: Colors.black87),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  event['desc'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.calendar_today_outlined, event['date'] as String),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.access_time, event['time'] as String),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.location_on_outlined, 'En ligne'),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: event['is_registered'] == true
                          ? null
                          : () => _registerForEvent(event['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event['is_registered'] == true ? Colors.grey : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        event['is_registered'] == true ? 'Inscrit' : "S'inscrire",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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

  Widget _buildCardTag(String label, Color bgColor, Color textColor, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Future<void> _registerForEvent(dynamic eventId) async {
    final result = await _apiService.registerForEvent(eventId.toString());
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Inscription réussie !'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchEvents(); // Refresh to update is_registered status
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur lors de l\'inscription'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
}
