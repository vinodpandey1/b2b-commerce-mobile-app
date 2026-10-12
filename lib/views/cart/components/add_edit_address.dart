import 'package:EazySupplies/core/components/shopping_app_bar.dart';
import 'package:EazySupplies/core/utils/responsive.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:EazySupplies/core/constants/apiClients.dart';
import 'package:EazySupplies/core/constants/api_config.dart';
import 'package:EazySupplies/core/constants/app_defaults.dart';
import 'package:EazySupplies/core/models/userModel.dart';

class AddEditAddressPage extends StatefulWidget {
  final Address? existingAddress;

  const AddEditAddressPage({super.key, this.existingAddress});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _streetCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _postalCtrl;

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.existingAddress?.name ?? '');
    _streetCtrl =
        TextEditingController(text: widget.existingAddress?.address ?? '');
    _cityCtrl = TextEditingController(text: widget.existingAddress?.city ?? '');
    _postalCtrl =
        TextEditingController(text: widget.existingAddress?.zipcode ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      if (widget.existingAddress != null) "id": widget.existingAddress!.id,
      "name": _nameCtrl.text.trim(),
      "address": _streetCtrl.text.trim(),
      "city": _cityCtrl.text.trim(),
      "zipcode": _postalCtrl.text.trim(),
    };

    try {
      // Use jsonEncode to ensure proper JSON
      final data = jsonEncode(payload);

      if (widget.existingAddress != null) {
        await ApiClient.dio.put(
          ApiConfig.addressPost,
          data: data,
          options: Options(headers: {"Content-Type": "application/json"}),
        );
      } else {
        await ApiClient.dio.post(
          ApiConfig.addressPost,
          data: data,
          options: Options(headers: {"Content-Type": "application/json"}),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Address save error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save address")),
      );
    }
  }

  // Future<void> _submitForm() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final payload = {
  //     if(widget.existingAddress != null)
  //       "id": widget.existingAddress!.id,
  //     "name": _nameCtrl.text.trim(),
  //     "address": _streetCtrl.text.trim(),
  //     "city": _cityCtrl.text.trim(),
  //     "zipcode": _postalCtrl.text.trim().toString(),
  //   };

  //   try {
  //     print(payload);
  //     if (widget.existingAddress != null) {
  //       await ApiClient.dio.put(
  //         ApiConfig.address,
  //         data: payload,
  //       );
  //     } else {
  //       await ApiClient.dio.post(
  //         ApiConfig.address,
  //         data: payload,
  //       );
  //     }

  //     Navigator.pop(context, true);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Failed to save address")),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAddress != null;

    return Scaffold(
      appBar: ShoppingAppBar(
        title: Text(isEditing ? "Edit Address" : "Add Address"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Address Details",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: Responsive.hp(context, 16 / 8)),
              _buildTextField(
                label: "Name",
                hint: "Enter full name",
                controller: _nameCtrl,
              ),
              _buildTextField(
                label: "Street Address",
                hint: "House no, street, area",
                controller: _streetCtrl,
              ),
              _buildTextField(
                label: "City",
                hint: "Enter city",
                controller: _cityCtrl,
              ),
              _buildTextField(
                label: "Postal Code",
                hint: "Enter postal code",
                controller: _postalCtrl,
                keyboard: TextInputType.number,
              ),
              SizedBox(height: Responsive.hp(context, 24 / 8)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(isEditing ? "Update Address" : "Save Address"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Text field with label ABOVE input
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: Responsive.hp(context, 6 / 8)),

          /// Input
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
