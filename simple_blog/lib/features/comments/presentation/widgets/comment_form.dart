import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_blog/features/comments/presentation/providers/comment_provider.dart';
import 'package:simple_blog/features/comments/presentation/widgets/comment_image_picker.dart';

class CommentForm extends StatefulWidget {
  final String postId;

  const CommentForm({required this.postId, super.key});

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  String? _validateContent(String? value) {
    final content = value?.trim() ?? '';

    if (content.isEmpty) {
      return 'Comment cannot be empty.';
    }

    if (content.length > 1000) {
      return 'Comment cannot exceed 1000 characters.';
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CommentProvider>();

    final created = await provider.createComment(
      postId: widget.postId,
      content: _contentController.text,
    );

    if (!mounted) return;

    if (!created) {
      AppNotification.error(
        context,
        message:
            provider.submitErrorMessage ?? 'Unable to create your comment.',
      );
      return;
    }

    _contentController.clear();

    AppNotification.success(context, message: 'Your comment was posted.');
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select<AuthProvider, bool>(
      (provider) => provider.isAuthenticated,
    );

    final isSubmitting = context.select<CommentProvider, bool>(
      (provider) => provider.isSubmitting,
    );

    if (!isAuthenticated) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(child: Text('Sign in to join the conversation.')),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: () => context.goNamed(
                  RouteNames.register,
                  queryParameters: {
                    'mode': 'login',
                    'redirect': GoRouterState.of(context).uri.toString(),
                  },
                ),
                child: const Text('Sign in'),
              ),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _contentController,
            enabled: !isSubmitting,
            minLines: 3,
            maxLines: 6,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Add a comment',
              hintText: 'What are your thoughts?',
              alignLabelWithHint: true,
            ),
            validator: _validateContent,
          ),
          const SizedBox(height: 12),
          const CommentImagePicker(),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: isSubmitting ? null : _submit,
              child: isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Comment'),
            ),
          ),
        ],
      ),
    );
  }
}
