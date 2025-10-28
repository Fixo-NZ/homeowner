import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/urgent_booking_viewmodel.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  ConsumerState<CreateServiceScreen> createState() =>
      _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  int _selectedCategoryId = 1; // Default category
  final int _homeownerId =
      1; // Default homeowner ID - in real app this would come from auth

  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Electrical'},
    {'id': 2, 'name': 'Plumbing'},
    {'id': 3, 'name': 'Carpentry'},
    {'id': 4, 'name': 'Painting'},
    {'id': 5, 'name': 'Cleaning'},
    {'id': 6, 'name': 'Gardening'},
    {'id': 7, 'name': 'HVAC'},
    {'id': 8, 'name': 'Roofing'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(urgentBookingViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Service Request'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/urgent-booking'),

          // onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Category
              const Text(
                'Service Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select a category',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Job Description
              const Text(
                'Job Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                      'Please describe the work you need done in detail...',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a job description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Location
              const Text(
                'Service Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the address where service is needed',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isCreatingService ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: state.isCreatingService
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Create Service Request',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              // Error Message
              if (state.createServiceError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[200] ?? Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.createServiceError!,
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(urgentBookingViewModelProvider.notifier)
        .createService(
          homeownerId: _homeownerId,
          jobCategoryId: _selectedCategoryId,
          jobDescription: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service request created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.maybePop(context);
    }
  }
}
