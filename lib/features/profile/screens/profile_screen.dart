import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:wealthwise/features/auth/providers/auth_provider.dart';
import 'package:wealthwise/features/transactions/transaction_provider.dart';
import 'package:wealthwise/services/data_export_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final isGuest = user == null;

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(
              user?.name ?? 'Guest User', 
              user?.email ?? 'Sign in to sync your data',
              isGuest,
            ),
            const SizedBox(height: 40),
            _buildSettingsSection(context, ref),
            const SizedBox(height: 24),
            if (!isGuest) ...[
              _buildDataSection(context, ref, transactionsAsync, user?.name ?? 'User'),
              const SizedBox(height: 40),
            ],
            _buildAuthButton(context, ref, isGuest),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email, bool isGuest) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isGuest ? AppTheme.accentGold : AppTheme.accentEmerald, 
                shape: BoxShape.circle
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.secondaryNavy,
                child: Icon(
                  isGuest ? Icons.person_outline : Icons.person, 
                  size: 60, 
                  color: isGuest ? AppTheme.accentGold : AppTheme.accentEmerald
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(email, style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return _buildSectionContainer([
      _buildListTile(Icons.dark_mode_outlined, 'Dark Mode', trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppTheme.accentEmerald)),
      _buildListTile(Icons.fingerprint, 'Biometric Lock', trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppTheme.accentEmerald)),
      _buildListTile(Icons.notifications_outlined, 'Notifications', onTap: () {}),
    ]);
  }

  Widget _buildDataSection(BuildContext context, WidgetRef ref, AsyncValue<List<dynamic>> txsAsync, String name) {
    return _buildSectionContainer([
      _buildListTile(Icons.file_download_outlined, 'Export Transactions (CSV)', onTap: () {
        txsAsync.whenData((txs) {
          DataExportService().exportToCSV(txs.cast());
        });
      }),
      _buildListTile(Icons.picture_as_pdf_outlined, 'Monthly Financial Report (PDF)', onTap: () {
        txsAsync.whenData((txs) {
          DataExportService().exportToPDF(txs.cast(), name);
        });
      }),
      _buildListTile(Icons.cloud_sync_outlined, 'Cloud Sync Settings', onTap: () {}),
    ]);
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: AppTheme.secondaryNavy, borderRadius: BorderRadius.circular(20)),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(IconData icon, String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildAuthButton(BuildContext context, WidgetRef ref, bool isGuest) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: isGuest
            ? ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentEmerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Sign In / Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            : OutlinedButton.icon(
                onPressed: () {
                   ref.read(authNotifierProvider.notifier).signOut();
                   context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.accentCoral),
                label: const Text('Sign Out', style: TextStyle(color: AppTheme.accentCoral, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentCoral),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
      ),
    );
  }
}
