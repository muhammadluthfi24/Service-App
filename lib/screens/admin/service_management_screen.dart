import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/firebase_service_service.dart';
import '../../models/service_model.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ServiceModel> _filteredServices = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  final List<String> _categories = [
    'All',
    'Cleaning',
    'Repair',
    'Maintenance',
    'Installation',
    'Consultation',
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    await FirebaseServiceService.fetchServices();
    setState(() {
      _filteredServices = FirebaseServiceService.allServices;
      _isLoading = false;
    });
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = FirebaseServiceService.allServices.where((service) {
        final matchesSearch = service.name.toLowerCase().contains(query) ||
            service.description.toLowerCase().contains(query) ||
            service.category.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == 'All' || service.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 20),
          ),
        ),
        title: const Text(
          'Service Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.secondary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _showAddServiceDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Service', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    hintStyle: TextStyle(color: AppColors.grey),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                              _filterServices();
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.secondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Services List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredServices.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: _filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = _filteredServices[index];
                          return _buildServiceCard(service);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.miscellaneous_services_rounded, size: 80, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(
            'No services found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or add new services',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddServiceDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Service'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Service Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      service.serviceImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.miscellaneous_services_rounded, 
                                 color: AppColors.primary, size: 40);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Service Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: service.isActive 
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: service.isActive ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Color(0xFFFF8F28), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            service.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${service.reviewCount} reviews)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              service.description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditServiceDialog(service),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleServiceStatus(service),
                    icon: const Icon(Icons.power_settings_new_rounded, size: 16),
                    label: Text(service.isActive ? 'Deactivate' : 'Activate', 
                         style: const TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: service.isActive ? Colors.red : Colors.green,
                      side: BorderSide(color: service.isActive ? Colors.red : Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteServiceDialog(service),
                    icon: const Icon(Icons.delete_rounded, size: 16),
                    label: const Text('Delete', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final providerController = TextEditingController();
    final imageUrlController = TextEditingController();
    bool isPopular = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan gradient
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_business_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add New Service', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('Fill in the service details', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Form fields dengan design modern
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildModernTextField(
                            controller: nameController,
                            label: 'Service Name',
                            icon: Icons.title_rounded,
                            hint: 'Enter service name',
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildModernTextField(
                            controller: categoryController,
                            label: 'Category',
                            icon: Icons.category_rounded,
                            hint: 'e.g., Cleaning, Repair, Maintenance',
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildModernTextField(
                            controller: descriptionController,
                            label: 'Description',
                            icon: Icons.description_rounded,
                            hint: 'Describe the service...',
                            maxLines: 3,
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildModernTextField(
                            controller: priceController,
                            label: 'Price',
                            icon: Icons.attach_money_rounded,
                            hint: '0.00',
                            keyboardType: TextInputType.number,
                            prefixText: 'Rp ',
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildModernTextField(
                            controller: providerController,
                            label: 'Provider Name',
                            icon: Icons.business_rounded,
                            hint: 'Service provider name',
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildModernTextField(
                            controller: imageUrlController,
                            label: 'Image URL (Optional)',
                            icon: Icons.image_rounded,
                            hint: 'https://example.com/image.jpg',
                          ),
                          const SizedBox(height: 20),
                          
                          // Popular service toggle dengan design modern
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isPopular ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: isPopular ? AppColors.primary : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Popular Service', style: TextStyle(fontWeight: FontWeight.w600)),
                                      Text('Feature this service on homepage', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isPopular,
                                  onChanged: (value) => setState(() => isPopular = value),
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action buttons
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isNotEmpty && 
                                categoryController.text.isNotEmpty && 
                                descriptionController.text.isNotEmpty && 
                                priceController.text.isNotEmpty) {
                              
                              final newService = ServiceModel(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: nameController.text.trim(),
                                category: categoryController.text.trim(),
                                description: descriptionController.text.trim(),
                                price: double.tryParse(priceController.text) ?? 0.0,
                                rating: 5.0,
                                reviewCount: 0,
                                providerName: providerController.text.trim().isNotEmpty ? providerController.text.trim() : 'Servify Provider',
                                providerImage: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/100/100',
                                serviceImage: imageUrlController.text.trim().isNotEmpty ? imageUrlController.text.trim() : 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/300/200',
                                isActive: true,
                                isPopular: isPopular,
                                isApproved: true,
                              );

                              // Show loading indicator
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Text('Menyimpan service...'),
                                    ],
                                  ),
                                  backgroundColor: AppColors.primary,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              await FirebaseServiceService.addService(newService);
                              
                              Navigator.pop(context); // Close dialog
                              _loadServices(); // Refresh list
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Service berhasil ditambahkan!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Add Service', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Text(
                    label, 
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondary, fontSize: 14),
                  ),
                  if (isRequired) ...[
                    const SizedBox(width: 4),
                    const Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  void _showEditServiceDialog(ServiceModel service) {
    final nameController = TextEditingController(text: service.name);
    final categoryController = TextEditingController(text: service.category);
    final descriptionController = TextEditingController(text: service.description);
    final priceController = TextEditingController(text: service.price.toString());
    final providerController = TextEditingController(text: service.providerName);
    final imageUrlController = TextEditingController(text: service.serviceImage);
    bool isPopular = service.isPopular;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Service'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: providerController,
                    decoration: const InputDecoration(
                      labelText: 'Provider Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Popular Service'),
                    value: isPopular,
                    onChanged: (value) => setState(() => isPopular = value ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    providerController.text.isNotEmpty) {
                  
                  final updatedService = ServiceModel(
                    id: service.id,
                    name: nameController.text.trim(),
                    category: categoryController.text.trim(),
                    description: descriptionController.text.trim(),
                    price: double.tryParse(priceController.text) ?? 0.0,
                    rating: service.rating,
                    reviewCount: service.reviewCount,
                    providerName: providerController.text.trim(),
                    providerImage: service.providerImage,
                    serviceImage: imageUrlController.text.trim().isEmpty 
                        ? service.serviceImage
                        : imageUrlController.text.trim(),
                    isActive: service.isActive,
                    isPopular: isPopular,
                    createdAt: service.createdAt,
                  );

                  await FirebaseServiceService.updateService(updatedService);
                  Navigator.pop(context);
                  _loadServices();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Update Service'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleServiceStatus(ServiceModel service) async {
    await FirebaseServiceService.toggleServiceStatus(service.id);
    _loadServices();
  }

  void _showDeleteServiceDialog(ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete ${service.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseServiceService.deleteService(service.id);
              Navigator.pop(context);
              _loadServices();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
