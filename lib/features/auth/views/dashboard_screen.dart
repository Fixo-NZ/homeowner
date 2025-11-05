import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tradie/core/navbar/custom_nav_bar.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';


class DashboardScreen extends ConsumerStatefulWidget {  
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on index
    switch (index) {
      case 0:
        // Home - already on dashboard
        break;
      case 1:
        // Jobs - navigate to jobs screen (when you create it)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jobs screen coming soon!'),
          ),
        );
        break;
      case 2:
        // Messages - navigate to messages screen (when you create it)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Messages screen coming soon!'),
          ),
        );
        break;
      case 3:
        // Profile - navigate to profile screen (when you create it)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile screen coming soon!'),
          ),
        );
        break;
    }
  }

  void _onPlusButtonPressed() {
    // Navigate to job posting flow starting from category selection
    context.go('/job');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Dashboard', style: AppTextStyles.appBarTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await authViewModel.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: AppDimensions.spacing8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildDashboardBody(authState),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onPlusButtonPressed: _onPlusButtonPressed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPlusButtonPressed,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDashboardBody(AuthState authState) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back!', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppDimensions.spacing8),
                  if (authState.user != null) ...[
                    Text(
                      authState.user!.fullName,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      authState.user!.email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // Quick actions
          Text(
            'Quick Actions',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),

          Expanded(
            child: GridView.count(
              crossAxisCount: AppDimensions.gridCrossAxisCount,
              crossAxisSpacing: AppDimensions.gridSpacing,
              mainAxisSpacing: AppDimensions.gridSpacing,
              children: [
                _buildActionCard(
                  icon: Icons.work,
                  title: 'My Jobs',
                  subtitle: 'View active jobs',
                  color: AppColors.tradieBlue,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Jobs screen coming soon!'),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: 'Update your info',
                  color: AppColors.tradieGreen,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile screen coming soon!'),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.schedule,
                  title: 'Availability',
                  subtitle: 'Manage schedule',
                  color: AppColors.tradieOrange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Availability screen coming soon!'),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.attach_money,
                  title: 'Earnings',
                  subtitle: 'View payments',
                  color: AppColors.success,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Earnings screen coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                ),
                child: Icon(icon, size: AppDimensions.iconLarge, color: color),
              ),
              const SizedBox(height: AppDimensions.spacing12),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}