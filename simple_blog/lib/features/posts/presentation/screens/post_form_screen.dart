import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';
import 'package:simple_blog/features/posts/data/models/post_image.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_form_provider.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_list_provider.dart';
import 'package:simple_blog/features/posts/presentation/widgets/post_image_picker.dart';
import 'package:simple_blog/core/widgets/network_image_gallery.dart';

class PostFormScreen extends StatefulWidget {
  final Post? initialPost;
  const PostFormScreen({super.key, this.initialPost});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late final List<PostImage> _existingImages;
  final List<PostImage> _removedImages = [];

  bool get _isEditing => widget.initialPost != null;

  @override
  void initState() {
    super.initState();

    final post = widget.initialPost;

    _existingImages = List.of(post?.images ?? []);

    if (post != null) {
      _titleController.text = post.title;
      _contentController.text = post.content;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<PostFormProvider>().setExistingImageCount(
        _existingImages.length,
      );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';

    if (title.isEmpty) {
      return 'Title is required.';
    }

    if (title.length < 3) {
      return 'Title must contain at least 3 characters.';
    }

    return null;
  }

  String? _validateContent(String? value) {
    final content = value?.trim() ?? '';

    if (content.isEmpty) {
      return 'Content is required.';
    }

    if (content.length < 10) {
      return 'Content must contain at least 10 characters.';
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final formProvider = context.read<PostFormProvider>();

    final post = _isEditing
        ? await formProvider.updatePost(
            postId: widget.initialPost!.id,
            title: _titleController.text,
            content: _contentController.text,
            removedImages: List.of(_removedImages),
          )
        : await formProvider.createPost(
            title: _titleController.text,
            content: _contentController.text,
          );

    if (!mounted) return;

    if (post == null) {
      AppNotification.error(
        context,
        message:
            formProvider.errorMessage ??
            (_isEditing
                ? 'Unable to update your post.'
                : 'Unable to create your post.'),
      );
      return;
    }

    await context.read<PostListProvider>().loadPosts();

    if (!mounted) return;

    AppNotification.success(
      context,
      message: _isEditing
          ? 'Your post was updated successfully.'
          : 'Your post was created successfully.',
    );

    if (_isEditing) {
      context.pop(post);
      return;
    }

    context.goNamed(RouteNames.postDetail, pathParameters: {'postId': post.id});
  }

  void _removeExistingImage(int index) {
    if (index < 0 || index >= _existingImages.length) return;

    setState(() {
      _removedImages.add(_existingImages.removeAt(index));
    });

    context.read<PostFormProvider>().setExistingImageCount(
      _existingImages.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select<AuthProvider, bool>(
      (provider) => provider.isAuthenticated,
    );

    final isLoading = context.select<PostFormProvider, bool>(
      (provider) => provider.isLoading,
    );

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit post' : 'Create post')),
      body: isAuthenticated ? _buildForm(isLoading) : _buildSignInRequired(),
    );
  }

  Widget _buildForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  enabled: !isLoading,
                  maxLength: 120,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Give your post a clear title',
                  ),
                  validator: _validateTitle,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _contentController,
                  enabled: !isLoading,
                  minLines: 8,
                  maxLines: 16,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Share your thoughts...',
                    alignLabelWithHint: true,
                  ),
                  validator: _validateContent,
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Images',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const PostImagePicker(),
                ],

                if (_isEditing && _existingImages.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Current images'),
                  const SizedBox(height: 12),
                  NetworkImageGallery(
                    imageUrls: _existingImages
                        .map((image) => image.imageUrl)
                        .toList(),
                    enabled: !isLoading,
                    onRemove: _removeExistingImage,
                  ),
                ],
                if (_isEditing) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Add images',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const PostImagePicker(),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : Text(_isEditing ? 'Save changes' : 'Publish post'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 48),
            const SizedBox(height: 16),
            Text(
              _isEditing
                  ? 'Sign in to edit this post.'
                  : 'Sign in to create a post.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.goNamed(RouteNames.login),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
