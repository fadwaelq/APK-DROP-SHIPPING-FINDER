import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Trouvez les meilleurs produits',
      'subtitle': 'Analysez des milliers de produits et trouvez ceux qui ont le meilleur potentiel de vente',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Analyse de rentabilité',
      'subtitle': 'Évaluez la rentabilité potentielle de chaque produit avec nos outils avancés',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Gagnez du temps',
      'subtitle': 'Automatisez la recherche de produits pour vous concentrer sur la croissance',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final item = _onboardingData[index];
                  return Padding(
                    padding: AppTheme.screenPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.lightGray,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 120,
                                color: AppTheme.secondaryOrange,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXL),
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: AppTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            item['subtitle']!,
                            textAlign: TextAlign.center,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.secondaryOrange
                              : AppTheme.mediumGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage == _onboardingData.length - 1)
                    SizedBox(
                      width: 120,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to login screen
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text('Commencer'),
                      ),
                    )
                  else
                    SizedBox(
                      width: 120,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                        child: const Text('Suivant'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}