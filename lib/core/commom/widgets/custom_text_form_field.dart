import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:flutter/material.dart';

import '../../utils/constants/app_colors.dart';
import '../styles/get_text_style.dart';

class CustomTexFormField extends StatefulWidget {
  const CustomTexFormField({
    super.key,
    this.hintText,
    this.controller,
    this.validator,
    this.isPassword = false,
    this.obscureText, // <-- ADDED: New optional parameter
    this.maxLines = 1,
    this.radius,
    this.prefixIcon,
    this.onChange,
    this.onTap,
    this.readOnly = false,
    this.inputDecoration,
    this.suffixIcon,
    this.isPhoneField = false,
    this.contentPadding,
    this.onFieldSubmitted,
  });

  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool? obscureText; // <-- ADDED: New optional parameter
  final int maxLines;
  final InputDecoration? inputDecoration;
  final double? radius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChange;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool isPhoneField;
  final EdgeInsetsGeometry? contentPadding;
  final void Function(String)? onFieldSubmitted;

  @override
  State<CustomTexFormField> createState() => _CustomTexFormFieldState();
}

class _CustomTexFormFieldState extends State<CustomTexFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: widget.readOnly,
      onChanged: widget.onChange,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      maxLines: widget.maxLines,
      controller: widget.controller,
      validator: widget.validator,
      // --- MODIFIED LOGIC ---
      // It prioritizes the new obscureText property if provided.
      // Otherwise, it falls back to the original isPassword logic.
      obscureText: widget.obscureText ?? (widget.isPassword ? _obscureText : false),
      keyboardType: widget.isPhoneField
          ? TextInputType.phone
          : TextInputType.text,
      style: getTextStyleMsrt(),
      decoration:
      widget.inputDecoration ??
          InputDecoration(
            prefixIcon: widget.prefixIcon,
            filled: true,
            //fillColor: Color(0xffFFFFFF),
            labelStyle: TextStyle(
              color: const Color(0xff616161),
              fontSize: getWidth(14),
              fontWeight: FontWeight.w500,
            ),
            contentPadding:
            widget.contentPadding ??
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Color(0xFF84828E), fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(widget.radius ?? 8),
              ),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(widget.radius ?? 8),
              ),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(widget.radius ?? 8),
              ),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(widget.radius ?? 8),
              ),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(widget.radius ?? 8),
              ),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.blue.withAlpha(150),
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : widget.suffixIcon,
          ),
    );
  }
}

