import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class ParrainageScreen extends StatefulWidget {
  const ParrainageScreen({super.key});

  @override
  State<ParrainageScreen> createState() => _ParrainageScreenState();
}

class _ParrainageScreenState extends State<ParrainageScreen> {
  final ApiService _apiService = ApiService();

  // ── Referral stats
  String _referralCode = '...';
  String _referralLink = '';
  String _totalReferrals = '0';
  String _pointsEarned = '0';

  // ── Leaderboard
  List<Map<String, dynamic>> _leaderboard = [];

  // ── Rewards tiers
  List<Map<String, dynamic>> _rewardTiers = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DATA
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Fire all 3 calls in parallel
    final results = await Future.wait([
      _apiService.getReferrals(),          // index 0
      _apiService.getReferralLeaderboard(), // index 1
      _apiService.getReferralRewards(),     // index 2
    ]);

    final referralsRes   = results[0];
    final leaderboardRes = results[1];
    final rewardsRes     = results[2];

    // ── Referral profile
    if (referralsRes['success'] == true) {
      final data = referralsRes['data'] ?? referralsRes;
      setState(() {
        _referralCode   = data['referral_code']   ?? 'NON-GÉNÉRÉ';
        _referralLink   = data['referral_link']   ?? '';
        _totalReferrals = (data['total_referrals'] ?? data['count'] ?? 0).toString();
        _pointsEarned   = (data['points']          ?? data['points_earned'] ?? 0).toString();
      });
    } else {
      setState(() => _error = referralsRes['message'] ?? 'Erreur chargement parrainage');
    }

    // ── Leaderboard
    if (leaderboardRes['success'] == true) {
      final raw = leaderboardRes['data'];
      if (raw is List) {
        setState(() {
          _leaderboard = List<Map<String, dynamic>>.from(
            raw.asMap().entries.map((e) {
              final item = Map<String, dynamic>.from(e.value);
              item['rank'] = e.key + 1;
              return item;
            }),
          );
        });
      }
    }

    // ── Reward tiers
    if (rewardsRes['success'] == true) {
      final raw = rewardsRes['data'];
      if (raw is List) {
        setState(() {
          _rewardTiers = List<Map<String, dynamic>>.from(raw);
        });
      }
    }

    setState(() => _isLoading = false);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _sendInvite(String email) async {
    final res = await _apiService.sendReferralInvite(email: email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['success'] == true
            ? 'Invitation envoyée à $email !'
            : res['message'] ?? 'Erreur lors de l\'envoi'),
        backgroundColor: res['success'] == true ? AppColors.primary : Colors.red,
      ),
    );
  }

  Future<void> _claimReward(String rewardId, String label) async {
    final res = await _apiService.claimReferralReward(rewardId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['success'] == true
            ? 'Récompense « $label » activée !'
            : res['message'] ?? 'Erreur lors de l\'activation'),
        backgroundColor: res['success'] == true ? AppColors.primary : Colors.red,
      ),
    );
    if (res['success'] == true) _fetchData(); // refresh
  }

  void _showInviteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Inviter un ami', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Email de votre ami',
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final email = controller.text.trim();
              Navigator.pop(ctx);
              if (email.isNotEmpty) _sendInvite(email);
            },
            child: const Text('Envoyer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHowItWorks(context),
                    const SizedBox(height: 20),
                    _buildReferralCode(context),
                    const SizedBox(height: 20),
                    if (_leaderboard.isNotEmpty) ...[
                      _buildLeaderboard(context),
                      const SizedBox(height: 20),
                    ],
                    if (_rewardTiers.isNotEmpty) ...[
                      _buildRewardTiers(context),
                      const SizedBox(height: 20),
                    ],
                    _buildActionButtons(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.referral_rewards,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.people,
                    label: AppLocalizations.of(context)!.active_referrals,
                    value: _totalReferrals,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star,
                    label: AppLocalizations.of(context)!.points_earned,
                    value: _pointsEarned,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.info_outline,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(l10n.how_it_works,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          _buildStep('1', l10n.referral_step_1),
          _buildStep('2', l10n.referral_step_2),
          _buildStep('3', l10n.referral_step_3),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCode(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.your_referral_code,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          // Code display
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _referralCode,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.primary),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(l10n.code_copied),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.copy,
                        color: AppColors.primary, size: 20),
                  ),
                ),
              ],
            ),
          ),
          // Link (if available)
          if (_referralLink.isNotEmpty) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _referralLink));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Lien copié !'),
                  backgroundColor: AppColors.primary,
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _referralLink,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.copy, color: AppColors.primary, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Leaderboard (from getReferralLeaderboard)
  Widget _buildLeaderboard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.leaderboard, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(l10n.my_referrals,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const SizedBox(
                    width: 30,
                    child: Text('#',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey))),
                Expanded(
                    child: Text(l10n.name_label,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey))),
                Text(l10n.points_label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._leaderboard.take(10).map((entry) => _buildLeaderboardRow(entry)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(Map<String, dynamic> entry) {
    final rank   = entry['rank'] as int? ?? 0;
    final name   = entry['name'] as String?   ?? entry['username'] as String? ?? 'Utilisateur';
    final date   = entry['date'] as String?   ?? entry['joined_at'] as String? ?? '';
    final points = entry['points']?.toString() ?? entry['points_earned']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: rank == 1 ? AppColors.primary.withOpacity(0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank == 1 ? AppColors.primary : Colors.grey),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                if (date.isNotEmpty)
                  Text(date,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          if (points.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(points,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
        ],
      ),
    );
  }

  // ── Reward tiers (from getReferralRewards)
  Widget _buildRewardTiers(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Paliers de récompenses',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          ..._rewardTiers.map((tier) => _buildRewardTierRow(tier)),
        ],
      ),
    );
  }

  Widget _buildRewardTierRow(Map<String, dynamic> tier) {
    final id          = tier['id']?.toString() ?? '';
    final label       = tier['label'] as String? ?? tier['name'] as String? ?? 'Récompense';
    final description = tier['description'] as String? ?? '';
    final claimed     = tier['claimed'] as bool? ?? false;
    final threshold   = tier['threshold']?.toString() ?? tier['required_referrals']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: claimed
            ? Colors.grey[100]
            : AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: claimed
                ? Colors.grey[300]!
                : AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: claimed
                  ? Colors.grey[200]
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              claimed ? Icons.check_circle : Icons.card_giftcard,
              color: claimed ? Colors.grey : AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: claimed ? Colors.grey : Colors.black87)),
                if (description.isNotEmpty)
                  Text(description,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
                if (threshold != null)
                  Text('Requis : $threshold filleuls',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          if (!claimed && id.isNotEmpty)
            TextButton(
              onPressed: () => _claimReward(id, label),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
              child: const Text('Réclamer',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          if (claimed)
            const Text('Activé',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // ── Bottom action buttons
  Widget _buildActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shareText = _referralLink.isNotEmpty
        ? l10n.referral_share_msg(_referralLink)
        : l10n.referral_share_msg(_referralCode);

    return Column(
      children: [
        // Invite button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showInviteDialog,
            icon: const Icon(Icons.person_add_outlined, color: AppColors.primary),
            label: const Text(
              'Inviter un ami par email',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Share button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Share.share(shareText),
            icon: const Icon(Icons.share, color: Colors.white),
            label: Text(
              l10n.share_code_btn,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
