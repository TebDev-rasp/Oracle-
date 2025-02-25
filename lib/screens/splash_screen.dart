import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Remove the preload map data call since it's no longer needed
    // MapWidget().preloadMapData();

    // Set up navigation check
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasNavigated) {
        _hasNavigated = true;
        checkUserAndNavigate();
      }
    });

    // Start animation after brief delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void checkUserAndNavigate() {
    if (!mounted) return;
    
    final userProfile = Provider.of<UserProfileProvider>(context, listen: false);
    
    if (userProfile.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/oracle_wisdom.json',
          controller: _controller,
          onLoaded: (composition) {
            // Ensure we only start the animation if we haven't navigated
            if (!_hasNavigated && mounted) {
              _controller.forward();
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error_outline, size: 50);
          },
        ),
      ),
    );
  }
}