import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/session_manager.dart';
import 'package:provider/provider.dart';

class CommunauteScreen extends StatefulWidget {
  const CommunauteScreen({super.key});

  @override
  State<CommunauteScreen> createState() => _CommunauteScreenState();
}

class _CommunauteScreenState extends State<CommunauteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];
  String? _error;

  Map<String, dynamic> _stats = {
    'members_active': '2,847',
    'publications': '1,234',
    'vos_likes': '89'
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _tabIndex = _tabController.index);
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchPosts(),
      _fetchStats(),
    ]);
  }

  Future<void> _fetchStats() async {
    final result = await _apiService.getDashboardStats();
    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        _stats = {
          'members_active': data['active_users_count']?.toString() ?? '2,847',
          'publications': data['total_posts']?.toString() ?? '1,234',
          'vos_likes': data['user_likes_count']?.toString() ?? '89',
        };
      });
    }
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _apiService.getCommunityPosts();

    if (result['success'] == true) {
      final List<dynamic> postsData = result['data'] ?? [];
      setState(() {
        _posts = postsData.map((p) => {
          'id': p['id'],
          'category': p['category'] ?? 'Pour vous',
          'author': p['author_name'] ?? 'Inconnu',
          'handle': p['created_at_relative'] ?? 'récemment',
          'avatarUrl': p['author_avatar_url'],
          'avatarColor': _getCategoryColor(p['category']),
          'content': p['content'] ?? '',
          'product': p['product_name'],
          'productBadge': p['product_trend'],
          'productColor': Colors.green,
          'imageUrl': p['image_url'],
          'imageColor': Colors.blue,
          'likes': p['likes_count'] ?? 0,
          'comments': p['comments_count'] ?? 0,
          'shares': p['shares_count'] ?? 0,
          'created_at': p['created_at_formatted'], // Assuming this is available
        }).toList();
        
        // Extract unique members from posts
        _activeMembers = [];
        final Set<String> seenAuthors = {};
        for (var post in _posts) {
          final author = post['author'] as String;
          if (!seenAuthors.contains(author)) {
            seenAuthors.add(author);
            _activeMembers.add({
              'name': author,
              'color': post['avatarColor'],
              'avatarUrl': post['avatarUrl'],
            });
          }
        }
        
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Erreur lors du chargement des posts';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _activeMembers = [];

  Color _getCategoryColor(String? cat) {
    if (cat == 'Populaires') return Colors.blue;
    if (cat == 'Suivis') return Colors.purple;
    return Colors.orange;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  static const List<String> _trends = [
    '#Auto Tech', '#175%', '#Macbook', '#195%'
  ];



  List<Map<String, dynamic>> get _filteredPosts {
    if (_tabIndex == 0) return _posts;
    // Map index to internal category keys
    String category = _tabIndex == 1 ? 'Populaires' : 'Suivis';
    return _posts.where((p) => p['category'] == category).toList();
  }

  String _getTranslated(String text) {
    if (text == 'Pour vous') return AppLocalizations.of(context)!.tab_for_you;
    if (text == 'Populaires') return AppLocalizations.of(context)!.tab_populaires;
    if (text == 'Suivis') return AppLocalizations.of(context)!.tab_suivis;
    if (text.startsWith('il y a')) {
      final hours = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      return AppLocalizations.of(context)!.post_time(hours);
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 11), textAlign: TextAlign.center),
                        ),
                      _buildStatsCard(),
                      _buildStoriesRow(context),
                      _buildTrendingTopics(),
                      _buildTabBar(),
                      _buildPostList(),
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
              currentIndex: -1, // Not a main tab
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
            'Communauté',
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/create_post'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Membres actifs', _stats['members_active'], Icons.people_outline),
          _buildStatVerticalDivider(),
          _buildStatItem('Publications', _stats['publications'], Icons.trending_up),
          _buildStatVerticalDivider(),
          _buildStatItem('Vos likes', _stats['vos_likes'], Icons.favorite_border),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildStatVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _buildStoriesRow(BuildContext context) {
    final user = Provider.of<SessionManager>(context).user;
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildStoryItem(
            'Vous', 
            user?.profilePicture ?? 'https://i.pravatar.cc/150?u=${user?.id ?? "me"}', 
            isMe: true
          ),
          _buildStoryItem('Sarah M', 'https://i.pravatar.cc/150?u=sarah'),
          _buildStoryItem('Alex D', 'https://i.pravatar.cc/150?u=alex'),
          _buildStoryItem('Marie L', 'https://i.pravatar.cc/150?u=marie'),
        ],
      ),
    );
  }

  Widget _buildStoryItem(String name, String url, {bool isMe = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(url),
                ),
              ),
              if (isMe)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTrendingTopics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sujets Tendances', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () {}, child: const Text('Voir tout', style: TextStyle(color: Colors.orange, fontSize: 12))),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTrendChip('#Audio Tech', '234', '+12%'),
                const SizedBox(width: 10),
                _buildTrendChip('#Montres', '189', '+8%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChip(String tag, String count, String trend) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Text(tag, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(' ($count)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 4),
          Text(trend, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Pour vous', 'Populaires', 'Suivis'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          bool isSelected = _tabIndex == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostList() {
    final filtered = _filteredPosts;
    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: Text('Aucune publication trouvée')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => _buildPostCard(filtered[i]),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          // Author row
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: post['avatarColor'] as Color,
                    backgroundImage: post['avatarUrl'] != null ? NetworkImage(post['avatarUrl'] as String) : null,
                    child: post['avatarUrl'] == null ? Text(
                      (post['author'] as String).split(' ').map((w) => w[0]).take(2).join(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ) : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['author'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(_getTranslated(post['handle'] as String), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.bookmark_border, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(
            post['content'] as String,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
          // Product chip
          if (post['product'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (post['productColor'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.trending_up, size: 14, color: post['productColor'] as Color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      post['product'] as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (post['productBadge'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (post['productColor'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        post['productBadge'] as String,
                        style: TextStyle(
                          color: post['productColor'] as Color,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          // Image
          if (post['imageUrl'] != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                post['imageUrl'] as String,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: (post['imageColor'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: post['imageColor'] as Color),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              _buildAction(Icons.favorite_border, '${post['likes'] ?? 0}'),
              const SizedBox(width: 20),
              _buildAction(Icons.chat_bubble_outline, '${post['comments'] ?? 0}'),
              const SizedBox(width: 20),
              _buildAction(Icons.share_outlined, '${post['shares'] ?? 0}'),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
