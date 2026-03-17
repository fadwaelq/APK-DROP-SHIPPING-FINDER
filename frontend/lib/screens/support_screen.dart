import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'support_success_screen.dart';

class SupportScreen extends StatefulWidget {
  /// Optionally pass a ticketId to show the "close ticket" option
  final String? ticketId;

  const SupportScreen({super.key, this.ticketId});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ApiService _apiService = ApiService();

  // ── Category list (from API)
  List<String> _categories = ['Problème Technique', 'Feedback', 'Question sur l\'abonnement', 'Autre'];
  String? _selectedSubject;
  bool _loadingCategories = true;

  final _messageController = TextEditingController();
  final _emailController   = TextEditingController();
  final _replyController   = TextEditingController();
  bool _isSending = false;
  bool _isReplying = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DATA
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _loadCategories() async {
    final res = await _apiService.getSupportCategories();
    if (!mounted) return;

    if (res['success'] == true) {
      final raw = res['data'];
      if (raw is List && raw.isNotEmpty) {
        final labels = raw
            .map<String>((c) =>
                (c['label'] as String?) ??
                (c['name'] as String?) ??
                c.toString())
            .toList();
        setState(() {
          _categories       = labels;
          _selectedSubject  = labels.first;
          _loadingCategories = false;
        });
        return;
      }
    }

    // Fallback to defaults
    setState(() {
      _selectedSubject  = _categories.first;
      _loadingCategories = false;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _sendTicket() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez décrire votre problème.')),
      );
      return;
    }
    setState(() => _isSending = true);

    final res = await _apiService.createSupportTicket({
      'subject' : _selectedSubject ?? _categories.first,
      'message' : _messageController.text.trim(),
      'email'   : _emailController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _isSending = false);

    if (res['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SupportSuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Erreur lors de l\'envoi.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _closeTicket() async {
    final id = widget.ticketId;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clore le ticket', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Êtes-vous sûr de vouloir marquer ce ticket comme résolu ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final res = await _apiService.closeTicket(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['success'] == true
          ? 'Ticket #$id clôturé avec succès.'
          : res['message'] ?? 'Erreur lors de la clôture.'),
      backgroundColor: res['success'] == true ? AppColors.primary : Colors.red,
    ));

    if (res['success'] == true) Navigator.pop(context);
  }

  Future<void> _replyToTicket() async {
    final id = widget.ticketId;
    if (id == null) return;
    final msg = _replyController.text.trim();
    if (msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un message.')),
      );
      return;
    }

    setState(() => _isReplying = true);
    final res = await _apiService.replyToSupportTicket(id, msg);
    if (!mounted) return;
    setState(() => _isReplying = false);

    if (res['success'] == true) {
      _replyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Réponse envoyée.'),
        backgroundColor: AppColors.primary,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Erreur lors de l’envoi.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contacter l\'Assistance',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Show "Close ticket" button only when a ticketId is passed
          if (widget.ticketId != null)
            TextButton.icon(
              onPressed: _closeTicket,
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.red, size: 18),
              label: const Text('Clore',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If viewing an existing ticket, show a banner
            if (widget.ticketId != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ticket #${widget.ticketId} — En cours',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reply box (uses POST /support/tickets/{id}/reply/)
              const Text('Répondre',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _replyController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Écrivez votre réponse...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isReplying ? null : _replyToTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isReplying
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text(
                          'Envoyer la réponse',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Center(
              child: Text(
                'Veuillez remplir les détails ci-dessous.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 32),

            // ── Subject (from getSupportCategories)
            const Text('Sujet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _loadingCategories
                ? const Center(
                    child: SizedBox(
                        height: 48,
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2))))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSubject,
                        isExpanded: true,
                        icon:
                            const Icon(Icons.keyboard_arrow_down),
                        items: _categories
                            .map((v) => DropdownMenuItem<String>(
                                  value: v,
                                  child: Text(v,
                                      style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedSubject = v),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),

            // ── Message
            const Text('Votre message',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Décrivez votre problème en détail...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            // ── Email
            const Text('Votre email',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'votre@email.com',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 48),

            // ── Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text(
                        'Envoyer la Demande',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
