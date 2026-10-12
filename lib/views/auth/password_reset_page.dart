import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/apiClients.dart';
import '../../core/constants/api_config.dart';
import '../../core/constants/constants.dart';
import '../../core/enums/login_type.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/responsive.dart';

class PasswordResetPage extends StatefulWidget {
  final String email;

  const PasswordResetPage({super.key, required this.email});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        return (data['message'] ??
                data['error'] ??
                'Unable to reset the password')
            .toString();
      }
    }
    return 'Unable to reset the password. Please try again.';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Use at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include an uppercase letter and a number';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.dio.get(
        ApiConfig.passwordReset,
        queryParameters: {
          'action': 'forgotPassword',
          'email': widget.email,
          'otp': _otpController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.data?['message']?.toString() ??
                'Password updated successfully',
          ),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
        arguments: LoginType.email,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    try {
      final response = await ApiClient.dio.get(
        ApiConfig.passwordReset,
        queryParameters: {
          'action': 'forgetpasswordotp',
          'email': widget.email,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.data?['message']?.toString() ??
                'A new verification code was sent',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('New Password'),
        backgroundColor: AppColors.scaffoldBackground,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(AppDefaults.margin),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDefaults.padding,
              vertical: AppDefaults.padding * 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppDefaults.borderRadius,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Set a new password',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  Text('Enter the code sent to ${widget.email}.'),
                  const SizedBox(height: AppDefaults.padding * 2),
                  const Text('Six-digit verification code'),
                  SizedBox(height: Responsive.hp(context, 1)),
                  TextFormField(
                    controller: _otpController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (value) =>
                        RegExp(r'^\d{6}$').hasMatch(value ?? '')
                            ? null
                            : 'Enter the six-digit code',
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  const Text('New password'),
                  SizedBox(height: Responsive.hp(context, 1)),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.next,
                    validator: _validatePassword,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _showPassword = !_showPassword,
                        ),
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  const Text('Confirm password'),
                  SizedBox(height: Responsive.hp(context, 1)),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.done,
                    validator: (value) => value == _passwordController.text
                        ? null
                        : 'Passwords do not match',
                    onFieldSubmitted: (_) => _resetPassword(),
                  ),
                  const SizedBox(height: AppDefaults.padding * 2),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update password'),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: _isResending ? null : _resendCode,
                      child: Text(
                        _isResending ? 'Sending…' : 'Resend verification code',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
