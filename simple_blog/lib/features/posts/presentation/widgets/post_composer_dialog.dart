import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_form_provider.dart';
import 'package:simple_blog/features/posts/presentation/widgets/post_image_picker.dart';

class PostComposerDialog extends StatefulWidget {
  const PostComposerDialog({super.key});

  @override
  State<PostComposerDialog> createState() => _PostComposerDialogState();
}

class _PostComposerDialogState extends State<PostComposerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final provider = context.read<PostFormProvider>();
    final post = await provider.createPost(
      title: _titleController.text,
      content: _contentController.text,
    );

    if (!mounted) return;
    if (post == null) {
      AppNotification.error(
        context,
        message: provider.errorMessage ?? 'Unable to publish your post.',
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.select<PostFormProvider, bool>(
      (provider) => provider.isLoading,
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 10, 12),
              child: Row(
                children: [
                  Text(
                    'Create post',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        enabled: !isLoading,
                        autofocus: true,
                        maxLength: 120,
                        decoration: const InputDecoration(
                          hintText: 'Post title',
                        ),
                        validator: (value) {
                          final title = value?.trim() ?? '';
                          if (title.length < 3) {
                            return 'Enter at least 3 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _contentController,
                        enabled: !isLoading,
                        minLines: 4,
                        maxLines: 10,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: 'What do you want to share?',
                        ),
                        validator: (value) {
                          final content = value?.trim() ?? '';
                          if (content.length < 10) {
                            return 'Enter at least 10 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const PostImagePicker(),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : _publish,
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publish'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
