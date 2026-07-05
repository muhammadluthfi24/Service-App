import '../models/service_model.dart';
import '../config/firebase_config.dart';

class FirebaseServiceService {
  static final List<ServiceModel> _services = [];

  static List<ServiceModel> get allServices => _services;
  static List<ServiceModel> get activeServices => _services.where((s) => s.isActive).toList();
  static List<ServiceModel> get popularServices => _services.where((s) => s.isPopular).toList();

  // Initialize with sample services
  static Future<void> initializeServices() async {
    try {
      // Fetch from Firestore first
      await fetchServices();
      
      // If no services, add sample data
      if (_services.isEmpty) {
        final sampleServices = [
          ServiceModel(
            id: '1',
            name: 'Home Cleaning',
            category: 'Cleaning',
            description: 'Professional home cleaning services',
            price: 50.0,
            rating: 4.8,
            reviewCount: 124,
            providerName: 'CleanPro Services',
            providerImage: 'https://picsum.photos/seed/provider1/100/100',
            serviceImage: 'https://picsum.photos/seed/cleaning/200/200',
            isActive: true,
            isPopular: true,
          ),
          ServiceModel(
            id: '2',
            name: 'Plumbing',
            category: 'Repair',
            description: 'Expert plumbing services',
            price: 80.0,
            rating: 4.6,
            reviewCount: 89,
            providerName: 'PlumbMaster',
            providerImage: 'https://picsum.photos/seed/provider2/100/100',
            serviceImage: 'https://picsum.photos/seed/plumbing/200/200',
            isActive: true,
            isPopular: false,
          ),
          ServiceModel(
            id: '3',
            name: 'Electrical',
            category: 'Repair',
            description: 'Professional electrical services',
            price: 100.0,
            rating: 4.7,
            reviewCount: 156,
            providerName: 'ElectricPro',
            providerImage: 'https://picsum.photos/seed/provider3/100/100',
            serviceImage: 'https://picsum.photos/seed/electrical/200/200',
            isActive: true,
            isPopular: true,
          ),
        ];

        for (final service in sampleServices) {
          await saveService(service);
        }
        
        await fetchServices(); // Refresh the list
      }
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  // Fetch services from Firestore
  static Future<void> fetchServices() async {
    try {
      final snapshot = await FirebaseConfig.servicesCollection.get();
      _services.clear();
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          _services.add(ServiceModel(
            id: doc.id,
            name: data['name'] ?? '',
            category: data['category'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] ?? 0.0).toDouble(),
            rating: (data['rating'] ?? 0.0).toDouble(),
            reviewCount: data['reviewCount'] ?? 0,
            providerName: data['providerName'] ?? '',
            providerImage: data['providerImage'] ?? '',
            serviceImage: data['serviceImage'] ?? '',
            isPopular: data['isPopular'] ?? false,
            isApproved: data['isApproved'] ?? false,
            createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
          ));
        }
      }
      print('Fetched ${_services.length} services from Firestore');
    } catch (e) {
      print('Error fetching services: $e');
      // Add sample services if Firestore fails
      if (_services.isEmpty) {
        await _addSampleServices();
      }
    }
  }

  // Add sample services for testing
  static Future<void> _addSampleServices() async {
    final sampleServices = [
      ServiceModel(
        id: 'sample1',
        name: 'Home Cleaning',
        category: 'Cleaning',
        description: 'Professional home cleaning services',
        price: 50.0,
        rating: 4.8,
        reviewCount: 124,
        providerName: 'CleanPro Services',
        providerImage: 'https://picsum.photos/seed/provider1/100/100',
        serviceImage: 'https://picsum.photos/seed/cleaning/200/200',
        isActive: true,
        isPopular: true,
      ),
      ServiceModel(
        id: 'sample2',
        name: 'Plumbing Repair',
        category: 'Repair',
        description: 'Expert plumbing services',
        price: 80.0,
        rating: 4.6,
        reviewCount: 89,
        providerName: 'PlumbMaster',
        providerImage: 'https://picsum.photos/seed/provider2/100/100',
        serviceImage: 'https://picsum.photos/seed/plumbing/200/200',
        isActive: true,
        isPopular: false,
      ),
    ];
    
    _services.addAll(sampleServices);
    print('Added ${sampleServices.length} sample services');
  }

  // Add new service
  static Future<void> addService(ServiceModel service) async {
    try {
      // Add to Firestore first
      final docRef = await FirebaseConfig.servicesCollection.add({
        'name': service.name,
        'category': service.category,
        'description': service.description,
        'price': service.price,
        'rating': service.rating,
        'reviewCount': service.reviewCount,
        'providerName': service.providerName,
        'providerImage': service.providerImage,
        'serviceImage': service.serviceImage,
        'isActive': service.isActive,
        'isPopular': service.isPopular,
        'isApproved': service.isApproved,
        'createdAt': service.createdAt.toIso8601String(),
      });

      // Create service with Firestore ID
      final newService = ServiceModel(
        id: docRef.id,
        name: service.name,
        category: service.category,
        description: service.description,
        price: service.price,
        rating: service.rating,
        reviewCount: service.reviewCount,
        providerName: service.providerName,
        providerImage: service.providerImage,
        serviceImage: service.serviceImage,
        isActive: service.isActive,
        isPopular: service.isPopular,
        isApproved: service.isApproved,
        createdAt: service.createdAt,
      );

      // Add to local list
      _services.add(newService);
      print('Service added: ${service.name} (ID: ${docRef.id})');
      
      // Refresh services to ensure sync
      await fetchServices();
    } catch (e) {
      print('Error adding service: $e');
      // Add to local list even if Firestore fails
      _services.add(service);
    }
  }

  // Update existing service
  static Future<void> updateService(ServiceModel service) async {
    try {
      await FirebaseConfig.servicesCollection.doc(service.id).update({
        'name': service.name,
        'category': service.category,
        'description': service.description,
        'price': service.price,
        'rating': service.rating,
        'reviewCount': service.reviewCount,
        'providerName': service.providerName,
        'providerImage': service.providerImage,
        'serviceImage': service.serviceImage,
        'isActive': service.isActive,
        'isPopular': service.isPopular,
      });

      final index = _services.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _services[index] = service;
      }
    } catch (e) {
      print('Error updating service: $e');
    }
  }

  // Delete service
  static Future<void> deleteService(String serviceId) async {
    try {
      await FirebaseConfig.servicesCollection.doc(serviceId).delete();
      _services.removeWhere((service) => service.id == serviceId);
    } catch (e) {
      print('Error deleting service: $e');
    }
  }

  // Save service (for new services)
  static Future<void> saveService(ServiceModel service) async {
    try {
      await FirebaseConfig.servicesCollection.doc(service.id).set({
        'name': service.name,
        'category': service.category,
        'description': service.description,
        'price': service.price,
        'rating': service.rating,
        'reviewCount': service.reviewCount,
        'providerName': service.providerName,
        'providerImage': service.providerImage,
        'serviceImage': service.serviceImage,
        'isActive': service.isActive,
        'isPopular': service.isPopular,
        'createdAt': service.createdAt.toIso8601String(),
      });

      if (!_services.any((s) => s.id == service.id)) {
        _services.add(service);
      }
    } catch (e) {
      print('Error saving service: $e');
    }
  }

  // Toggle service status
  static Future<void> toggleServiceStatus(String serviceId) async {
    try {
      final service = _services.firstWhere((s) => s.id == serviceId);
      final updatedService = ServiceModel(
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
        isActive: !service.isActive,
        isPopular: service.isPopular,
        createdAt: service.createdAt,
      );

      await updateService(updatedService);
    } catch (e) {
      print('Error toggling service status: $e');
    }
  }

  // Toggle service popularity
  static Future<void> toggleServicePopularity(String serviceId) async {
    try {
      final service = _services.firstWhere((s) => s.id == serviceId);
      final updatedService = ServiceModel(
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
        isActive: service.isActive,
        isPopular: !service.isPopular,
        createdAt: service.createdAt,
      );

      await updateService(updatedService);
    } catch (e) {
      print('Error toggling service popularity: $e');
    }
  }

  // Get popular services
  static List<ServiceModel> getPopularServices() {
    return _services.where((s) => s.isPopular).toList();
  }

  // Get active services
  static List<ServiceModel> getActiveServices() {
    return _services.where((s) => s.isActive).toList();
  }
}
