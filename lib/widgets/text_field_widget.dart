import 'package:flutter/material.dart';
import 'package:rentrig/utils/app_colors.dart';

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;
  final bool obscureText;
  final bool showPasswordToggle;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.obscureText = false,
    this.showPasswordToggle = false,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late bool _isObscured;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: widget.enabled
            ? (_isFocused
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.03))
            : Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? AppColors.accent.withOpacity(0.6)
              : Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        enabled: widget.enabled,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        obscureText: _isObscured,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          labelStyle: TextStyle(
            color: _isFocused
                ? AppColors.accent
                : Colors.white.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          floatingLabelStyle: TextStyle(
            color: _isFocused
                ? AppColors.accent
                : Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 14,
          ),
          border: InputBorder.none,
          errorStyle: const TextStyle(
            color: AppColors.error,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: widget.showPasswordToggle
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: _isFocused
                        ? AppColors.accent
                        : Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
        ),
        validator: widget.validator,
      ),
    );
  }
}
