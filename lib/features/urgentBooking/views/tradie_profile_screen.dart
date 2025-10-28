import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:go_router/go_router.dart';
import '../models/tradie_recommendation.dart';
import 'booking_flow_screen.dart';

class TradieProfileScreen extends ConsumerStatefulWidget {
  final TradieRecommendation tradie;

  const TradieProfileScreen({super.key, required this.tradie});

  @override
  ConsumerState<TradieProfileScreen> createState() =>
      _TradieProfileScreenState();
}


class TradieRecommendationsScreen extends StatefulWidget {
  const TradieRecommendationsScreen({super.key});

  @override
  State<TradieRecommendationsScreen> createState() =>
      _TradieRecommendationsScreenState();
}

class _TradieRecommendationsScreenState
    extends State<TradieRecommendationsScreen>
    with TickerProviderStateMixin {
  bool showFilterPanel = false;

  // Active filters (editable) and appliedFilters (used to filter list)
  Map<String, dynamic> filters = {
    'tradeType': 'Any category',
    'preferredTime': 'Anytime',
    'radius': 25,
    'budget': 550,
  };

  Map<String, dynamic> appliedFilters = {};

  // sample professionals data (converted from the React fixture)
  final List<Map<String, dynamic>> professionals = [
    {
      'id': 1,
      'name': 'James Mitchell',
      'role': 'Licensed Electrician',
      'rating': 4.9,
      'reviews': 127,
      'jobs': 342,
      'location': 'Ponsonby, Auckland',
      'distance': '1.8 km',
      'availability': 'Available today',
      'rate': '\$85/hr',
      'badges': ['Top'],
      'verified': true,
      'services': ['Residential', 'Commercial', 'Emergency'],
    },
    {
      'id': 2,
      'name': 'Sarah Thompson',
      'role': 'Master Plumber',
      'rating': 4.8,
      'reviews': 93,
      'jobs': 256,
      'location': 'Parnell, Auckland',
      'distance': '2.5 km',
      'availability': 'Available tomorrow',
      'rate': '\$95/hr',
      'badges': ['Top'],
      'verified': true,
      'services': ['Leak Repair', 'Installation', 'Maintenance'],
    },
    {
      'id': 3,
      'name': 'Michael Chen',
      'role': 'Carpenter',
      'rating': 4.7,
      'reviews': 68,
      'jobs': 189,
      'location': 'Auckland CBD',
      'distance': '3.2 km',
      'availability': 'Available today',
      'rate': '\$80/hr',
      'badges': [],
      'verified': true,
      'services': ['Custom Build', 'Renovation', 'Repair'],
    },
  ];

  List<Map<String, dynamic>> get filteredPros {
    if (appliedFilters.isEmpty) return professionals;
    return professionals.where((pro) {
      final trade = appliedFilters['tradeType'] as String?;
      if (trade != null && trade != 'Any category') {
        if (!pro['role'].toString().toLowerCase().contains(
          trade.toLowerCase(),
        )) {
          return false;
        }
      }
      // radius and budget are illustrative; professionals don't include numeric
      // radius/budget fields in this fixture so those checks are omitted.
      return true;
    }).toList();
  }

  void _applyFilters() {
    setState(() {
      appliedFilters = Map<String, dynamic>.from(filters);
      showFilterPanel = false;
    });
  }

  void _resetFilters() {
    setState(() {
      filters = {
        'tradeType': 'Any category',
        'preferredTime': 'Anytime',
        'radius': 25,
        'budget': 550,
      };
      appliedFilters = Map<String, dynamic>.from(filters);
    });
  }

  @override
  void initState() {
    super.initState();
    appliedFilters = Map<String, dynamic>.from(filters);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final panelWidth = media.size.width < 760 ? media.size.width : 360.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Find Your Tradie',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => showFilterPanel = true),
            icon: const Icon(Icons.filter_list, color: Color(0xFF1E3A8A)),
            tooltip: 'Open filters',
          ),
        ],
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.place,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${filteredPros.length} professionals available nearby',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Best Match',
                            style: TextStyle(
                              color: Color(0xFF1E40AF),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredPros.length,
                  itemBuilder: (context, idx) {
                    final pro = filteredPros[idx];
                    return _ProfessionalCard(
                      pro: pro,
                      onViewProfile: () {
                        // Navigate to existing profile screen using tradie model if available
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TradieProfileScreen(
                              tradie: TradieRecommendation(
                                id: pro['id'] as int,
                                name: pro['name'] as String,
                                occupation: pro['role'] as String,
                                // minimal mapping; other required fields filled with defaults
                                serviceArea: pro['location'] as String? ?? '',
                                availability:
                                    pro['availability'] as String? ?? 'unknown',
                                profileImage: null,
                                hourlyRate: double.tryParse(
                                  (pro['rate'] as String)
                                      .replaceAll('\$', '')
                                      .replaceAll('/hr', ''),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onBookNow: () {
                        // simple placeholder action
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Book Now tapped')),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Backdrop + sliding panel
          if (showFilterPanel)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => showFilterPanel = false),
                // Replace deprecated withOpacity usage with Color.fromRGBO
                child: Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
              ),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            right: showFilterPanel ? 0 : -panelWidth,
            top: 0,
            bottom: 0,
            width: panelWidth,
            child: Material(
              elevation: 12,
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  children: [
                    // header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter & Adjust Search',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => showFilterPanel = false),
                            icon: const Icon(Icons.close),
                            tooltip: 'Close filters',
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Trade Type',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: filters['tradeType'] as String,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Any category',
                                  child: Text('Any category'),
                                ),
                                DropdownMenuItem(
                                  value: 'Electrician',
                                  child: Text('Electrician'),
                                ),
                                DropdownMenuItem(
                                  value: 'Plumber',
                                  child: Text('Plumber'),
                                ),
                                DropdownMenuItem(
                                  value: 'Carpenter',
                                  child: Text('Carpenter'),
                                ),
                              ],
                              onChanged: (v) => setState(
                                () =>
                                    filters['tradeType'] = v ?? 'Any category',
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Preferred Time',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: filters['preferredTime'] as String,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Anytime',
                                  child: Text('Anytime'),
                                ),
                                DropdownMenuItem(
                                  value: 'Today',
                                  child: Text('Today'),
                                ),
                                DropdownMenuItem(
                                  value: 'Tomorrow',
                                  child: Text('Tomorrow'),
                                ),
                                DropdownMenuItem(
                                  value: 'This Week',
                                  child: Text('This Week'),
                                ),
                              ],
                              onChanged: (v) => setState(
                                () => filters['preferredTime'] = v ?? 'Anytime',
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            const Text(
                              'Radius',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Slider(
                              value: (filters['radius'] as int).toDouble(),
                              min: 1,
                              max: 50,
                              divisions: 49,
                              label: '${filters['radius']} km',
                              onChanged: (v) =>
                                  setState(() => filters['radius'] = v.round()),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Budget',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Slider(
                              value: (filters['budget'] as int).toDouble(),
                              min: 100,
                              max: 1000,
                              divisions: 18,
                              label: '\$${filters['budget']}/hr',
                              onChanged: (v) =>
                                  setState(() => filters['budget'] = v.round()),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton(
                                  onPressed: () => setState(
                                    () => filters['tradeType'] = 'Any category',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E40AF),
                                  ),
                                  child: const Text('Best match'),
                                ),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Nearest First'),
                                ),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Top Rated'),
                                ),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Lowest Price'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _resetFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                              ),
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                              ),
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final Map<String, dynamic> pro;
  final VoidCallback onViewProfile;
  final VoidCallback onBookNow;

  const _ProfessionalCard({
    required this.pro,
    required this.onViewProfile,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            pro['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if ((pro['badges'] as List).contains('Top'))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E40AF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '⚡ Top',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pro['role'],
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${pro['rating']}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${pro['reviews']})',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  pro['rate'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: (pro['services'] as List)
                  .map<Widget>(
                    (s) => Chip(
                      label: Text(s),
                      backgroundColor: const Color(0xFFEFF6FF),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewProfile,
                    child: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBookNow,
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
}

class _TradieProfileScreenState extends ConsumerState<TradieProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              'Back to List',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(200),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      child: widget.tradie.profileImage != null
                          ? ClipOval(
                              child: Image.network(
                                widget.tradie.profileImage!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey[600],
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tradie.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.tradie.occupation,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildBadge('Verified', Icons.check_circle),
                              const SizedBox(width: 8),
                              _buildBadge('Top Rated', Icons.star),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.tradie.formattedRating} (${widget.tradie.reviewCount ?? 127})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.work_outline,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.tradie.jobsCompleted ?? 342} jobs',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.tradie.formattedHourlyRate,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tab bar
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.blue[600],
                  labelColor: Colors.blue[600],
                  unselectedLabelColor: Colors.grey[600],
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Work'),
                    Tab(text: 'Reviews'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildWorkTab(), _buildReviewsTab()],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(51),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookingFlowScreen(tradie: widget.tradie),
                ),
              );
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
              'Book Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Professional Background
          _buildSection('Professional Background', Icons.business, [
            const Text(
              'Experience: 12 years',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Licensed electrician with over 12 years of experience in residential and commercial electrical work. Specialized in energy-efficient installations, smart home systems, and emergency repairs. Committed to delivering safe, reliable, and code-compliant electrical solutions.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ]),
          const SizedBox(height: 24),

          // Certifications
          _buildSection('Certifications', Icons.school, [
            _buildCertificationCard(
              'Electrical Contractor License',
              'NSW Fair Trading • 2012',
            ),
            const SizedBox(height: 12),
            _buildCertificationCard(
              'Restricted Electrical License',
              'NSW Fair Trading • 2015',
            ),
            const SizedBox(height: 12),
            _buildCertificationCard(
              'Solar Installation Certificate',
              'Clean Energy Council • 2018',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildWorkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Work
          _buildSection('Recent Work', Icons.photo_library, [
            _buildProjectCard(
              'Complete Home Rewiring',
              'September 2025',
              'Full electrical rewiring of a 4-bedroom home in Bondi including LED lighting upgrades and smart switches.',
              'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400',
            ),
            const SizedBox(height: 16),
            _buildProjectCard(
              'Modern Office Installation',
              'August 2025',
              'Smart lighting and power installation for modern office space with glass partitions.',
              'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Reviews
          _buildSection('Customer Reviews', Icons.chat_bubble_outline, [
            // Overall rating
            Center(
              child: Column(
                children: [
                  Text(
                    widget.tradie.formattedRating,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(
                        5,
                        (index) =>
                            Icon(Icons.star, color: Colors.amber, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.tradie.reviewCount ?? 127} reviews',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Individual reviews
            _buildReviewCard(
              'Sarah L.',
              '2 weeks ago',
              'Lighting Installation',
              'James did an excellent job installing new lighting throughout our home. Professional, punctual, and cleaned up after himself. Highly recommend!',
            ),
            const SizedBox(height: 16),
            _buildReviewCard(
              'Michael P.',
              '1 month ago',
              'Electrical Repair',
              'Very knowledgeable and explained everything clearly. Fixed our electrical issues quickly and efficiently.',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildCertificationCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
    String title,
    String date,
    String description,
    String imageUrl,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    String name,
    String date,
    String serviceTag,
    String comment,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  serviceTag,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(Icons.star, color: Colors.amber, size: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}
