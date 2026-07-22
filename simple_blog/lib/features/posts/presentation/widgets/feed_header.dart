import 'package:flutter/material.dart';

class FeedHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isAuthenticated;
  final bool isDarkMode;
  final bool isAuthLoading;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onProfile;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const FeedHeader({
    required this.isAuthenticated,
    required this.isDarkMode,
    required this.isAuthLoading,
    required this.onLogin,
    required this.onRegister,
    required this.onProfile,
    required this.onToggleTheme,
    required this.onLogout,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 600;
    final showCompactTitle = width >= 360;

    return AppBar(
      toolbarHeight: preferredSize.height,
      titleSpacing: 16,
      title: Row(
        children: [
          Tooltip(
            message: 'Simple Blog/Forum',
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Icon(
                  Icons.forum_rounded,
                  size: 20,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
          if (!isCompact || showCompactTitle) ...[
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                isCompact ? 'Blog/Forum' : 'Simple Blog/Forum',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (isCompact)
          PopupMenuButton<_HeaderAction>(
            tooltip: 'Menu',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (action) {
              switch (action) {
                case _HeaderAction.signIn:
                  onLogin();
                case _HeaderAction.register:
                  onRegister();
                case _HeaderAction.theme:
                  onToggleTheme();
                case _HeaderAction.profile:
                  onProfile();
                case _HeaderAction.logout:
                  onLogout();
              }
            },
            itemBuilder: (context) => [
              if (!isAuthenticated) ...[
                const PopupMenuItem(
                  value: _HeaderAction.signIn,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.login_rounded),
                    title: Text('Sign in'),
                  ),
                ),
                const PopupMenuItem(
                  value: _HeaderAction.register,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_add_outlined),
                    title: Text('Create account'),
                  ),
                ),
              ],
              PopupMenuItem(
                value: _HeaderAction.theme,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  title: Text(isDarkMode ? 'Light mode' : 'Dark mode'),
                ),
              ),
              if (isAuthenticated) ...[
                const PopupMenuItem(
                  value: _HeaderAction.profile,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.account_circle_outlined),
                    title: Text('Profile'),
                  ),
                ),
                PopupMenuItem(
                  value: _HeaderAction.logout,
                  enabled: !isAuthLoading,
                  child: const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.logout_rounded),
                    title: Text('Sign out'),
                  ),
                ),
              ],
            ],
          )
        else ...[
          if (!isAuthenticated) ...[
            IconButton(
              onPressed: onLogin,
              tooltip: 'Sign in',
              icon: const Icon(Icons.login_rounded),
            ),
            IconButton(
              onPressed: onRegister,
              tooltip: 'Create account',
              icon: const Icon(Icons.person_add_outlined),
            ),
          ],
          IconButton(
            onPressed: onToggleTheme,
            tooltip: isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          if (isAuthenticated) ...[
            IconButton(
              onPressed: onProfile,
              tooltip: 'Profile',
              icon: const Icon(Icons.account_circle_outlined),
            ),
            IconButton(
              onPressed: isAuthLoading ? null : onLogout,
              tooltip: 'Sign out',
              icon: isAuthLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded),
            ),
          ],
          const SizedBox(width: 6),
        ],
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: colorScheme.outlineVariant),
      ),
    );
  }
}

enum _HeaderAction { signIn, register, theme, profile, logout }
