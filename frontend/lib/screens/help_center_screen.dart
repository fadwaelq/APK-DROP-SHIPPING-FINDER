import 'package:flutter/material.dart';
import 'package:dropshipping_app/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'support_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.support_home_title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.support_home_subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    context,
                    icon: Icons.email_outlined,
                    title: l10n.send_email_title,
                    subtitle: l10n.send_email_subtitle,
                    onTap: () {
                      Navigator.pushNamed(context, '/contact_support');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildContactCard(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: l10n.chat_with_agent_title,
                    subtitle: l10n.chat_with_agent_subtitle,
                    onTap: () {
                      // Logic for chat can be added here
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context,
              icon: Icons.confirmation_number_outlined,
              title: 'Mes tickets',
              subtitle: 'Consulter et répondre',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (ctx) => DraggableScrollableSheet(
                    initialChildSize: 0.75,
                    minChildSize: 0.4,
                    maxChildSize: 0.92,
                    expand: false,
                    builder: (_, scrollController) => FutureBuilder<Map<String, dynamic>>(
                      future: ApiService().getSupportTickets(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final res = snapshot.data!;
                        if (res['success'] != true) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(res['message']?.toString() ?? 'Erreur chargement tickets',
                                style: const TextStyle(color: Colors.red)),
                          );
                        }
                        final data = res['data'];
                        final list = data is List
                            ? data
                            : (data is Map ? (data['results'] ?? data['data'] ?? const []) : const []);
                        final tickets = List<Map<String, dynamic>>.from(list as List);
                        if (tickets.isEmpty) {
                          return ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(20),
                            children: const [
                              Text('Aucun ticket pour le moment.', style: TextStyle(color: Colors.grey)),
                            ],
                          );
                        }
                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: tickets.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final t = tickets[i];
                            final id = (t['id'] ?? t['ticket_id'] ?? '').toString();
                            final subject = (t['subject'] ?? t['category'] ?? 'Ticket').toString();
                            final status = (t['status'] ?? '').toString();
                            return ListTile(
                              tileColor: const Color(0xFFFFEBD8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              leading: const Icon(Icons.support_agent, color: AppColors.primary),
                              title: Text('#$id • $subject',
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: status.isEmpty ? null : Text(status, style: const TextStyle(fontSize: 11)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SupportScreen(ticketId: id),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              l10n.faq_title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildFaqItem(l10n.faq_q1, l10n.faq_a1),
                  _buildFaqItem(l10n.faq_q2, l10n.faq_a2),
                  _buildFaqItem(l10n.faq_q3, l10n.faq_a3),
                  _buildFaqItem(l10n.faq_q4, l10n.faq_a4),
                  _buildFaqItem(l10n.faq_q5, l10n.faq_a5, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBD8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, {bool isLast = false}) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
