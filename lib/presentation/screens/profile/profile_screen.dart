import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../business_logic/auth/auth_bloc.dart';
import '../../../business_logic/auth/auth_event.dart';
import '../../../business_logic/auth/auth_state.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go(RouteConstants.login);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is Authenticated) {
            // Show success message when profile is updated
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
          }
        },
        builder: (context, state) {
          if (state is Authenticated) {
            final user = state.user;

            return ListView(
              children: [
                // Profile header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                        child: Text(
                          user.fullName.substring(0, 1).toUpperCase(),
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(user.fullName, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(user.email, style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      )),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: user.kycStatus == 'approved'
                              ? AppColors.successGreen.withOpacity(0.2)
                              : AppColors.warningOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'KYC: ${user.kycStatus.toUpperCase()}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: user.kycStatus == 'approved'
                                ? AppColors.successGreen
                                : AppColors.warningOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Profile options
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditProfileDialog(context, user),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Transaction History'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RouteConstants.transactions),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text('Security'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),

                // Logout
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.errorRed),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AuthBloc>().add(const AuthLogoutRequested());
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: AppColors.errorRed),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, user) {
    final formKey = GlobalKey<FormState>();
    final fullNameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: BlocConsumer<AuthBloc, AuthState>(
            listener: (dialogCtx, state) {
              if (state is Authenticated) {
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
              }
            },
            builder: (dialogCtx, state) {
              final isLoading = state is AuthLoading;
              String? errorMsg;
              if (state is AuthError) errorMsg = state.message;

              return SizedBox(
                width: 360,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                            child: Text(
                              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                              style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Edit Profile', style: AppTextStyles.h3),
                                const SizedBox(height: 4),
                                Text(user.email, style: AppTextStyles.companyName),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: fullNameCtrl,
                        decoration: const InputDecoration(labelText: 'Full name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter full name' : null,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone' : null,
                        enabled: !isLoading,
                      ),
                      if (errorMsg != null) ...[
                        const SizedBox(height: 10),
                        Text(errorMsg, style: AppTextStyles.bodySmall.copyWith(color: AppColors.errorRed)),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (!formKey.currentState!.validate()) return;
                                    context.read<AuthBloc>().add(AuthProfileUpdateRequested(
                                          fullName: fullNameCtrl.text.trim(),
                                          phone: phoneCtrl.text.trim(),
                                        ));
                                  },
                            child: isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
