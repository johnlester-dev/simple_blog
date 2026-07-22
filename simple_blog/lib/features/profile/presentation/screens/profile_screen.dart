import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
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
    final email = context.select<AuthProvider, String?>(
      (provider) => provider.currentUser?.email,
    );

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
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: _ProfilePanel(
                  displayName: profile.displayName,
                  email: email,
                  avatarUrl: profile.avatarUrl,
                  memberSince: profile.createdAt,
                  isSaving: provider.isSaving,
                  onChangeAvatar: () => _changeAvatar(context, provider),
                  onDeleteAvatar: profile.avatarUrl == null
                      ? null
                      : () => _deleteAvatar(context, provider),
                  onEditName: () => _editDisplayName(context, provider),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.memberSince,
    required this.isSaving,
    required this.onChangeAvatar,
    required this.onDeleteAvatar,
    required this.onEditName,
  });

  final String displayName;
  final String? email;
  final String? avatarUrl;
  final DateTime memberSince;
  final bool isSaving;
  final VoidCallback onChangeAvatar;
  final VoidCallback? onDeleteAvatar;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final joined = MaterialLocalizations.of(
      context,
    ).formatMonthYear(memberSince.toLocal());

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.tertiary],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 58,
                          backgroundColor: colors.secondaryContainer,
                          foregroundImage: avatarUrl == null
                              ? null
                              : NetworkImage(avatarUrl!),
                          child: avatarUrl == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 54,
                                  color: colors.onSecondaryContainer,
                                )
                              : null,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: isSaving ? null : onEditName,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit profile'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    displayName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      email!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Joined $joined',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Divider(color: colors.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Profile photo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: isSaving ? null : onChangeAvatar,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(
                          avatarUrl == null ? 'Upload photo' : 'Change photo',
                        ),
                      ),
                      if (onDeleteAvatar != null)
                        TextButton.icon(
                          onPressed: isSaving ? null : onDeleteAvatar,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
