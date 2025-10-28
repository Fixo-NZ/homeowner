import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/urgent_booking_viewmodel.dart';
import '../models/tradie_filter.dart';
import '../models/tradie_recommendation.dart';
import 'booking_flow_screen.dart';
import 'tradie_profile_screen.dart';

class TradieRecommendationsScreen extends ConsumerStatefulWidget {
  final int serviceId;

  const TradieRecommendationsScreen({super.key, required this.serviceId});

  @override
  ConsumerState<TradieRecommendationsScreen> createState() =>
      _TradieRecommendationsScreenState();
}

class _TradieRecommendationsScreenState
    extends ConsumerState<TradieRecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(urgentBookingViewModelProvider.notifier)
          .getTradieRecommendations(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(urgentBookingViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header section matching the image
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text(
                      'Find Your Tradie',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${state.recommendations.length} professionals available nearby',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Sorted by: ', style: TextStyle(fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Best Match',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(UrgentBookingState state) {
    if (state.isLoadingRecommendations) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.recommendationsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.recommendationsError}',
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(urgentBookingViewModelProvider.notifier)
                    .getTradieRecommendations(widget.serviceId);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.recommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'No Available Tradies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We couldn\'t find any tradies matching your requirements in your area right now. Try adjusting your search criteria or expanding your location range.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showFilterDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Modify Search',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(urgentBookingViewModelProvider.notifier)
            .getTradieRecommendations(widget.serviceId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.recommendations.length,
        itemBuilder: (context, index) {
          final tradie = state.recommendations[index];
          return _buildTradieCard(tradie);
        },
      ),
    );
  }

  Widget _buildTradieCard(TradieRecommendation tradie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile and basic info
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[200],
                  child: tradie.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            tradie.profileImage!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.grey[600],
                              );
                            },
                          ),
                        )
                      : Icon(Icons.person, size: 32, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tradie.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (tradie.isTopRated)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Top',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tradie.occupation,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating and stats row
            Row(
              children: [
                if (tradie.rating != null) ...[
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < (tradie.rating ?? 0).floor()
                              ? Colors.amber
                              : Colors.grey[300],
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tradie.formattedRating} (${tradie.reviewCount ?? 0})',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ],
                if (tradie.jobsCompleted != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tradie.jobsCompleted} jobs',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Location and availability
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tradie.serviceArea,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                if (tradie.distanceKm != null) ...[
                  Text(
                    tradie.formattedDistance,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  tradie.availabilityText,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Service tags (matching the image style)
            if (tradie.skills.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: tradie.skills.take(3).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue[200] ?? Colors.blue,
                      ),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Hourly rate
            if (tradie.hourlyRate != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tradie.formattedHourlyRate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showTradieProfile(context, tradie);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[600] ?? Colors.blue),
                      foregroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showBookingDialog(context, tradie);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTradieProfile(BuildContext context, TradieRecommendation tradie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TradieProfileScreen(tradie: tradie),
      ),
    );
  }

  void _showBookingDialog(BuildContext context, TradieRecommendation tradie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFlowScreen(tradie: tradie),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final viewModel = ref.read(urgentBookingViewModelProvider.notifier);
    final current = ref.read(urgentBookingViewModelProvider).filters;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filters',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              color: Colors.white,
              child: SafeArea(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    String tradeType = current.tradeType;
                    String preferredTime = current.preferredTime;
                    double radius = current.radiusKm;
                    int budget = current.budget;

                    return Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200] ?? Colors.grey,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Filter & Adjust Search',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Trade Type *',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: tradeType,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Any category',
                                      child: Text('Any category'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Electrical',
                                      child: Text('Electrical'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Plumbing',
                                      child: Text('Plumbing'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Carpentry',
                                      child: Text('Carpentry'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Painting',
                                      child: Text('Painting'),
                                    ),
                                  ],
                                  onChanged: (v) => setState(
                                    () => tradeType = v ?? 'Any category',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                const Text(
                                  'Preferred Time *',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: preferredTime,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Anytime',
                                      child: Text('Anytime'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Morning',
                                      child: Text('Morning'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Afternoon',
                                      child: Text('Afternoon'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Evening',
                                      child: Text('Evening'),
                                    ),
                                  ],
                                  onChanged: (v) => setState(
                                    () => preferredTime = v ?? 'Anytime',
                                  ),
                                ),
                                const SizedBox(height: 24),

                                const Text(
                                  'Radius',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('1km'),
                                    Expanded(
                                      child: Slider(
                                        value: radius,
                                        min: 1.0,
                                        max: 50.0,
                                        divisions: 49,
                                        label: '${radius.round()}km',
                                        onChanged: (v) =>
                                            setState(() => radius = v),
                                      ),
                                    ),
                                    Text('50km'),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                const Text(
                                  'Budget',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('\$100/hr'),
                                    Expanded(
                                      child: Slider(
                                        value: budget.toDouble(),
                                        min: 100.0,
                                        max: 1000.0,
                                        divisions: 90,
                                        label: '\$$budget',
                                        onChanged: (v) =>
                                            setState(() => budget = v.round()),
                                      ),
                                    ),
                                    Text('\$1000/hr'),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                const Text(
                                  'Sorted by:',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    _buildSortChip('Best match', true),
                                    _buildSortChip('Nearest First', false),
                                    _buildSortChip('Top Rated', false),
                                    _buildSortChip('Lowest Price', false),
                                  ],
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),

                        // Actions
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey[200] ?? Colors.grey,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    viewModel.resetFilters();
                                    Navigator.pop(context);
                                    // Optionally reload
                                    viewModel.applyFilters(widget.serviceId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                  ),
                                  child: const Text('Reset'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    viewModel.setFilters(
                                      TradieFilter(
                                        tradeType: tradeType,
                                        preferredTime: preferredTime,
                                        radiusKm: radius,
                                        budget: budget,
                                      ),
                                    );
                                    Navigator.pop(context);
                                    viewModel.applyFilters(widget.serviceId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[900],
                                  ),
                                  child: const Text('Apply'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  Widget _buildSortChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[600] : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
