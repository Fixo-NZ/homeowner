import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tradie/features/job_posting/models/job_posting_models.dart';
import 'package:tradie/features/job_posting/viewmodels/job_posting_viewmodel.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobPostingViewModelProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobPostingViewModelProvider);

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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          const Divider(height: 1),

          // Browse Job Services Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Browse Job Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Categories List
          Expanded(
            child: state.isLoading && state.categories == null
                ? const Center(child: CircularProgressIndicator())
                : state.categories != null
                ? ListView.builder(
                    itemCount: state.categories!.length,
                    itemBuilder: (context, index) {
                      final category = state.categories![index];
                      return _buildCategoryItem(category);
                    },
                  )
                : state.error != null
                ? Center(child: Text("Error: ${state.error}"))
                : const Center(child: Text("No categories available")),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: category.iconUrl != null
            ? Image.network(
                category.iconUrl!,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.category, size: 40);
                },
              )
            : const Icon(Icons.category, size: 40),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: category.description != null
            ? Text(
                category.description!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ref
              .read(jobPostingViewModelProvider.notifier)
              .selectCategory(category);
          context.go('/job/form');
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
