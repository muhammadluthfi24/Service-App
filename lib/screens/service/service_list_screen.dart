import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../data/dummy_data.dart';
import '../../models/service_model.dart';
import '../../widgets/service_card.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatefulWidget {
  final String category;
  const ServiceListScreen({super.key, required this.category});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  late String _selectedCategory;
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceModel> get filteredServices {
    var list = DummyData.services;
    if (_selectedCategory != 'Semua') {
      list = list.where((s) => s.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Semua', ...DummyData.categories.map((c) => c.name)];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context))
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColors.secondary),
                          ),
                        ),
                      if (Navigator.canPop(context)) const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Semua Layanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                      ),
                      // Toggle view
                      GestureDetector(
                        onTap: () => setState(() => _isGridView = !_isGridView),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Cari layanan...',
                        hintStyle: TextStyle(color: AppColors.grey, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Category filter chips
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.lightGrey,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // Results count
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  Text(
                    '${filteredServices.length} layanan ditemukan',
                    style: const TextStyle(fontSize: 13, color: AppColors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // List / Grid
            Expanded(
              child: filteredServices.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: AppColors.lightGrey),
                          SizedBox(height: 16),
                          Text('Tidak ada layanan ditemukan', style: TextStyle(color: AppColors.grey)),
                        ],
                      ),
                    )
                  : _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return ServicePopularCard(
                              service: service,
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ServiceDetailScreen(service: service),
                              )),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return ServiceCard(
                              service: service,
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ServiceDetailScreen(service: service),
                              )),
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
