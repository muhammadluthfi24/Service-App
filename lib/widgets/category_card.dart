import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../utils/constants.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'cleaning': return Icons.cleaning_services_rounded;
      case 'repair':   return Icons.build_rounded;
      case 'electric': return Icons.electrical_services_rounded;
      case 'plumbing': return Icons.plumbing_rounded;
      case 'ac':       return Icons.ac_unit_rounded;
      case 'paint':    return Icons.format_paint_rounded;
      case 'garden':   return Icons.yard_rounded;
      default:         return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Icon(
          _getIconData(category.icon),
          color: isSelected ? Colors.white : category.color,
          size: 26,
        ),
      ),
    );
  }
}
