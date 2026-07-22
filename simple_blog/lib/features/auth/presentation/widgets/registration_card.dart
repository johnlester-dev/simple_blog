import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_blog/features/auth/presentation/widgets/auth_brand_mark.dart';
import 'package:simple_blog/features/auth/presentation/widgets/auth_form_field.dart';

class RegistrationCard extends StatelessWidget {
  const RegistrationCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.obscurePassword,
    required this.isLoading,
    required this.isDesktop,
    required this.showBrand,
    required this.onTogglePassword,
    required this.onSwitchMode,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final ValueListenable<String?> emailError;
  final ValueListenable<String?> passwordError;
  final bool obscurePassword;
  final bool isLoading;
  final bool isDesktop;
  final bool showBrand;
  final VoidCallback onTogglePassword;
  final VoidCallback onSwitchMode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AutofillGroup(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBrand) ...[
              const AuthBrandMark(centered: true),
              const SizedBox(height: 24),
            ],
            _AuthTabs(isDesktop: isDesktop, onSwitchMode: onSwitchMode),
            const SizedBox(height: 18),
            Container(
              padding: EdgeInsets.all(isDesktop ? 32 : 20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create Account', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    'Join the community and start sharing.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AuthFormField(
                    controller: emailController,
                    label: 'Email Address',
                    hint: 'name@example.com',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    errorText: emailError,
                    onChanged: (_) => context.read<AuthProvider>().clearError(),
                  ),
                  const SizedBox(height: 8),
                  AuthFormField(
                    controller: passwordController,
                    label: 'Password',
                    hint: 'At least 8 characters',
                    prefixIcon: Icons.lock_outline_rounded,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    obscureText: obscurePassword,
                    errorText: passwordError,
                    onChanged: (_) => context.read<AuthProvider>().clearError(),
                    onFieldSubmitted: (_) {
                      if (!isLoading) onSubmit();
                    },
                    suffixIcon: IconButton(
                      onPressed: onTogglePassword,
                      tooltip: obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: isLoading ? null : onSubmit,
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Create Account'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text.rich(
              TextSpan(
                text: 'By joining, you agree to our ',
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(color: colors.primary),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy.',
                    style: TextStyle(color: colors.primary),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  const _AuthTabs({required this.isDesktop, required this.onSwitchMode});

  final bool isDesktop;
  final VoidCallback onSwitchMode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget tab(String label, bool selected, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(isDesktop ? 0 : 999),
          onTap: selected ? null : onTap,
          child: Container(
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: !isDesktop && selected
                  ? colors.surface
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(isDesktop ? 0 : 999),
              border: isDesktop && selected
                  ? Border(bottom: BorderSide(color: colors.primary, width: 2))
                  : null,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? colors.primary : colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isDesktop ? 0 : 3),
      decoration: BoxDecoration(
        color: isDesktop ? Colors.transparent : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(isDesktop ? 0 : 999),
        border: isDesktop
            ? Border(bottom: BorderSide(color: colors.outlineVariant))
            : null,
      ),
      child: Row(
        children: [
          tab('Sign In', false, onSwitchMode),
          tab('Create Account', true, () {}),
        ],
      ),
    );
  }
}
