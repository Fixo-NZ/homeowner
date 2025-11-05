import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tradie/features/job_posting/models/job_posting_models.dart';
import 'package:tradie/features/job_posting/viewmodels/job_posting_viewmodel.dart';

class ServiceSelectionScreen extends ConsumerStatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  ConsumerState<ServiceSelectionScreen> createState() =>
      _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState
    extends ConsumerState<ServiceSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<int> _selectedServiceIds = [];

  @override
  void initState() {
    super.initState();
    final category = ref
        .read(jobPostingViewModelProvider)
        .formData
        .selectedCategory;
    if (category != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(jobPostingViewModelProvider.notifier)
            .loadServicesByCategory(category.id);
      });
    }

    // Initialize with currently selected services
    final currentSelectedServices = ref
        .read(jobPostingViewModelProvider)
        .formData
        .selectedServices;
    _selectedServiceIds.addAll(currentSelectedServices.map((s) => s.id));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobPostingViewModelProvider);
    final categoryName = state.formData.selectedCategory?.name ?? 'Services';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$categoryName Services',
          style: const TextStyle(
            color: Colors.black, // Ensure text is black
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white, // Keep white background
        foregroundColor: Colors.black, // Icons and text color
        elevation: 2, // Slight shadow for visibility
        iconTheme: const IconThemeData(color: Colors.black),
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final selectedServices =
                  state.servicesForCategory
                      ?.where(
                        (service) => _selectedServiceIds.contains(service.id),
                      )
                      .toList() ??
                  [];
              ref
                  .read(jobPostingViewModelProvider.notifier)
                  .selectServices(selectedServices);
              context.pop();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                // Implement search functionality if needed
              },
            ),
          ),

          // Services List
          Expanded(
            child: state.isLoading && state.servicesForCategory == null
                ? const Center(child: CircularProgressIndicator())
                : state.servicesForCategory != null
                ? ListView.builder(
                    itemCount: state.servicesForCategory!.length,
                    itemBuilder: (context, index) {
                      final service = state.servicesForCategory![index];
                      return _buildServiceItem(service);
                    },
                  )
                : state.error != null
                ? Center(child: Text("Error: ${state.error}"))
                : const Center(child: Text("No services available")),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(service.name, style: const TextStyle(fontSize: 16)),
        subtitle: service.description != null
            ? Text(
                service.description!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              )
            : null,
        value: _selectedServiceIds.contains(service.id),
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _selectedServiceIds.add(service.id);
            } else {
              _selectedServiceIds.remove(service.id);
            }
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
