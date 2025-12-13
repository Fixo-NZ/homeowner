import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './../../../core/network/api_result.dart';
import '../viewmodels/job_posting_viewmodel.dart';
import './job_post_form_screen.dart';
import '../models/job_posting_models.dart';

class JobEditScreen extends ConsumerStatefulWidget {
  final int jobId;

  const JobEditScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobEditScreen> createState() => _JobEditScreenState();
}

class _JobEditScreenState extends ConsumerState<JobEditScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadJobData());
  }

  Future<void> _loadJobData() async {
    try {
      final repository = ref.read(jobPostingRepositoryProvider);
      final result = await repository.getJobOfferDetails(widget.jobId);

      if (result is Success<JobPostResponse>) {
        final job = result.data;
        final viewModel = ref.read(jobPostingViewModelProvider.notifier);

        // 1. Create complete CategoryModel from job data
        final category = CategoryModel(
          id: job.serviceCategoryId,
          name: job.category?['name'] as String? ?? 'Unknown Category',
          description: job.category?['description'] as String? ?? '',
          icon: job.category?['icon'] as String?,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 2. Create complete ServiceModels from job data
        final List<ServiceModel> services = [];
        if (job.services != null) {
          for (final serviceData in job.services!) {
            services.add(ServiceModel(
              id: serviceData['id'] as int? ?? 0,
              name: serviceData['name'] as String? ?? 'Unknown Service',
              description: serviceData['description'] as String?,
              status: 'active',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
          }
        }

        // 3. Get existing photo URLs
        final existingPhotoUrls = job.allPhotoUrls;

        // 4. Convert job type
        final JobType jobType;
        switch (job.jobType.toLowerCase()) {
          case 'urgent':
            jobType = JobType.urgent;
            break;
          case 'recurrent':
            jobType = JobType.recurrent;
            break;
          default:
            jobType = JobType.standard;
        }

        // 5. Convert job size
        final JobSize jobSize;
        switch (job.jobSize.toLowerCase()) {
          case 'small':
            jobSize = JobSize.small;
            break;
          case 'large':
            jobSize = JobSize.large;
            break;
          default:
            jobSize = JobSize.medium;
        }

        // 6. Convert frequency
        Frequency? frequency;
        if (job.frequency != null && job.frequency!.isNotEmpty) {
          switch (job.frequency!.toLowerCase()) {
            case 'daily':
              frequency = Frequency.daily;
              break;
            case 'weekly':
              frequency = Frequency.weekly;
              break;
            case 'monthly':
              frequency = Frequency.monthly;
              break;
            case 'quarterly':
              frequency = Frequency.quarterly;
              break;
            case 'yearly':
              frequency = Frequency.yearly;
              break;
            case 'custom':
              frequency = Frequency.custom;
              break;
          }
        }

        // 7. Create a complete JobPostFormData with ALL the job information
        final formData = JobPostFormData(
          jobId: job.id,
          selectedCategory: category, // This is the key - set the complete CategoryModel
          selectedServices: services,
          jobType: jobType,
          frequency: frequency,
          preferredDate: job.preferredDate,
          startDate: job.startDate,
          endDate: job.endDate,
          title: job.title,
          jobSize: jobSize,
          description: job.description,
          address: job.address,
          photoFiles: const [],
          existingPhotoUrls: existingPhotoUrls,
        );

        // 8. Load this complete form data into the viewmodel
        viewModel.loadExistingJobIntoForm(formData);

        // 9. Also load categories (for background, but not needed for display)
        Future.microtask(() => viewModel.loadCategories());

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load job';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Job'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Job'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJobData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // The viewmodel already has everything pre-loaded
    return JobPostFormScreen(
      isEditMode: true,
      jobId: widget.jobId,
    );
  }
}