import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:go_router/go_router.dart';
import '../models/tradie_recommendation.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  final TradieRecommendation tradie;

  const BookingFlowScreen({super.key, required this.tradie});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form controllers
  final _serviceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final List<String> _steps = ['Service', 'Schedule', 'Contact', 'Review'];

  @override
  void dispose() {
    _pageController.dispose();
    _serviceController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Book ${widget.tradie.name}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Text(
                  'Step ${_currentStep + 1} of 4: ${_steps[_currentStep]} Details',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _steps.asMap().entries.map((entry) {
                    int index = entry.key;
                    bool isActive = index <= _currentStep;

                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < _steps.length - 1 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.blue[600] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tradie info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  child: widget.tradie.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            widget.tradie.profileImage!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 24,
                                color: Colors.grey[600],
                              );
                            },
                          ),
                        )
                      : Icon(Icons.person, size: 24, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tradie.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.tradie.occupation,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.tradie.formattedRating,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildServiceStep(),
                _buildScheduleStep(),
                _buildContactStep(),
                _buildReviewStep(),
              ],
            ),
          ),

          // Continue button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentStep < _steps.length - 1
                    ? _nextStep
                    : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep < _steps.length - 1
                          ? 'Continue >'
                          : 'Submit Booking Request',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_currentStep == _steps.length - 1) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check, size: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What service do you need?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Service selection
          const Text(
            'Select Service *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Choose a service',
            ),
            items: const [
              DropdownMenuItem(
                value: 'Electrical Repair',
                child: Text('Electrical Repair'),
              ),
              DropdownMenuItem(
                value: 'Lighting Installation',
                child: Text('Lighting Installation'),
              ),
              DropdownMenuItem(
                value: 'Cable Installation',
                child: Text('Cable Installation'),
              ),
              DropdownMenuItem(
                value: 'Power Outlet Installation',
                child: Text('Power Outlet Installation'),
              ),
            ],
            onChanged: (value) {
              _serviceController.text = value ?? '';
            },
          ),
          const SizedBox(height: 16),

          // Job description
          const Text(
            'Job Description *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Please describe the work you need done in detail...',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            maxLength: 500,
            onChanged: (value) {
              setState(() {}); // Update character count
            },
          ),
          Text(
            '${_descriptionController.text.length}/500 characters (minimum 10)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Tip box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: Include specific details about the job, location within your property, any existing issues, and your expectations for the best quote.',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When would you like the work done?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Preferred date
          const Text(
            'Preferred Date *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _dateController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue[600]!),
              ),
              hintText: 'October 8th, 2025',
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: () {
                  // Show date picker
                },
              ),
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                _dateController.text = 'October ${date.day}th, ${date.year}';
              }
            },
          ),
          const SizedBox(height: 16),

          // Preferred time
          const Text(
            'Preferred Time *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '10:00 AM - 12:00 PM',
              prefixIcon: Icon(Icons.access_time),
            ),
            items: const [
              DropdownMenuItem(
                value: '9:00 AM - 11:00 AM',
                child: Text('9:00 AM - 11:00 AM'),
              ),
              DropdownMenuItem(
                value: '10:00 AM - 12:00 PM',
                child: Text('10:00 AM - 12:00 PM'),
              ),
              DropdownMenuItem(
                value: '1:00 PM - 3:00 PM',
                child: Text('1:00 PM - 3:00 PM'),
              ),
              DropdownMenuItem(
                value: '2:00 PM - 4:00 PM',
                child: Text('2:00 PM - 4:00 PM'),
              ),
            ],
            onChanged: (value) {
              _timeController.text = value ?? '';
            },
          ),
          const SizedBox(height: 16),

          // Note box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.amber[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: ${widget.tradie.name} is currently available next week. They will confirm the exact timing after reviewing your request.',
                    style: TextStyle(fontSize: 12, color: Colors.amber[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How can we reach you?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Full name
          const Text(
            'Full Name *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your full name',
            ),
          ),
          const SizedBox(height: 16),

          // Email
          const Text(
            'Email Address *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your email address',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Phone
          const Text(
            'Phone Number *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your phone number',
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Service address
          const Text(
            'Service Address *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '123 Main St, Sydney NSW 2000',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Full address where the service will be performed.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Booking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Service details
          _buildReviewCard('Service Details', [
            'Service: ${_serviceController.text.isNotEmpty ? _serviceController.text : "Cable Installation"}',
            'Description: ${_descriptionController.text.isNotEmpty ? _descriptionController.text : "dasdasdasd"}',
          ], Icons.build),
          const SizedBox(height: 12),

          // Schedule
          _buildReviewCard('Schedule', [
            'Date: ${_dateController.text.isNotEmpty ? _dateController.text : "Wednesday, October 8, 2025"}',
            'Time: ${_timeController.text.isNotEmpty ? _timeController.text : "10:00 AM - 12:00 PM"}',
          ], Icons.schedule),
          const SizedBox(height: 12),

          // Contact information
          _buildReviewCard('Contact Information', [
            'Name: ${_nameController.text.isNotEmpty ? _nameController.text : "dasd"}',
            'Email: ${_emailController.text.isNotEmpty ? _emailController.text : "lloydaaronryel.capili@lorma.edu"}',
            'Phone: ${_phoneController.text.isNotEmpty ? _phoneController.text : "123123123123"}',
            'Address: ${_addressController.text.isNotEmpty ? _addressController.text : "dasdasdas"}',
          ], Icons.location_on),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, List<String> details, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(icon, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...details.map(
            (detail) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(detail, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitBooking() {
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Booking Request Submitted'),
          ],
        ),
        content: Text(
          'Your booking request has been sent to ${widget.tradie.name}. They will contact you shortly to confirm the details.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
