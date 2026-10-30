import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../order/provider/order_provider.dart';
import '../../models/user_model.dart';
import '../../provider/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final orderCount = context.select<OrderProvider, int>(
      (orders) => orders.orders.length,
    );

    if (user == null) {
      // The router redirects signed-out users; this covers the brief moment
      // between signing out and leaving the page.
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileHeader(user: user),
              const SizedBox(height: 16),
              SectionCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: const Text('My orders'),
                      subtitle: Text(
                        orderCount == 0
                            ? 'No orders yet'
                            : '$orderCount order${orderCount == 1 ? '' : 's'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(AppRouter.orders),
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag_outlined),
                      title: const Text('My cart'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(AppRouter.cart),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Contact details',
                icon: Icons.badge_outlined,
                child: Column(
                  children: [
                    _DetailRow(icon: Icons.email_outlined, value: user.email),
                    _DetailRow(icon: Icons.phone_outlined, value: user.phone),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      value: [
                        user.address,
                        user.city,
                        user.postalCode,
                      ].where((part) => part.isNotEmpty).join(', '),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionCard(
                title: 'Appearance',
                icon: Icons.palette_outlined,
                child: _ThemeSelector(),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
                onPressed: () => _signOut(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your cart stays saved on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    // Leave the protected page first, then clear the session.
    context.go(AppRouter.home);
    await auth.logout();
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: user.image.isEmpty
                ? Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : ClipOval(
                    child: AppNetworkImage(
                      url: user.image,
                      width: 68,
                      height: 68,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user.username}',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _DetailRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode_outlined),
          label: Text('Light'),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.brightness_auto_outlined),
          label: Text('System'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode_outlined),
          label: Text('Dark'),
        ),
      ],
      selected: {themeProvider.themeMode},
      onSelectionChanged: (selection) =>
          themeProvider.setThemeMode(selection.first),
    );
  }
}
