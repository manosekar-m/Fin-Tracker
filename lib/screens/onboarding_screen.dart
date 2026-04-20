import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hive_service.dart';
import '../providers/transaction_provider.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedAvatar;

  // Premium Flat Vector Avatars (Icons8)
  final List<String> _avatars = [
    'https://img.icons8.com/color/480/user-male-circle--v1.png',
    'https://img.icons8.com/color/480/astronaut.png',
    'https://img.icons8.com/color/480/bear.png',
    'https://img.icons8.com/color/480/cat.png',
    'https://img.icons8.com/color/480/rubber-duck.png',
    'https://img.icons8.com/color/480/fox.png',
    'https://img.icons8.com/color/480/swan.png',
    'https://img.icons8.com/color/480/boy.png',
    'https://img.icons8.com/color/480/nerd.png',
    'https://img.icons8.com/color/480/ninja.png',
    'https://img.icons8.com/color/480/panda.png',
    'https://img.icons8.com/color/480/user-female-circle.png',
    'https://img.icons8.com/color/480/businesswoman.png',
  ];

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      if (_selectedAvatar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select an avatar to continue'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final settings = HiveService.getSettingsBox();
    await settings.put('isFirstRun', false);
    await settings.put('userAvatar', _selectedAvatar);
    
    if (mounted) {
      context.read<TransactionProvider>().completeOnboarding();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: provider.isDarkMode ? const Color(0xFF0F172A) : cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Standardized Header
            _buildTopNav(context, provider),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) => setState(() => _currentPage = page),
                children: [
                  _buildContentPage(
                    context: context,
                    imageUrl: 'https://img.icons8.com/fluency/480/wallet.png',
                    title: 'Empower Your Wallet',
                    description: 'Take charge of your financial journey with precision tracking and intuitive expense management.',
                  ),
                  _buildContentPage(
                    context: context,
                    imageUrl: 'https://img.icons8.com/fluency/480/analytics.png',
                    title: 'Data-Driven Insights',
                    description: 'Transform your spending habits into actionable insights with our premium analytics suite.',
                  ),
                  _buildAvatarSelectionSection(context, provider),
                ],
              ),
            ),
            
            // Shared Bottom Control Area (only for intro pages)
            if (_currentPage < 2)
              _buildBottomControls(context, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            )
          else
            const SizedBox(width: 48),
          
          Text(
            _currentPage == 2 ? 'Select Avatar' : 'Fin Tracker',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
          ),
          
          IconButton(
            icon: Icon(
              provider.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: provider.isDarkMode ? Colors.amber : cs.primary,
              size: 20,
            ),
            onPressed: () => provider.toggleDarkMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              3,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 6,
                width: _currentPage == index ? 32 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == index ? cs.primary : cs.outline.withAlpha(80),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPage({
    required BuildContext context,
    required String imageUrl,
    required String title,
    required String description,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(imageUrl, height: 240, fit: BoxFit.contain),
          const SizedBox(height: 60),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSelectionSection(BuildContext context, TransactionProvider provider) {
    final cs = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Text(
            'Choose a profile picture that best represents you. You can change it anytime from your profile settings.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        // Large Selection Preview at Top
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: provider.isDarkMode ? Colors.green.withAlpha(50) : cs.primaryContainer,
              border: Border.all(color: provider.isDarkMode ? Colors.green : cs.primary, width: 3),
            ),
            child: ClipOval(
              child: _selectedAvatar != null 
                ? Image.network(_selectedAvatar!, fit: BoxFit.cover)
                : Icon(Icons.person_outline_rounded, size: 60, color: cs.primary),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: _avatars.map((url) {
                final isSelected = _selectedAvatar == url;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = url),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? (provider.isDarkMode ? Colors.green : cs.primary) : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    padding: EdgeInsets.all(isSelected ? 3 : 0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.isDarkMode ? Colors.white12 : cs.surfaceContainerHighest,
                      ),
                      child: ClipOval(child: Image.network(url, fit: BoxFit.cover)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Large Save Button at Bottom
        Padding(
          padding: const EdgeInsets.all(30),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isDarkMode ? const Color(0xFF2E4C7C) : const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}
