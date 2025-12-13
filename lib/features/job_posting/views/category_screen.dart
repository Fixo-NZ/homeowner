import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:homeowner/features/job_posting/models/job_posting_models.dart';
import 'package:homeowner/features/job_posting/viewmodels/job_posting_viewmodel.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // ✅ Screen Title
            const Text(
              "Browse Job Services",
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 25,
                fontWeight: FontWeight.w600, // semibold
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => ref
                    . read(jobPostingViewModelProvider.notifier)
                    .filterCategories(value),
                style: const TextStyle(fontFamily: "Roboto"),
                decoration: const InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(fontFamily: "Roboto"),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Job Categories",
              style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            // ✅ CATEGORY GRID
            Expanded(
              child: Builder(
                builder: (_) {
                  if (state.isLoading && state.categories == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.filteredCategories == null ||
                      state.filteredCategories!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No categories available",
                        style: TextStyle(fontFamily: "Roboto"),
                      ),
                    );
                  }

                  final categories = state.filteredCategories!;

                  return GridView.builder(
                    itemCount: categories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(categories[index]);
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

  // ✅ CATEGORY CARD (LEFT ICON, CENTERED TEXT)
  Widget _buildCategoryCard(CategoryModel category) {
    return GestureDetector(
      onTap: () {
        ref.read(jobPostingViewModelProvider.notifier).resetForm();
        ref.read(jobPostingViewModelProvider.notifier)
            .selectCategory(category);
        context.go('/job/form');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Icon left aligned
            SizedBox(
              height: 40,
              width: 40,
              child: category.iconUrl != null
                  ? (category.iconUrl!.endsWith('.svg')
                      ? SvgPicture.network(category.iconUrl!)
                      : Image.network(category.iconUrl!))
                  : const Icon(Icons.category, size: 32),
            ),

            const SizedBox(height: 10),

            // ✅ Category name
            Text(
              category.name,
              style: const TextStyle(
                fontFamily: "Roboto",
                fontSize: 16,
                fontWeight: FontWeight.w500, // medium
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            // ✅ Description (single line + ...)
            Text(
              category.description ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: "Roboto",
                fontSize: 12,
                fontWeight: FontWeight.w400, // regular
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
