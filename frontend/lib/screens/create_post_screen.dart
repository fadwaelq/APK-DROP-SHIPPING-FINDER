import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String _selectedAudience = 'Audiance'; // 'Audiance', 'Privé', 'Suivis'
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _publishPost() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un message')),
      );
      return;
    }

    final result = await ApiService().createCommunityPost({
      'content': _contentController.text,
      'visibility': _selectedAudience.toLowerCase() == 'audiance' ? 'public' : _selectedAudience.toLowerCase(),
    });

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post publié avec succès !')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${result['message']}')),
        );
      }
    }
  }

  Future<void> _pickMedia(bool isVideo) async {
    final XFile? file = await (isVideo 
        ? _picker.pickVideo(source: ImageSource.gallery) 
        : _picker.pickImage(source: ImageSource.gallery));
    
    if (file != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isVideo ? "Vidéo" : "Image"} sélectionnée: ${file.name}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE8D1), // Light orange background from mockup
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Communauté',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // User Profile
                    const SizedBox(height: 30),
                    Consumer<SessionManager>(
                      builder: (context, session, _) {
                        final user = session.user;
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: user?.profilePicture != null 
                                  ? NetworkImage(user!.profilePicture!) 
                                  : NetworkImage('https://i.pravatar.cc/150?u=${user?.id ?? "unknown"}'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user?.fullName ?? 'Utilisateur',
                              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Audience Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAudienceButton('Audiance', Icons.public, Colors.orange),
                        const SizedBox(width: 12),
                        _buildAudienceButton('Privé', Icons.lock, Colors.white, textColor: Colors.black),
                        const SizedBox(width: 12),
                        _buildAudienceButton('Suivis', Icons.person, Colors.white, textColor: Colors.black),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Content field
                    Container(
                      height: 180,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Que voulez-vous dire ? Partager votre avis sur un produit',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Media buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMediaButton('Photos', Icons.image_outlined, onTap: () => _pickMedia(false)),
                        const SizedBox(width: 12),
                        _buildMediaButton('Video', Icons.videocam_outlined, onTap: () => _pickMedia(true)),
                        const SizedBox(width: 12),
                        _buildMediaButton('Produit', Icons.sell_outlined, onTap: () {
                          // TODO: Implement product attachment
                        }),
                      ],
                    ),
                    const SizedBox(height: 60),
                    // Publish Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _publishPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Publier',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
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

  Widget _buildAudienceButton(String label, IconData icon, Color bgColor, {Color textColor = Colors.white}) {
    bool isSelected = _selectedAudience == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedAudience = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 16, 
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton(String label, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
