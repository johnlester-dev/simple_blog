import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_blog/features/auth/presentation/widgets/login_card.dart';
import 'package:simple_blog/features/auth/presentation/widgets/registration_introduction.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final loggedIn = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!loggedIn) {
      AppNotification.error(
        context,
        message: authProvider.errorMessage ?? 'Unable to sign in.',
      );
      return;
    }

    AppNotification.success(
      context,
      message: 'Welcome back. You are now signed in.',
    );
    context.goNamed(RouteNames.posts);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>(
      (provider) => provider.isLoading,
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
            final card = LoginCard(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              isLoading: isLoading,
              showBrand: !isDesktop,
              onTogglePassword: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              onSubmit: _submit,
            );

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 20,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: SizedBox(
                    width: 1100,
                    child: isDesktop
                        ? Row(
                            children: [
                              const Expanded(child: RegistrationIntroduction()),
                              const SizedBox(width: 72),
                              SizedBox(width: 440, child: card),
                            ],
                          )
                        : card,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
