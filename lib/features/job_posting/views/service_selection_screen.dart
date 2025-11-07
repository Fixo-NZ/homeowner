import 'package:flutter/material.dart';
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

    final category =
        ref.read(jobPostingViewModelProvider).formData.selectedCategory;
    if (category != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(jobPostingViewModelProvider.notifier)
            .loadServicesByCategory(category.id);
      });
    }

    // Pre-fill with selected services
    final currentSelectedServices =
        ref.read(jobPostingViewModelProvider).formData.selectedServices;
    _selectedServiceIds.addAll(currentSelectedServices.map((s) => s.id));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobPostingViewModelProvider);
    final categoryName = state.formData.selectedCategory?.name ?? 'Services';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Select $categoryName Services',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.8,
        foregroundColor: Colors.black,
        shadowColor: Colors.black.withOpacity(0.05),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              final selectedServices = state.servicesForCategory
                      ?.where((service) => _selectedServiceIds.contains(service.id))
                      .toList() ??
                  [];
              ref
                  .read(jobPostingViewModelProvider.notifier)
                  .selectServices(selectedServices);
              context.pop();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.2),
                ),
              ),
              onChanged: (value) {
                // Add optional search filtering
              },
            ),
          ),

          // 🧾 Service List
          Expanded(
            child: state.isLoading && state.servicesForCategory == null
                ? const Center(child: CircularProgressIndicator())
                : state.servicesForCategory != null
                    ? ListView.separated(
                        itemCount: state.servicesForCategory!.length,
                        separatorBuilder: (context, _) => Divider(
                          color: Colors.grey.shade300,
                          height: 1,
                        ),
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
    final isSelected = _selectedServiceIds.contains(service.id);

    return CheckboxListTile(
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedServiceIds.add(service.id);
          } else {
            _selectedServiceIds.remove(service.id);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.blue,
      checkboxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        service.name,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
