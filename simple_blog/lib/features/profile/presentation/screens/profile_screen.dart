import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/profile/presentation/providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _changeAvatar(
    BuildContext context,
    ProfileProvider provider,
  ) async {
    final updated = await provider.pickAndUploadAvatar();

    if (!context.mounted || updated) return;

    AppNotification.error(
      context,
      message: provider.errorMessage ?? 'Unable to update your profile image.',
    );
  }

  Future<void> _deleteAvatar(
    BuildContext context,
    ProfileProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete profile image?'),
          content: const Text(
            'Your current profile image will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final deleted = await provider.deleteAvatar();

    if (!context.mounted) return;

    if (!deleted) {
      AppNotification.error(
        context,
        message:
            provider.errorMessage ?? 'Unable to delete your profile image.',
      );
      return;
    }

    AppNotification.success(
      context,
      message: 'Your profile image was deleted.',
    );
  }

  Future<void> _editDisplayName(
    BuildContext context,
    ProfileProvider provider,
  ) async {
    final profile = provider.profile;

    if (profile == null) return;

    final formKey = GlobalKey<FormState>();
    var displayName = profile.displayName;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit display name'),
          content: Form(
            key: formKey,
            child: TextFormField(
              initialValue: profile.displayName,
              autofocus: true,
              maxLength: 50,
              decoration: const InputDecoration(labelText: 'Display name'),
              onChanged: (value) {
                displayName = value;
              },
              validator: (value) {
                final name = value?.trim() ?? '';

                if (name.length < 2) {
                  return 'Enter at least 2 characters.';
                }

                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                Navigator.of(dialogContext).pop(displayName.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null || !context.mounted) return;
    if (result == profile.displayName) return;

    final updated = await provider.updateDisplayName(result);

    if (!context.mounted) return;

    if (!updated) {
      AppNotification.error(
        context,
        message: provider.errorMessage ?? 'Unable to update your display name.',
      );
      return;
    }

    AppNotification.success(context, message: 'Your display name was updated.');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError && profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.errorMessage ?? 'Unable to load your profile.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: provider.loadProfile,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (profile == null) {
            return const Center(child: Text('Profile not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 58,
                          foregroundImage: profile.avatarUrl != null
                              ? NetworkImage(profile.avatarUrl!)
                              : null,
                          child: profile.avatarUrl == null
                              ? const Icon(Icons.person_outline, size: 54)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: provider.isSaving
                                  ? null
                                  : () => _changeAvatar(context, provider),
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                              ),
                              label: Text(
                                profile.avatarUrl == null
                                    ? 'Add photo'
                                    : 'Change photo',
                              ),
                            ),
                            if (profile.avatarUrl != null)
                              TextButton.icon(
                                onPressed: provider.isSaving
                                    ? null
                                    : () => _deleteAvatar(context, provider),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Remove photo'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          profile.displayName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: provider.isSaving
                              ? null
                              : () => _editDisplayName(context, provider),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit name'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
