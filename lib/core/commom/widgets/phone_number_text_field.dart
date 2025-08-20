
import 'package:flutter/material.dart';

import '../../utils/constants/app_colors.dart';
import '../styles/get_text_style.dart';
import 'custom_text.dart';


class PhoneNumberTextField extends StatefulWidget {
  const PhoneNumberTextField({
    super.key,
    this.hintText,
    this.controller,
    this.validator,
    this.radius = 4.0,
    this.onChange,
    this.onTap,
    this.readOnly = false,
  });

  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double radius;
  final Function(String)? onChange;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  State<PhoneNumberTextField> createState() => _PhoneNumberTextFieldState();
}

class _PhoneNumberTextFieldState extends State<PhoneNumberTextField> {
  String _selectedCountryCode = '+34';

  static const Map<String, int> countryPhoneLengths = {
    '+880': 10,
    '+1': 10,
    '+44': 10,
    '+91': 10,
    '+61': 9,
    '+49': 11,
    '+33': 9,
    '+81': 10,
    '+55': 11,
    '+34': 9,
  };

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: widget.readOnly,
      onChanged: widget.onChange,
      onTap: widget.onTap,
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: TextInputType.phone,
      style: getTextStyleMsrt(),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isDense: true,
              value: _selectedCountryCode,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedCountryCode = newValue);
                }
              },
              selectedItemBuilder: (context) =>
                  countryPhoneLengths.keys.map((code) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.flip(
                        flipX: true,
                        child: const Icon(Icons.arrow_drop_down,
                            color: Colors.black),
                      ),
                      CustomText(
                        text: "($_selectedCountryCode)",
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ],
                  ),
                );
              }).toList(),
              items: countryPhoneLengths.keys.map((code) {
                return DropdownMenuItem(
                  value: code,
                  child: CustomText(
                    text: code,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                );
              }).toList(),
              icon: const SizedBox.shrink(),
            ),
          ),
        ),
        filled: true,
        fillColor: AppColors.white,
        labelStyle: getTextStyleMsrt(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
        hintText: widget.hintText,
        hintStyle:
            TextStyle(color: const Color(0xFF84828E), fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
          borderSide: const BorderSide(color: Color(0xFFE2E2E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
          borderSide: const BorderSide(color: Color(0xFFE2E2E6), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
          borderSide: const BorderSide(color: Colors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }
}
