import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/core/utils/validators.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_blog/features/auth/presentation/widgets/login_card.dart';
import 'package:simple_blog/features/auth/presentation/widgets/registration_card.dart';
import 'package:simple_blog/features/auth/presentation/widgets/auth_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({this.initialLogin = true, super.key});

  final bool initialLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailError = ValueNotifier<String?>(null);
  final _passwordError = ValueNotifier<String?>(null);

  bool _obscurePassword = true;
  late bool _isLogin;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialLogin;
    _emailController.addListener(_clearEmailError);
    _passwordController.addListener(_clearPasswordError);
  }

  void _clearEmailError() {
    if (_emailError.value != null) _emailError.value = null;
  }

  void _clearPasswordError() {
    if (_passwordError.value != null) _passwordError.value = null;
  }

  void _switchMode(bool login) {
    if (_isLogin == login) return;
    FocusScope.of(context).unfocus();
    _emailError.value = null;
    _passwordError.value = null;
    context.read<AuthProvider>().clearError();
    setState(() => _isLogin = login);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailError.dispose();
    _passwordError.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _emailError.value = Validators.email(_emailController.text);
    _passwordError.value = Validators.password(_passwordController.text);

    if (_emailError.value != null || _passwordError.value != null) return;

    FocusScope.of(context).unfocus();
    final authProvider = context.read<AuthProvider>();
    final succeeded = _isLogin
        ? await authProvider.login(
            email: _emailController.text,
            password: _passwordController.text,
          )
        : await authProvider.register(
            email: _emailController.text,
            password: _passwordController.text,
          );

    if (!mounted) return;

    if (!succeeded) {
      AppNotification.error(
        context,
        message:
            authProvider.errorMessage ??
            (_isLogin ? 'Unable to sign in.' : 'Unable to create account.'),
      );
      return;
    }

    AppNotification.success(
      context,
      message: _isLogin
          ? 'Welcome back. You are now signed in.'
          : 'Your account was created successfully.',
    );
    final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
    if (redirect != null &&
        redirect.startsWith('/') &&
        !redirect.startsWith('//')) {
      context.go(redirect);
    } else {
      context.goNamed(RouteNames.posts);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>(
      (provider) => provider.isLoading,
    );
    final isDesktop = MediaQuery.sizeOf(context).width >= 700;

    final card = AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [...previousChildren, ?currentChild],
        );
      },
      child: _isLogin
          ? LoginCard(
              key: const ValueKey('login'),
              formKey: _loginFormKey,
              emailController: _emailController,
              passwordController: _passwordController,
              emailError: _emailError,
              passwordError: _passwordError,
              obscurePassword: _obscurePassword,
              isLoading: isLoading,
              isDesktop: isDesktop,
              showBrand: true,
              onTogglePassword: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onSwitchMode: () => _switchMode(false),
              onSubmit: _submit,
            )
          : RegistrationCard(
              key: const ValueKey('register'),
              formKey: _registerFormKey,
              emailController: _emailController,
              passwordController: _passwordController,
              emailError: _emailError,
              passwordError: _passwordError,
              obscurePassword: _obscurePassword,
              isLoading: isLoading,
              isDesktop: isDesktop,
              showBrand: true,
              onTogglePassword: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onSwitchMode: () => _switchMode(true),
              onSubmit: _submit,
            ),
    );

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth >= 700 ? 550 : 400,
                      ),
                      child: card,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
