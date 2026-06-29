import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart';
import 'product/product_list_screen.dart';

/// Splash screen — checks if user is already logged in
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  /// Check auth state and navigate accordingly
  void _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2)); // Brief splash display

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            user != null ? const ProductListScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Product App',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}