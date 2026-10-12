import 'package:form_field_validator/form_field_validator.dart';

class Validators {
  /// Email Validator
  static final email = EmailValidator(errorText: 'Enter a valid email address');

  /// Password Validator
  static final password = MultiValidator([
    RequiredValidator(errorText: 'Password is required'),
    MinLengthValidator(6, errorText: 'Password must be at least 6 digits long'),
    PatternValidator(
      r'^(\d{4,6}|(?=.*?[#?!@$%^&*-]).{6,})$',
      errorText: 'Enter valid OTP or strong password',
    )
  ]);

  static String? registrationPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Use at least 6 characters';
    if (!RegExp(r'[#?!@$%^&*-]').hasMatch(value)) {
      return 'Include at least one symbol: # ? ! @ \$ % ^ & * -';
    }
    return null;
  }

  /// Required Validator with Optional Field Name
  static RequiredValidator requiredWithFieldName(String? fieldName) =>
      RequiredValidator(errorText: '${fieldName ?? 'Field'} is required');

  /// Plain Required Validator
  static final required = RequiredValidator(errorText: 'Field is required');

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^[0-9]{10}$'); // basic 10-digit check
    if (!phoneRegex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  static String? gst(String? value) {
    if (value == null || value.isEmpty) return 'GST number is required';
    // GST regex: 2 digits state code, 10 chars PAN, 1 char entity, 1 char Z by default, 1 check digit
    final gstRegex = RegExp(
        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[A-Z0-9]{1}[Z]{1}[A-Z0-9]{1}$');
    if (!gstRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid GST number';
    }
    return null;
  }
}
