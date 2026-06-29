import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Send password reset email
  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.forgotPassword(_emailController.text);
      if (mounted) setState(() => _emailSent = true);
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
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _emailSent
              // Success state — show confirmation message
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mark_email_read,
                        size: 80, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'Reset Email Sent!',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your inbox at ${_emailController.text} for the reset link.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Login'),
                    ),
                  ],
                )
              // Input state — show email form
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.lock_reset, size: 72),
                      const SizedBox(height: 16),
                      const Text(
                        'Reset Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your email and we\'ll send you a reset link.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Email is required';
                          if (!val.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendResetEmail,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Text('Send Reset Link'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}