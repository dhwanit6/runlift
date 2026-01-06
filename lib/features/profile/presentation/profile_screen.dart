import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/atmospheric_background.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../data/auth_provider.dart';
import '../../../data/stats_service.dart';
import '../../../data/social_share_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final lifetimeStatsAsync = ref.watch(lifetimeStatsProvider);
    final user = authState.user;
    final theme = Theme.of(context);
    
    return Scaffold(
      body: AtmosphericBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            children: [
              // Header - Editorial impact
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERSONAL'.toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UNIVERSE',
                    style: theme.textTheme.displayMedium,
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // User Profile Section - Premium Bento
              _buildUserHero(user),

              const SizedBox(height: 24),

              // Lifetime Stats HUD - Bento Grid
              lifetimeStatsAsync.when(
                data: (stats) {
                  final runs = (stats['runs'] as num? ?? 0).toString();
                  final km = ((stats['km'] as num? ?? 0.0).toDouble()).toStringAsFixed(1);
                  final streak = (stats['streak'] as num? ?? 0).toString();

                  return Row(
                    children: [
                      Expanded(child: _buildBentoStat(runs, 'RUNS', Icons.directions_run_rounded, Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildBentoStat(km, 'KM', Icons.map_rounded, Colors.purple)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildBentoStat(streak, 'STREAK', Icons.local_fire_department_rounded, Colors.orange)),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 40),

              // Biometrics Section
              _buildSectionHeader('BIOMETRICS'),
              const SizedBox(height: 16),
              lifetimeStatsAsync.when(
                data: (stats) {
                  final weight = stats['weight'] as double? ?? 0.0;
                  final height = stats['height'] as double? ?? 0.0;
                  
                  return GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _buildSettingsRow(
                          icon: Icons.monitor_weight_outlined,
                          title: 'Weight',
                          value: weight > 0 ? '$weight kg' : 'Set weight',
                          onTap: () => _showBiometricDialog(context, ref, 'Weight', weight, (v) => ref.read(lifetimeStatsProvider.notifier).updateBiometrics(weight: v)),
                        ),
                        Divider(color: Colors.white.withAlpha(10), indent: 64, endIndent: 24),
                        _buildSettingsRow(
                          icon: Icons.height_rounded,
                          title: 'Height',
                          value: height > 0 ? '$height cm' : 'Set height',
                          onTap: () => _showBiometricDialog(context, ref, 'Height', height, (v) => ref.read(lifetimeStatsProvider.notifier).updateBiometrics(height: v)),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 40),

              // Preferences Section
              _buildSectionHeader('PREFERENCES'),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildSettingsRow(
                      icon: Icons.share_rounded,
                      title: 'Invite Friends',
                      value: 'Expand the network',
                      onTap: () => SocialShareService.shareInvite(),
                    ),
                    Divider(color: Colors.white.withAlpha(10), indent: 64, endIndent: 24),
                    _buildSettingsRow(
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      value: 'Daily 7:00 AM',
                      onTap: () => _showNotificationInfo(context),
                    ),
                    Divider(color: Colors.white.withAlpha(10), indent: 64, endIndent: 24),
                    _buildSettingsRow(
                      icon: Icons.info_outline_rounded,
                      title: 'About RunLift',
                      value: 'v1.0.0 Stable',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              
              // Logout Action
              PremiumButton(
                label: 'SIGN OUT',
                icon: Icons.logout_rounded,
                isSecondary: true,
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) context.go('/welcome');
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildUserHero(dynamic user) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withAlpha(100), width: 2),
              image: user?.photoURL != null 
                  ? DecorationImage(image: NetworkImage(user!.photoURL!), fit: BoxFit.cover)
                  : null,
            ),
            child: user?.photoURL == null 
                ? Center(
                    child: Text(
                      (user?.displayName ?? user?.email ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.primary, fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Runner',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Connect account',
                  style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoStat(String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({required IconData icon, required String title, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withAlpha(5), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white70, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white12),
          ],
        ),
      ),
    );
  }

  void _showNotificationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Ritual Reminders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Your discipline is tracked. We send reminders daily at 7:00 AM to ensure you stay on path.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('UNDERSTOOD', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 64),
            const SizedBox(height: 24),
            const Text('RUNLIFT', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2)),
            const SizedBox(height: 8),
            const Text('v1.0.0 Stable Build', style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 24),
            const Text(
              'Designed by Antigravity for elite runners. Built with Flutter for performance and elegance.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
            ),
            const SizedBox(height: 32),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  void _showBiometricDialog(BuildContext context, WidgetRef ref, String title, double currentValue, Function(double) onSave) {
    final controller = TextEditingController(text: currentValue > 0 ? currentValue.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Update $title', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter value',
            hintStyle: const TextStyle(color: Colors.white24),
            suffixText: title == 'Weight' ? ' KG' : ' CM',
            suffixStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 0.0;
              onSave(value);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
