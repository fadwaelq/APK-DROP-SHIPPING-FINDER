import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CommunauteScreen extends StatefulWidget {
  const CommunauteScreen({super.key});

  @override
  State<CommunauteScreen> createState() => _CommunauteScreenState();
}

class _CommunauteScreenState extends State<CommunauteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _tabIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const List<Map<String, dynamic>> _members = [
    {'name': 'Axel', 'color': Colors.orange},
    {'name': 'Qudir M.', 'color': Colors.blue},
    {'name': 'Liam G.', 'color': Colors.purple},
    {'name': 'Nindy', 'color': Colors.teal},
  ];

  static const List<String> _trends = [
    '#Auto Tech', '#175%', '#Macbook', '#195%'
  ];

  static final List<Map<String, dynamic>> _posts = [
    {
      'author': 'Garrid Marie',
      'handle': 'il y a 2h',
      'avatarUrl': 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
      'avatarColor': Colors.orange,
      'content':
          'J\'ai trouvé une nouvelle tendance incroyable ! Les casques audio avec réduction de bruit active que vos membres demandes. Le mondial explique il',
      'product': 'Casque Sans-Fil Premium',
      'productBadge': '+168%',
      'productColor': Colors.green,
      'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&auto=format&fit=crop',
      'imageColor': Colors.orange,
      'likes': 135,
      'comments': 23,
      'shares': 0,
    },
    {
      'author': 'Alex Dupuis',
      'handle': 'il y a 3h',
      'avatarUrl': 'https://i.pravatar.cc/150?u=a042581f4e29026024d',
      'avatarColor': Colors.blue,
      'content':
          'Quelqu\'un a vu les nouvelles connections "A" de cette semaine de fantable. Vos résultats 🎉',
      'product': null,
      'productBadge': null,
      'productColor': null,
      'imageUrl': null,
      'imageColor': null,
      'likes': 97,
      'comments': 11,
      'shares': 3,
    },
    {
      'author': 'Marie Landier',
      'handle': 'il y a 5h',
      'avatarUrl': 'https://i.pravatar.cc/150?u=a04258a2462d826712d',
      'avatarColor': Colors.purple,
      'content':
          'Astuce du jour : utilisez les filtres "Store Wolds Deal" pour trouver les produits qui vont cartonner sur les réseaux sociaux l',
      'product': null,
      'productBadge': null,
      'productColor': null,
      'imageUrl': null,
      'imageColor': null,
      'likes': 180,
      'comments': 34,
      'shares': 26,
    },
    {
      'author': 'Thomas Daumeau',
      'handle': 'il y a 6h',
      'avatarUrl': 'https://i.pravatar.cc/150?u=a042581f4e29026701d',
      'avatarColor': Colors.green,
      'content':
          'Mon premier produit offert "100 ventes" ! Merci à la communauté pour vos conseils 🙏 C\'est un moment magique !',
      'product': 'Accessoires Téléphone',
      'productBadge': '+190%',
      'productColor': Colors.green,
      'imageUrl': 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=800&auto=format&fit=crop',
      'imageColor': Colors.deepPurple,
      'likes': null,
      'comments': null,
      'shares': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildStats()),
          SliverToBoxAdapter(child: _buildTrendingTopics()),
          SliverToBoxAdapter(child: _buildTabBar()),
        ],
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _posts.length,
          itemBuilder: (ctx, i) => _buildPostCard(_posts[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
            'Communauté',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.add, color: AppColors.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Members stack + count
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 32,
                  child: Stack(
                    children: List.generate(_members.length, (i) {
                      return Positioned(
                        left: i * 18.0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: _members[i]['color'] as Color,
                          child: Text(
                            (_members[i]['name'] as String)[0],
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2,847', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Membres', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: Colors.grey[200]),
          Expanded(
            child: const Center(
              child: Column(
                children: [
                  Text('1,234', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('Publications', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 36, color: Colors.grey[200]),
          Expanded(
            child: const Center(
              child: Column(
                children: [
                  Text('98', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('En ligne', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTopics() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sujets Tendances', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _trends.map((t) {
              final isHighlight = t.contains('%');
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isHighlight ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: isHighlight ? Colors.green : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Plus doux', 'Populaires', 'Suivis'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = _tabIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.index = i;
                setState(() => _tabIndex = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: post['avatarColor'] as Color,
                backgroundImage: post['avatarUrl'] != null ? NetworkImage(post['avatarUrl'] as String) : null,
                child: post['avatarUrl'] == null ? Text(
                  (post['author'] as String).split(' ').map((w) => w[0]).take(2).join(),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['author'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(post['handle'] as String, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          // Content
          Text(post['content'] as String, style: const TextStyle(fontSize: 13, height: 1.5)),
          // Product chip
          if (post['product'] != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, size: 14, color: post['productColor'] as Color),
                      const SizedBox(width: 4),
                      Text(post['product'] as String, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (post['productBadge'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (post['productColor'] as Color).withOpacity(0.15),
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
          ],
          // Image
          if (post['imageUrl'] != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                post['imageUrl'] as String,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: (post['imageColor'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: post['imageColor'] as Color),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Actions
          if (post['likes'] != null)
            Row(
              children: [
                _buildAction(Icons.favorite_border, '${post['likes']}'),
                const SizedBox(width: 16),
                _buildAction(Icons.chat_bubble_outline, '${post['comments']}'),
                const SizedBox(width: 16),
                _buildAction(Icons.share_outlined, '${post['shares']}'),
                const Spacer(),
                const Text(
                  'Ajouter un commentaire...',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          if (post['likes'] == null)
            const Text(
              'Ajouter un commentaire...',
              style: TextStyle(color: Colors.grey, fontSize: 11),
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
