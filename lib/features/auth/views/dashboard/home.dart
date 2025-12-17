// lib/presentation/views/dashboard/DashboardHomeView.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart'; 
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tradie/providers/tradie_provider.dart';
import '../../../tradie/models/tradie_model.dart';

class DashboardHomeView extends ConsumerWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // You would watch/read other ViewModels here for data (e.g., jobsViewModelProvider)
    final query = ref.watch(tradieSearchProvider).trim().toLowerCase();
    final asyncTradies = ref.watch(tradiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header (Search Bar and Notifications)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spacing40), // Status bar padding + extra space
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // "FIXO" Logo/Title
                      Text(
                        'FIXO', 
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onBackground,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none, size: AppDimensions.iconMedium),
                        onPressed: () {
                          // TODO: Implement ViewModel method for notification tap
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing20),
                  // Search Bar (searches jobs and tradies)
                  Consumer(
                    builder: (context, ref, _) {
                      return TextField(
                        key: const Key('dashboard_search_field'),
                        onChanged: (v) => ref.read(tradieSearchProvider.notifier).state = v,
                        decoration: InputDecoration(
                          hintText: 'Search jobs or tradies...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.grey600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.grey200,
                          contentPadding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
                        ),
                        style: AppTextStyles.bodyMedium,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Popular Services
          SliverToBoxAdapter(
            child: _buildSectionTitle(context, 'Popular Services', showViewAll: false),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120, 
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                children: [
                  _buildServiceIcon(context, Icons.plumbing, 'Plumbing'),
                  _buildServiceIcon(context, Icons.carpenter, 'Carpentry'),
                  _buildServiceIcon(context, Icons.format_paint, 'Painting'),
                  _buildServiceIcon(context, Icons.electrical_services, 'Electrical'),
                  _buildServiceIcon(context, Icons.more_horiz, 'More', isMore: true),
                ],
              ),
            ),
          ),

          //TRADIE PROFILES HARDCODED FOR DEMO PURPOSES ONLY

          // Active Jobs
          SliverToBoxAdapter(
            child: _buildSectionTitle(context, 'Active Jobs'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Builder(builder: (context) {
                final query = ref.watch(tradieSearchProvider).trim().toLowerCase();
                final jobs = [
                  {
                    'title': 'Bathroom Renovation',
                    'status': 'In Progress',
                    'name': 'Andy Lim',
                    'role': 'Plumber',
                    'completion': 'June 13, 2025',
                  },
                  {
                    'title': 'Kitchen Lights',
                    'status': 'Scheduled',
                    'name': 'Jane Doe',
                    'role': 'Electrician',
                    'completion': 'May 20, 2025',
                  },
                ];

                final filteredJobs = query.isEmpty
                    ? jobs
                    : jobs.where((j) {
                        final title = (j['title'] as String).toLowerCase();
                        final owner = (j['name'] as String).toLowerCase();
                        return title.contains(query) || owner.contains(query);
                      }).toList();

                return Column(
                  children: filteredJobs.map((j) {
                    return _buildJobCard(
                      context,
                      title: j['title'] as String,
                      status: j['status'] as String,
                      name: j['name'] as String,
                      role: j['role'] as String,
                      completion: j['completion'] as String,
                    );
                  }).toList(),
                );
              }),
            ]),
          ),

          // Top Tradies (& search results)
          if (query.isEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionTitle(context, 'Top Tradies'),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: asyncTradies.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(child: Text('No tradies found', style: AppTextStyles.bodyMedium));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final t = list[index];
                        return _buildTradieCard(t.name, t.profession, t.rating, t.avatarUrl ?? '');
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) {
                    print('DashboardHomeView: error loading tradies $e');
                    return Center(child: Text('Error loading tradies', style: AppTextStyles.bodyMedium));
                  },
                ),
              ),
            ),
          ] else ...[
            SliverToBoxAdapter(
              child: asyncTradies.when(
                data: (list) {
                  final filtered = list.where((t) {
                    final name = t.name.toLowerCase();
                    final prof = t.profession.toLowerCase();
                    return name.contains(query) || prof.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Center(child: Text('No results found', style: AppTextStyles.bodyMedium)),
                    );
                  }

                  return Column(
                    children: filtered.map((t) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium, vertical: AppDimensions.spacing8),
                      child: _buildTradieCard(t.name, t.profession, t.rating, t.avatarUrl ?? ''),
                    )).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, s) => Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Center(child: Text('Error loading tradies', style: AppTextStyles.bodyMedium)),
                ),
              ),
            ),
          ],

          // Recently Completed
          SliverToBoxAdapter(
            child: _buildSectionTitle(context, 'Recently Completed', showViewAll: false),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
              child: ListTile(
                leading: CircleAvatar(
                  radius: AppDimensions.avatarSmall,
                  // backgroundImage
                  backgroundColor: AppColors.grey400,
                ),
                title: Text('Jane Doe', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('16hrs ago', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.more_horiz, color: AppColors.grey600), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.close, color: AppColors.grey600), onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
          
          // Image placeholder
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium, 
              vertical: AppDimensions.spacing8,
            ),
            sliver: SliverToBoxAdapter(
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    'Job Image Placeholder',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
                  ),
                ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.bottomNavHeight)), // Space for the floating navbar
        ],
      ),
    );
  }
  
  // --- Helper Widgets (Private to the View) ---

  Widget _buildSectionTitle(BuildContext context, String title, {bool showViewAll = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium, 
        AppDimensions.spacing20, 
        AppDimensions.paddingMedium, 
        AppDimensions.spacing12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          if (showViewAll)
            TextButton(
              onPressed: () { /* TODO: Navigation action */ },
              child: Text(
                'View all',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryDark),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(BuildContext context, IconData icon, String label, {bool isMore = false}) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppDimensions.spacing12),
      child: Column(
        children: [
          Container(
            height: AppDimensions.iconXLarge + AppDimensions.spacing8,
            width: AppDimensions.iconXLarge + AppDimensions.spacing8,
            decoration: BoxDecoration(
              color: isMore ? AppColors.primaryLight.withOpacity(0.3) : AppColors.grey100,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: Icon(
              icon, 
              color: isMore ? AppColors.primaryDark : AppColors.grey800,
              size: AppDimensions.iconLarge,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            label, 
            textAlign: TextAlign.center, 
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context, {
    required String title,
    required String status,
    required String name,
    required String role,
    required String completion,
    // String imageUrl = '', // Included for completeness
  }) {
    final statusColor = status == 'In Progress' ? AppColors.warning : AppColors.success;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.marginMedium, vertical: AppDimensions.marginSmall),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8, vertical: AppDimensions.spacing4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Row(
              children: [
                CircleAvatar(
                  radius: AppDimensions.avatarSmall / 2,
                  // backgroundImage: imageUrl.isNotEmpty ? AssetImage(imageUrl) : null,
                  backgroundColor: AppColors.grey400,
                  child: Text(name[0], style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary)),
                ),
                const SizedBox(width: AppDimensions.spacing12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(role, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Est. completion: $completion', 
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradieCard(String name, String role, double rating, String imageUrl) {
    return SizedBox(
      width: 120,
      child: Card(
        margin: const EdgeInsets.only(right: AppDimensions.spacing12, bottom: AppDimensions.spacing8), // Adjust margin for list
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      color: AppColors.grey200,
                      // image: DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.cover),
                    ),
                    child: Center(
                      child: Text(
                        name, 
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.grey600),
                        textAlign: TextAlign.center,
                      ),
                    ), 
                  ),
                  Positioned(
                    top: AppDimensions.spacing4,
                    right: AppDimensions.spacing4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Text(name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
              Text(role, style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.warning, size: AppDimensions.iconSmall),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(rating.toString(), style: AppTextStyles.labelMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}