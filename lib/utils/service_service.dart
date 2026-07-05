import '../models/service_model.dart';

class ServiceService {
  static final List<ServiceModel> _services = [];

  static List<ServiceModel> get allServices => List.unmodifiable(_services);
  static List<ServiceModel> get activeServices => _services.where((s) => s.isActive).toList();

  static void addService(ServiceModel service) {
    _services.add(service);
  }

  static void updateService(ServiceModel updatedService) {
    final index = _services.indexWhere((s) => s.id == updatedService.id);
    if (index != -1) {
      _services[index] = updatedService;
    }
  }

  static void deleteService(String serviceId) {
    _services.removeWhere((s) => s.id == serviceId);
  }

  static void toggleServiceStatus(String serviceId) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      final service = _services[index];
      _services[index] = ServiceModel(
        id: service.id,
        name: service.name,
        category: service.category,
        description: service.description,
        price: service.price,
        rating: service.rating,
        reviewCount: service.reviewCount,
        providerName: service.providerName,
        providerImage: service.providerImage,
        serviceImage: service.serviceImage,
        isPopular: service.isPopular,
        createdAt: service.createdAt,
        isActive: !service.isActive,
      );
    }
  }

  static void togglePopular(String serviceId) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      final service = _services[index];
      _services[index] = ServiceModel(
        id: service.id,
        name: service.name,
        category: service.category,
        description: service.description,
        price: service.price,
        rating: service.rating,
        reviewCount: service.reviewCount,
        providerName: service.providerName,
        providerImage: service.providerImage,
        serviceImage: service.serviceImage,
        isPopular: !service.isPopular,
        createdAt: service.createdAt,
        isActive: service.isActive,
      );
    }
  }

  static List<ServiceModel> getServicesByCategory(String category) {
    return _services.where((s) => s.category == category && s.isActive).toList();
  }

  static List<ServiceModel> getPopularServices() {
    return _services.where((s) => s.isPopular && s.isActive).toList();
  }

  // Initialize with sample services
  static void initializeServices() {
    if (_services.isEmpty) {
      _services.addAll([
        ServiceModel(
          id: 'service_001',
          name: 'Home Cleaning',
          category: 'Cleaning',
          description: 'Professional home cleaning service with eco-friendly products',
          price: 75.0,
          rating: 4.8,
          reviewCount: 124,
          providerName: 'CleanPro Services',
          providerImage: 'https://picsum.photos/seed/provider1/100/100',
          serviceImage: 'https://picsum.photos/seed/cleaning/300/200',
          isPopular: true,
        ),
        ServiceModel(
          id: 'service_002',
          name: 'AC Repair',
          category: 'Repair',
          description: 'Expert AC repair and maintenance services',
          price: 120.0,
          rating: 4.6,
          reviewCount: 89,
          providerName: 'CoolTech Solutions',
          providerImage: 'https://picsum.photos/seed/provider2/100/100',
          serviceImage: 'https://picsum.photos/seed/ac/300/200',
          isPopular: true,
        ),
        ServiceModel(
          id: 'service_003',
          name: 'Plumbing Services',
          category: 'Plumbing',
          description: 'Complete plumbing solutions for residential and commercial',
          price: 95.0,
          rating: 4.7,
          reviewCount: 156,
          providerName: 'PipeMaster Pro',
          providerImage: 'https://picsum.photos/seed/provider3/100/100',
          serviceImage: 'https://picsum.photos/seed/plumbing/300/200',
          isPopular: false,
        ),
        ServiceModel(
          id: 'service_004',
          name: 'Electrical Work',
          category: 'Electric',
          description: 'Licensed electricians for all your electrical needs',
          price: 110.0,
          rating: 4.9,
          reviewCount: 203,
          providerName: 'PowerFix Electric',
          providerImage: 'https://picsum.photos/seed/provider4/100/100',
          serviceImage: 'https://picsum.photos/seed/electric/300/200',
          isPopular: true,
        ),
      ]);
    }
  }
}
