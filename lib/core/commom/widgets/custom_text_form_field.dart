// lib/core/commom/widgets/custom_text_form_field.dart
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
    this.obscureText,                // controlled obscure flag (optional)
    this.maxLines = 1,
    this.radius,
    this.prefixIcon,
    this.prefixIconConstraints,      // <-- NEW
    this.onChange,
    this.onTap,
    this.readOnly = false,
    this.inputDecoration,
    this.suffixIcon,
    this.isPhoneField = false,
    this.contentPadding,
    this.onFieldSubmitted,
    this.keyboardType,               // <-- NEW
    this.textAlign,                  // <-- NEW
  });

  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool? obscureText;           // controlled by parent if provided
  final int maxLines;
  final InputDecoration? inputDecoration;
  final double? radius;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints; // <-- NEW
  final Widget? suffixIcon;
  final Function(String)? onChange;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool isPhoneField;
  final EdgeInsetsGeometry? contentPadding;
  final void Function(String)? onFieldSubmitted;
  final TextInputType? keyboardType; // <-- NEW
  final TextAlign? textAlign;        // <-- NEW

  @override
  State<CustomTexFormField> createState() => _CustomTexFormFieldState();
}

class _CustomTexFormFieldState extends State<CustomTexFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // If parent passes obscureText → controlled; else derive from isPassword + local state
    final effectiveObscure =
        widget.obscureText ?? (widget.isPassword ? _obscureText : false);

    final baseDeco = widget.inputDecoration ??
        InputDecoration(
          prefixIcon: widget.prefixIcon,
          filled: true,
          labelStyle: TextStyle(
            color: const Color(0xff616161),
            fontSize: getWidth(14),
            fontWeight: FontWeight.w500,
          ),
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Color(0xFF84828E), fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(widget.radius ?? 8)),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(widget.radius ?? 8)),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(widget.radius ?? 8)),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(widget.radius ?? 8)),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(widget.radius ?? 8)),
            borderSide: const BorderSide(color: Colors.orange),
          ),
        );

    final suffix = widget.suffixIcon ??
        (widget.isPassword && widget.obscureText == null
            ? IconButton(
          icon: Icon(
            effectiveObscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.blue.withAlpha(150),
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        )
            : null);

    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: widget.readOnly,
      onChanged: widget.onChange,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      maxLines: widget.maxLines,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: effectiveObscure,
      obscuringCharacter: '•',
      keyboardType: widget.keyboardType ??
          (widget.isPassword ? TextInputType.visiblePassword : TextInputType.text), // <-- fixed
      textAlign: widget.textAlign ?? TextAlign.start,                                   // <-- fixed
      enableSuggestions: !effectiveObscure,
      autocorrect: !effectiveObscure,
      style: getTextStyleMsrt(),
      decoration: baseDeco.copyWith(
        suffixIcon: suffix,
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: widget.prefixIconConstraints, // <-- fixed
      ),
    );
  }
}
