import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../repositories/transaction_repository.dart';
import 'manage_categories_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showCurrencyPicker(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('INR (₹)'),
                onTap: () {
                  vm.setCurrencySymbol('₹');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('USD (\$)'),
                onTap: () {
                  vm.setCurrencySymbol('\$');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('EUR (€)'),
                onTap: () {
                  vm.setCurrencySymbol('€');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('GBP (£)'),
                onTap: () {
                  vm.setCurrencySymbol('£');
                  Navigator.pop(context);
                },
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
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('System Default'),
                onTap: () {
                  vm.setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Light'),
                onTap: () {
                  vm.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Dark'),
                onTap: () {
                  vm.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
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
              title: const Text('Delete All Data', style: TextStyle(color: Colors.red)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This action is irreversible and will permanently delete all your transactions. Default categories will be restored.'),
                  const SizedBox(height: 16),
                  const Text('Type "DELETE" to confirm:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        input = val;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'DELETE',
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: input == 'DELETE' ? () => Navigator.pop(context, true) : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text('Delete Permanently'),
                ),
              ],
            );
          }
        );
      }
    );

    if (confirmed == true && context.mounted) {
      try {
        final repo = context.read<TransactionRepository>();
        await repo.wipeData();
        
        if (context.mounted) {
          // Reload view models
          await context.read<CategoryViewModel>().loadCategories();
          if (!context.mounted) return;
          await context.read<TransactionViewModel>().loadTransactions();
          if (!context.mounted) return;
          await context.read<TransactionViewModel>().loadDashboardData();
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All data deleted successfully.')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting data: $e')),
          );
        }
      }
    }
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not implemented yet.')),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Expense Tracker',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text('A clean, offline-first personal finance application.'),
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              children: [
          _buildSectionHeader('Preferences'),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            subtitle: Text('Current: ${settingsVM.currencySymbol}'),
            onTap: () => _showCurrencyPicker(context, settingsVM),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(settingsVM.themeMode.name.toUpperCase()),
            onTap: () => _showThemePicker(context, settingsVM),
          ),
          
          const Divider(),
          _buildSectionHeader('Categories'),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Manage Categories'),
            subtitle: const Text('Add, edit, or delete categories'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageCategoriesView()),
              );
            },
          ),
          
          const Divider(),
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Export Data'),
            onTap: () => _showNotImplemented(context),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Import Data'),
            onTap: () => _showNotImplemented(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete All Data', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmDeleteAllData(context),
          ),
          
          const Divider(),
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Application'),
            onTap: () => _showAbout(context),
          ),
          ],
             ),
            ),
          ),
        ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
