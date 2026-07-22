import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.errorText,
    required this.prefixIcon,
    super.key,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueListenable<String?> errorText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effectiveKeyboardType =
        kIsWeb && keyboardType == TextInputType.emailAddress
        ? TextInputType.text
        : keyboardType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: effectiveKeyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          obscureText: obscureText,
          autocorrect: false,
          enableSuggestions: !obscureText,
          onChanged: onChanged,
          onSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, size: 20),
            suffixIcon: suffixIcon,
          ),
        ),
        SizedBox(
          height: 20,
          child: ValueListenableBuilder<String?>(
            valueListenable: errorText,
            builder: (context, error, child) {
              if (error == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  error,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
