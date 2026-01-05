import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bienvenue sur DropShippingFinder',
      description:
          'Trouvez les produits gagnants pour votre business de dropshipping en quelques clics',
      imageUrl:
          'assets/images/Immagine WhatsApp 2025-11-08 ore 00.55.42_cb654da5.jpg',
    ),
    OnboardingPage(
      title: 'Analyse IA Puissante',
      description:
          'Notre intelligence artificielle analyse des milliers de produits pour vous',
      imageUrl:
          'assets/images/Immagine WhatsApp 2025-11-08 ore 00.55.42_cb654da5.jpg',
    ),
    OnboardingPage(
      title: 'Gagnez du Temps',
      description:
          'Concentrez-vous sur votre business pendant que nous trouvons les meilleurs produits',
      imageUrl:
          'assets/images/Immagine WhatsApp 2025-11-08 ore 00.55.42_cb654da5.jpg',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppTheme.spacingXL),

            // Logo and Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * .5,
                  child: Image.asset(
                    'assets/images/logo.png', // Create or download a PNG logo
                    fit: BoxFit.contain,
                  ),
                )
              ],
            ),

            SizedBox(height: AppTheme.spacingXL),

            // Welcome Text
            Text(
              _pages[_currentPage].title,
              style: AppTheme.titleLarge.copyWith(
                
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppTheme.spacingL),

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
              child: Text(
                _pages[_currentPage].description,
                style: AppTheme.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: AppTheme.spacingXL),

            // Image Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusLarge),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Image.asset(
                          _pages[index].imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to network image if asset not found
                            return Image.network(
                              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800&h=600&fit=crop&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightGray,
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.borderRadiusLarge),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 80,
                                      color: AppTheme.mediumGray,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: AppTheme.spacingXL),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingXS),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primaryOrange
                        : AppTheme.mediumGray,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppTheme.spacingXL),

            // Start Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Commencer',
                        style: AppTheme.labelLarge.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacingS),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imageUrl;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}
