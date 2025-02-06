import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/mapbox_widget.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    MapboxWidget.preloadMapData();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        checkUserAndNavigate();
      }
    });

    // Add a slight delay before starting animation
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.forward();
    });
  }

  void checkUserAndNavigate() {
    final userProfile = Provider.of<UserProfileProvider>(context, listen: false);
    
    if (userProfile.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
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
            _controller.forward();
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error_outline, size: 50);
          },
        ),
      ),
    );
  }
}