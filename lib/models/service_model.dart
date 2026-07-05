import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final String providerName;
  final String providerImage;
  final String serviceImage;
  final bool isPopular;
  final DateTime createdAt;
  final bool isActive;
  final bool isApproved; // Admin approval status

  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.providerName,
    required this.providerImage,
    required this.serviceImage,
    this.isPopular = false,
    DateTime? createdAt,
    this.isActive = true,
    this.isApproved = false, // Default to not approved
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'providerName': providerName,
      'providerImage': providerImage,
      'serviceImage': serviceImage,
      'isPopular': isPopular,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'isApproved': isApproved,
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] ?? 0,
      providerName: json['providerName'],
      providerImage: json['providerImage'],
      serviceImage: json['serviceImage'],
      isPopular: json['isPopular'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      isApproved: json['isApproved'] ?? false,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final Color color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class BookingModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String providerName;
  final DateTime bookingDate;
  final String status; // pending, confirmed, completed, cancelled
  final double totalPrice;
  final String address;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.providerName,
    required this.bookingDate,
    required this.status,
    required this.totalPrice,
    required this.address,
  });
}
