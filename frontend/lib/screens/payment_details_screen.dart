import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'payment_success_screen.dart';
import '../services/api_service.dart';

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cvvController = TextEditingController();
  String? _selectedMonth;
  String? _selectedYear;

  final List<String> _months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
  final List<String> _years = List.generate(10, (index) => (DateTime.now().year + index).toString());

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() => setState(() {}));
    _cardHolderController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2E8), // Light peach background
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Carte Bancaire',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Card Visual
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF7931E), Color(0xFFFFB347)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Carte de Paiement',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                          const Text(
                            'VISA',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _cardNumberController.text.isEmpty 
                            ? '6230  4567  2345  5678' 
                            : _cardNumberController.text.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)}  "),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _cardHolderController.text.isEmpty ? 'Nom & Prenom' : _cardHolderController.text.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${_selectedMonth ?? "12"}/${_selectedYear?.substring(2) ?? "25"}',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildInputLabel(Icons.credit_card, 'Numéro de carte'),
                const SizedBox(height: 12),
                _buildModernTextField(
                  controller: _cardNumberController,
                  hintText: 'Saisissez le numéro de carte à 12 chiffres',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel(Icons.calendar_today, 'Valable jusqu\'au'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildModernDropdown(
                                  hint: 'Mois',
                                  value: _selectedMonth,
                                  items: _months,
                                  onChanged: (val) => setState(() => _selectedMonth = val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildModernDropdown(
                                  hint: 'Année',
                                  value: _selectedYear,
                                  items: _years,
                                  onChanged: (val) => setState(() => _selectedYear = val),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel(Icons.lock_outline, 'CVV'),
                          const SizedBox(height: 12),
                          _buildModernTextField(
                            controller: _cvvController,
                            hintText: 'CVV',
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.grey, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputLabel(Icons.person_outline, 'Nom du titulaire de la carte'),
                const SizedBox(height: 12),
                _buildModernTextField(
                  controller: _cardHolderController,
                  hintText: 'Nom sur la carte',
                ),
                const SizedBox(height: 48),
                Center(
                  child: SizedBox(
                    width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {}); // Show loading if needed
                          
                          final result = await ApiService().addPaymentMethod({
                            'card_type': 'VISA',
                            'last_four': _cardNumberController.text.length >= 4 
                                ? _cardNumberController.text.substring(_cardNumberController.text.length - 4)
                                : '0000',
                            'expiry_date': '${_selectedMonth ?? "12"}/${_selectedYear?.substring(2) ?? "25"}',
                            'holder_name': _cardHolderController.text,
                          });

                          if (mounted) {
                            if (result['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Carte enregistrée avec succès'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Push replacement to force refresh of the management screen
                              Navigator.pushReplacementNamed(context, '/payment_management');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur : ${result['message']}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7931E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 4,
                          shadowColor: Colors.orange.withOpacity(0.4),
                        ),
                        child: const Text(
                          'Ajouter la carte',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ),
                ),
              ],
            ),
          ),
          // Floating Bottom Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: -1,
              onTap: (index) {
                // The CustomBottomNavBar handles logic
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFF7931E), size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
