import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/tradie_recommendation.dart';
import '../viewmodels/urgent_booking_viewmodel.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  final TradieRecommendation tradie;
  final int jobId;

  const BookingFlowScreen({super.key, required this.tradie, required this.jobId});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Per-step form keys
  final _serviceFormKey = GlobalKey<FormState>();
  final _scheduleFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();

  // Form controllers
  final _serviceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Focus nodes
  final _serviceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _nameFocus = FocusNode();

  final List<String> _steps = [
    'Service',
    'Schedule',
    'Contact',
    'Review',
    'Sent',
  ];

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
    _serviceFocus.dispose();
    _descriptionFocus.dispose();
    _dateFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validate current step before advancing
    final validators = [_serviceFormKey, _scheduleFormKey, _contactFormKey];
    if (_currentStep < validators.length) {
      final currentKey = validators[_currentStep];
      if (currentKey.currentState != null &&
          !currentKey.currentState!.validate()) {
        return;
      }
    }

    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitBooking() async {
    // Ensure contact step is valid before submitting
    if (!(_contactFormKey.currentState?.validate() ?? true)) return;

    final ok = await ref.read(urgentBookingViewModelProvider.notifier)
        .createUrgentBooking(
      jobId: widget.jobId,
      notes: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priorityLevel: 'high',
      serviceName:
          _serviceController.text.trim().isEmpty ? null : _serviceController.text.trim(),
      preferredDate:
          _dateController.text.trim().isEmpty ? null : _dateController.text.trim(),
      preferredTimeWindow:
          _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
      contactName:
          _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      contactEmail:
          _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      contactPhone:
          _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address:
          _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
    );

    if (ok) {
      // Move to sent step
      if (_currentStep < _steps.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      if (mounted) {
        final err = ref.read(urgentBookingViewModelProvider).createUrgentBookingError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err ?? 'Failed to create urgent booking')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgentState = ref.watch(urgentBookingViewModelProvider);
    final isSubmitting = urgentState.isCreatingUrgentBooking;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text('Book ${widget.tradie.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // onPressed: () => Navigator.pop(context),
          onPressed: () => context.go('/urgent-booking'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Text(
                  'Step ${_currentStep + 1} of 5: ${_steps[_currentStep]}',
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
                  color: Colors.grey.withAlpha(30),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey[200],
                  child: widget.tradie.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            widget.tradie.profileImage!,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.person, size: 26, color: Colors.grey[600]),
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
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
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

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
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
                _buildSentStep(),
              ],
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (urgentState.createUrgentBookingError != null &&
                    _currentStep == _steps.length - 2) ...[
                  Text(
                    urgentState.createUrgentBookingError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    if (_currentStep > 0 && _currentStep < _steps.length - 1)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting ? null : _previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Colors.blue[600] ?? Colors.blue,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Back"),
                        ),
                      ),
                    if (_currentStep > 0 && _currentStep < _steps.length - 1)
                      const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : _currentStep < _steps.length - 2
                                ? _nextStep
                                : _currentStep == _steps.length - 2
                                    ? _submitBooking
                                    : () => context.go('/urgent-booking'),
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
                              _currentStep < _steps.length - 2
                                  ? 'Continue'
                                  : _currentStep == _steps.length - 2
                                      ? 'Submit'
                                      : 'Done',
                            ),
                            if (isSubmitting) ...[
                              const SizedBox(width: 12),
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStep() {
    return _buildStepContainer([
      const Text(
        'What service do you need?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Select a service',
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
        onChanged: (value) => _serviceController.text = value ?? '',
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _descriptionController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Describe the job details...',
        ),
        maxLines: 4,
      ),
    ]);
  }

  Widget _buildScheduleStep() {
    return _buildStepContainer([
      const Text(
        'When would you like the work done?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dateController,
        readOnly: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
          hintText: 'Choose preferred date',
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 7)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            _dateController.text = '${date.day}/${date.month}/${date.year}';
          }
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.access_time),
          hintText: 'Select preferred time',
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
        ],
        onChanged: (value) => _timeController.text = value ?? '',
      ),
    ]);
  }

  Widget _buildContactStep() {
    return _buildStepContainer([
      const Text(
        'How can we reach you?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      _buildTextField(_nameController, 'Full Name'),
      const SizedBox(height: 12),
      _buildTextField(_emailController, 'Email Address'),
      const SizedBox(height: 12),
      _buildTextField(_phoneController, 'Phone Number'),
      const SizedBox(height: 12),
      _buildTextField(_addressController, 'Service Address'),
    ]);
  }

  Widget _buildReviewStep() {
    return _buildStepContainer([
      const Text(
        'Review Your Booking',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      _buildReviewCard('Service Details', [
        'Service: ${_serviceController.text.isEmpty ? 'Not selected' : _serviceController.text}',
        'Description: ${_descriptionController.text.isEmpty ? 'Not provided' : _descriptionController.text}',
      ], Icons.build),
      const SizedBox(height: 12),
      _buildReviewCard('Schedule', [
        'Date: ${_dateController.text.isEmpty ? 'Not selected' : _dateController.text}',
        'Time: ${_timeController.text.isEmpty ? 'Not selected' : _timeController.text}',
      ], Icons.schedule),
      const SizedBox(height: 12),
      _buildReviewCard('Contact Info', [
        'Name: ${_nameController.text.isEmpty ? 'Not provided' : _nameController.text}',
        'Email: ${_emailController.text.isEmpty ? 'Not provided' : _emailController.text}',
        'Phone: ${_phoneController.text.isEmpty ? 'Not provided' : _phoneController.text}',
        'Address: ${_addressController.text.isEmpty ? 'Not provided' : _addressController.text}',
      ], Icons.person),
    ]);
  }

  Widget _buildSentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Booking Request Sent!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Your request has been sent to ${widget.tradie.name}. They’ll contact you soon to confirm details.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/urgent-booking'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('View my urgent bookings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepContainer(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hint,
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
            color: Colors.grey.withAlpha(25),
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
          const SizedBox(height: 8),
          ...details.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(d, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
