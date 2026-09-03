import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

class TransferView extends StatelessWidget {
  const TransferView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimaryDark, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transfer', style: AppStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderDark, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.swap_horiz, color: AppColors.textSecondaryDark, size: 40),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Transfers Coming Soon',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'We are building a robust multi-account system. Soon you will be able to transfer money between your checking, savings, and credit accounts seamlessly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textTertiaryDark,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Got it', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
