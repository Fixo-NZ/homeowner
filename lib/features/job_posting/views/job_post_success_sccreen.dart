import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tradie/features/job_posting/viewmodels/job_posting_viewmodel.dart';

class JobPostSuccessScreen extends ConsumerWidget {
  const JobPostSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createdJob = ref.watch(jobPostingViewModelProvider).createdJob;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Posted',
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 20),
                  const Text(
                    'Job Posted Successfully!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your job request has been posted and tradies in your area will be notified.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Job Summary Card
                  if (createdJob != null) ...[
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              createdJob.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (createdJob.description != null &&
                                createdJob.description!.isNotEmpty)
                              Text(
                                createdJob.description!,
                                style: const TextStyle(fontSize: 14),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Divider(),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to view job page
                        // context.go('/job/view');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('View Job feature coming soon'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View Job'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(jobPostingViewModelProvider.notifier)
                            .resetForm();
                        context.go('/job');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Post Another Job'),
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
}
