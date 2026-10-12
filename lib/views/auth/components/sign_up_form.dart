import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/constants.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/utils/validators.dart';
import 'already_have_accout.dart';
import '../../../core/routes/app_routes.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final gstCtrl = TextEditingController();

  bool loading = false;
  bool hidePassword = true;
  bool hideConfirmation = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    gstCtrl.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordCtrl.text != confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => loading = true);
    final url = Uri.parse(ApiConfig.userProfile);
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameCtrl.text.trim(),
          "email": emailCtrl.text.trim(),
          "phone": phoneCtrl.text.trim(),
          "countryCode": "91",
          "password": passwordCtrl.text,
          "gstn": gstCtrl.text.trim().toUpperCase(),
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Your account registered successfully!")),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        var message = 'Registration failed. Please try again.';
        try {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic>) {
            message = (body['message'] ?? body['error'] ?? message).toString();
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Unable to create the account. Check your connection and try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
        margin: const EdgeInsets.all(AppDefaults.margin),
        padding: const EdgeInsets.all(AppDefaults.padding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppDefaults.boxShadow,
          borderRadius: AppDefaults.borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: nameCtrl,
              validator: Validators.requiredWithFieldName('Name').call,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppDefaults.padding),
            const Text("Email"),
            const SizedBox(height: 8),
            TextFormField(
              controller: emailCtrl,
              validator: Validators.email.call,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("GST No"),
            const SizedBox(height: 8),
            TextFormField(
              controller: gstCtrl,
              validator: Validators.gst,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppDefaults.padding),
            const Text("Phone Number"),
            const SizedBox(height: 8),
            TextFormField(
              controller: phoneCtrl,
              validator: Validators.phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppDefaults.padding),
            const Text("Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordCtrl,
              validator: Validators.registrationPassword,
              obscureText: hidePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                helperText:
                    'Use at least 6 characters, including a symbol (# ? ! @ \$ % ^ & * -).',
                helperMaxLines: 3,
                errorMaxLines: 3,
                suffixIcon: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    tooltip: hidePassword ? 'Show password' : 'Hide password',
                    onPressed: () =>
                        setState(() => hidePassword = !hidePassword),
                    icon: Icon(hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDefaults.padding),
            const Text("Confirm Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: confirmPasswordCtrl,
              validator: (value) => value == null || value.isEmpty
                  ? 'Confirm your password'
                  : value != passwordCtrl.text
                      ? 'Passwords do not match'
                      : null,
              obscureText: hideConfirmation,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                suffixIcon: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    tooltip: hideConfirmation
                        ? 'Show confirmation password'
                        : 'Hide confirmation password',
                    onPressed: () =>
                        setState(() => hideConfirmation = !hideConfirmation),
                    icon: Icon(hideConfirmation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDefaults.padding),

            // 🔥 Keep your button, but connect API
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : registerUser,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign Up"),
              ),
            ),

            const AlreadyHaveAnAccount(),
            const SizedBox(height: AppDefaults.padding),
          ],
        ),
      ),
    );
  }
}
