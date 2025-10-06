import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/job_view_model.dart';
import '../widgets/job_category_tile.dart';
class JobCategoriesScreen extends ConsumerStatefulWidget {
  const JobCategoriesScreen({super.key});

  @override
  ConsumerState<JobCategoriesScreen> createState() =>
      _JobCategoriesScreenState();
}

class _JobCategoriesScreenState extends ConsumerState<JobCategoriesScreen> {
  String query = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(jobViewModelProvider.notifier).loadCategoriesWithServices(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobViewModelProvider);

    final filteredCategories =
        state.categories.where((c) {
          final search = query.toLowerCase();
          return c.categoryName.toLowerCase().contains(search) ||
              c.categorySubtitle.toLowerCase().contains(search);
        }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Browse Job Services")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Categories grid
            Expanded(
              child:
                  state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.error != null
                      ? Center(child: Text("Error: ${state.error}"))
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // two per row
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.2,
                            ),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          return JobCategoryTile(
                            category: category,
                            onTap: () {
                              // Navigate to next screen
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
