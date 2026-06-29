import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';

/// Screen for changing password while logged in
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle change password form submission
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.updatePassword(_newPasswordController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Icon(Icons.lock_outline,
                    size: 72, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                const Text(
                  'Change Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your new password below',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // New password field
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  obscureText: _obscureNew,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Password is required';
                    if (val.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm new password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Please confirm your password';
                    if (val != _newPasswordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
