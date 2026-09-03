import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../repositories/transaction_repository.dart';
import '../routes/app_routes.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showNameEditor(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        String input = vm.userName;
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Set Your Name', style: AppStyles.bodyPrimary),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: input),
            style: AppStyles.bodyPrimary,
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              hintStyle: AppStyles.bodySecondary,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.borderDark),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (val) {
              input = val;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: AppStyles.bodySecondary),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
              ),
              onPressed: () {
                vm.setUserName(input);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Select Currency', style: AppStyles.bodyPrimary),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogListTile(
                context,
                'INR (₹)',
                () => vm.setCurrencySymbol('₹'),
              ),
              _buildDialogListTile(
                context,
                'USD (\$)',
                () => vm.setCurrencySymbol('\$'),
              ),
              _buildDialogListTile(
                context,
                'EUR (€)',
                () => vm.setCurrencySymbol('€'),
              ),
              _buildDialogListTile(
                context,
                'GBP (£)',
                () => vm.setCurrencySymbol('£'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Select Theme', style: AppStyles.bodyPrimary),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogListTile(
                context,
                'System Default',
                () => vm.setThemeMode(ThemeMode.system),
              ),
              _buildDialogListTile(
                context,
                'Light',
                () => vm.setThemeMode(ThemeMode.light),
              ),
              _buildDialogListTile(
                context,
                'Dark',
                () => vm.setThemeMode(ThemeMode.dark),
              ),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildDialogListTile(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title, style: AppStyles.bodySecondary),
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }

  Future<void> _confirmDeleteAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String input = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              title: const Text(
                'Delete All Data',
                style: AppStyles.destructive,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This action is irreversible and will permanently delete all your transactions. Default categories will be restored.',
                    style: AppStyles.bodySecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Type "DELETE" to confirm:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        input = val;
                      });
                    },
                    style: AppStyles.bodyPrimary,
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.borderDark),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF87171)),
                      ),
                      hintText: 'DELETE',
                      hintStyle: AppStyles.caption,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: AppStyles.bodySecondary),
                ),
                ElevatedButton(
                  onPressed: input == 'DELETE'
                      ? () => Navigator.pop(context, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF87171),
                    foregroundColor: AppColors.backgroundDark,
                  ),
                  child: const Text('Delete Permanently'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        final repo = context.read<TransactionRepository>();
        await repo.wipeData();

        if (context.mounted) {
          await context.read<CategoryViewModel>().loadCategories();
          if (!context.mounted) return;
          await context.read<TransactionViewModel>().loadTransactions();
          if (!context.mounted) return;
          await context.read<TransactionViewModel>().loadDashboardData();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All data deleted successfully.'),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting data: $e'),
              backgroundColor: const Color(0xFFF87171),
            ),
          );
        }
      }
    }
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not implemented yet.'),
        backgroundColor: AppColors.surfaceContainerHighDark,
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FlowLedger',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text('A clean, offline-first personal finance application.'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimaryDark,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: AppStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              children: [
                _buildSectionHeader('Preferences'),
                _buildSettingsTile(
                  icon: Icons.person,
                  title: 'User Name',
                  subtitle: settingsVM.userName,
                  onTap: () => _showNameEditor(context, settingsVM),
                ),
                _buildSettingsTile(
                  icon: Icons.attach_money,
                  title: 'Currency',
                  subtitle: 'Current: ${settingsVM.currencySymbol}',
                  onTap: () => _showCurrencyPicker(context, settingsVM),
                ),
                _buildSettingsTile(
                  icon: Icons.brightness_6,
                  title: 'Theme',
                  subtitle: settingsVM.themeMode.name.toUpperCase(),
                  onTap: () => _showThemePicker(context, settingsVM),
                ),

                const Divider(
                  color: AppColors.borderDark,
                  indent: 24,
                  endIndent: 24,
                  height: 32,
                ),

                _buildSectionHeader('Categories'),
                _buildSettingsTile(
                  icon: Icons.category_outlined,
                  title: 'Manage Categories',
                  subtitle: 'Add, edit, or delete categories',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.manageCategories);
                  },
                ),

                const Divider(
                  color: AppColors.borderDark,
                  indent: 24,
                  endIndent: 24,
                  height: 32,
                ),

                _buildSectionHeader('Data'),
                _buildSettingsTile(
                  icon: Icons.file_upload_outlined,
                  title: 'Export Data',
                  onTap: () => _showNotImplemented(context),
                ),
                _buildSettingsTile(
                  icon: Icons.file_download_outlined,
                  title: 'Import Data',
                  onTap: () => _showNotImplemented(context),
                ),
                _buildSettingsTile(
                  icon: Icons.delete_forever,
                  title: 'Delete All Data',
                  isDestructive: true,
                  onTap: () => _confirmDeleteAllData(context),
                ),

                const Divider(
                  color: AppColors.borderDark,
                  indent: 24,
                  endIndent: 24,
                  height: 32,
                ),

                _buildSectionHeader('About'),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About Application',
                  onTap: () => _showAbout(context),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Text(title.toUpperCase(), style: AppStyles.sectionHeader),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final color = isDestructive
        ? const Color(0xFFF87171)
        : AppColors.textPrimaryDark;
    final iconColor = isDestructive
        ? const Color(0xFFF87171)
        : AppColors.textSecondaryDark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textTertiaryDark,
                fontSize: 12,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
