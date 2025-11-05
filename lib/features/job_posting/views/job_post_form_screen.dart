import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tradie/core/services/photo_service.dart';
import 'package:tradie/features/job_posting/models/job_posting_models.dart';
import 'package:tradie/features/job_posting/viewmodels/job_posting_viewmodel.dart';

class JobPostFormScreen extends ConsumerStatefulWidget {
  const JobPostFormScreen({super.key});

  @override
  ConsumerState<JobPostFormScreen> createState() => _JobPostFormScreenState();
}

class _JobPostFormScreenState extends ConsumerState<JobPostFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize form with existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formData = ref.read(jobPostingViewModelProvider).formData;
      _titleController.text = formData.title;
      _descriptionController.text = formData.description ?? '';
      _addressController.text = formData.address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobPostingViewModelProvider);
    final formData = state.formData;
    final viewModel = ref.read(jobPostingViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post a Job',
          style: TextStyle(
            color: Colors.black, // Ensure text is black
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white, // Keep white background
        foregroundColor: Colors.black, // This should make icons black
        elevation: 2, // Add slight shadow for separation
        iconTheme: const IconThemeData(color: Colors.black),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Column(
        children: [
          // Category Description
          if (formData.selectedCategory?.description != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Text(
                formData.selectedCategory!.description!,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Type Toggle Switch
                  _buildJobTypeToggle(viewModel, formData.jobType),
                  const SizedBox(height: 16),

                  // Dynamic Date Fields based on Job Type
                  if (formData.jobType == JobType.standard) ...[
                    _buildDateSection(
                      title: 'Preferred Date',
                      hint: 'mm/dd/yyyy',
                      onTap: () =>
                          _selectDate(context, viewModel, isStandard: true),
                    ),
                  ] else if (formData.jobType == JobType.recurrent) ...[
                    _buildDateSection(
                      title: 'Preferred Start Date',
                      hint: 'mm/dd/yyyy',
                      onTap: () =>
                          _selectDate(context, viewModel, isStartDate: true),
                    ),
                    const SizedBox(height: 16),
                    _buildDateSection(
                      title: 'End Date (Optional)',
                      hint: 'mm/dd/yyyy',
                      onTap: () =>
                          _selectDate(context, viewModel, isEndDate: true),
                    ),
                    const SizedBox(height: 16),
                    // Frequency Selection for Recurrent Jobs
                    _buildFrequencySelector(viewModel, formData.frequency),
                  ],

                  const SizedBox(height: 24),

                  // Job Information Title
                  const Text(
                    'Job Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Job Title
                  _buildTextField(
                    controller: _titleController,
                    label: 'Job Title',
                    hint: 'e.g. Light Installation',
                    onChanged: viewModel.updateTitle,
                  ),
                  const SizedBox(height: 16),

                  // Services
                  _buildServicesField(formData, context),
                  const SizedBox(height: 16),

                  // Job Size
                  _buildJobSizeSelector(viewModel, formData.jobSize),
                  const SizedBox(height: 16),

                  // Description
                  _buildDescriptionField(viewModel),
                  const SizedBox(height: 24),

                  // Address Section
                  _buildSection(
                    title: 'Address',
                    child: TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Enter your address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: viewModel.updateAddress,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Photo Upload Section
                  _buildPhotoUploadSection(formData, viewModel),
                  const SizedBox(height: 32),

                  // Post Job Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => _submitForm(viewModel, formData),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Post Job',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobTypeToggle(
    JobPostingViewModel viewModel,
    JobType currentType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Standard Job Toggle
              Expanded(
                child: GestureDetector(
                  onTap: () => viewModel.updateJobType(JobType.standard),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: currentType == JobType.standard
                          ? Colors.blue
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Standard Job',
                        style: TextStyle(
                          color: currentType == JobType.standard
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Recurrent Job Toggle
              Expanded(
                child: GestureDetector(
                  onTap: () => viewModel.updateJobType(JobType.recurrent),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: currentType == JobType.recurrent
                          ? Colors.blue
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Recurrent Job',
                        style: TextStyle(
                          color: currentType == JobType.recurrent
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection({
    required String title,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(hint, style: TextStyle(color: Colors.grey[500])),
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector(
    JobPostingViewModel viewModel,
    Frequency? currentFrequency,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequency',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: Frequency.values.map((frequency) {
              return RadioListTile<Frequency>(
                title: Text(_getFrequencyLabel(frequency)),
                value: frequency,
                groupValue: currentFrequency,
                onChanged: (value) => viewModel.updateFrequency(value),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildJobSizeSelector(
    JobPostingViewModel viewModel,
    JobSize currentSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: JobSize.values.map((size) {
              return RadioListTile<JobSize>(
                title: Text(_getJobSizeLabel(size)),
                value: size,
                groupValue: currentSize,
                onChanged: (value) => viewModel.updateJobSize(value!),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildServicesField(JobPostFormData formData, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(
              formData.selectedServices.isNotEmpty
                  ? '${formData.selectedServices.length} services selected'
                  : 'Select Services',
              style: TextStyle(
                color: formData.selectedServices.isNotEmpty
                    ? Colors.black
                    : Colors.grey[500],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.push('/job/services');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(JobPostingViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter job description here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: viewModel.updateDescription,
        ),
        const SizedBox(height: 8),
        Text(
          '${_descriptionController.text.length}/300 characters',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadSection(
    JobPostFormData formData,
    JobPostingViewModel viewModel,
  ) {
    return _buildSection(
      title: 'Upload Photos (${formData.photoFiles.length}/5)',
      child: Column(
        children: [
          // Photo Grid
          if (formData.photoFiles.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: formData.photoFiles.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(formData.photoFiles[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => viewModel.removePhoto(index),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Upload Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final photos = await PhotoService.pickImages();
                      if (photos.isNotEmpty) {
                        viewModel.addPhotoFiles(photos);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to pick images: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final photo = await PhotoService.takePhoto();
                      if (photo != null) {
                        viewModel.addPhotoFiles([photo]);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to take photo: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          // File size info
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Maximum 5 photos, 5MB each',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  String _getFrequencyLabel(Frequency frequency) {
    switch (frequency) {
      case Frequency.daily:
        return 'Daily';
      case Frequency.weekly:
        return 'Weekly';
      case Frequency.monthly:
        return 'Monthly';
      case Frequency.quarterly:
        return 'Quarterly';
      case Frequency.yearly:
        return 'Yearly';
      case Frequency.custom:
        return 'Custom';
    }
  }

  String _getJobSizeLabel(JobSize size) {
    switch (size) {
      case JobSize.small:
        return 'Small (Few hours)';
      case JobSize.medium:
        return 'Medium (Half day)';
      case JobSize.large:
        return 'Large (Full day+)';
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    JobPostingViewModel viewModel, {
    bool isStandard = false,
    bool isStartDate = false,
    bool isEndDate = false,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isStandard) {
        viewModel.updatePreferredDate(picked);
      } else if (isStartDate) {
        viewModel.updateStartDate(picked);
      } else if (isEndDate) {
        viewModel.updateEndDate(picked);
      }
    }
  }

  void _submitForm(
    JobPostingViewModel viewModel,
    JobPostFormData formData,
  ) async {
    // Use the viewModel's validation method
    final validationError = viewModel.getFormValidationError();
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    // Now just call createJobPost without parameters
    final success = await viewModel.createJobPost();

    if (success && context.mounted) {
      context.go('/job/success');
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post job: ${viewModel.state.error}')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
