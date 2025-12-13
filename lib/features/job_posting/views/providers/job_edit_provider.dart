// job_edit_provider.dart - FIXED VERSION

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../../models/job_posting_models.dart';
import '../../viewmodels/job_posting_viewmodel.dart';

final jobEditProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, jobId) async {
  try {
    final repository = ref.read(jobPostingRepositoryProvider);
    final result = await repository.getJobOfferDetails(jobId);
    
    if (result is Success<JobPostResponse>) {
      return _convertJobToFormData(result.data);
    } else {
      throw Exception('Failed to load job: ${(result as Failure).message}');
    }
  } catch (e) {
    throw Exception('Failed to load job: $e');
  }
});

// Provider to fetch job details by ID
final jobDetailProvider = FutureProvider.autoDispose.family<JobPostResponse?, int>(
  (ref, jobId) async {
    try {
      final repository = ref.read(jobPostingRepositoryProvider);
      final result = await repository.getJobOfferDetails(jobId);
      
      if (result is Success<JobPostResponse>) {
        return result.data;
      } else {
        throw Exception((result as Failure).message);
      }
    } catch (e) {
      throw Exception('Failed to load job: $e');
    }
  },
);

Map<String, dynamic> _convertJobToFormData(JobPostResponse job) {
  // Convert job type
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

  // Convert job size
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

  // Convert frequency
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

  // Get service IDs
  final List<String> serviceIds = [];
  if (job.services != null) {
    for (final service in job.services!) {
      if (service['id'] != null) {
        serviceIds.add(service['id'].toString());
      }
    }
  }

  return {
    'id': job.id,
    'title': job.title,
    'description': job.description ?? '',
    'address': job.address,
    'jobType': jobType,
    'jobSize': jobSize,
    'preferredDate': job.preferredDate,
    'startDate': job.startDate,
    'endDate': job.endDate,
    'frequency': frequency,
    'categoryId': job.serviceCategoryId.toString(),
    'categoryName': job.category?['name'] as String? ?? 'Category',
    'serviceIds': serviceIds,
    'photoUrls': job.allPhotoUrls,
  };
}