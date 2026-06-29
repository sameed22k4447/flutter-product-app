import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../product/product_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login form submission
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      // Navigate to product list on successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProductListScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // App logo/header
                Icon(Icons.inventory_2,
                    size: 72, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Sign in to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Password is required';
                    if (val.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 16),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}