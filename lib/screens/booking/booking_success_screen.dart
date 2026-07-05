import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../utils/constants.dart';
import '../main_screen.dart';

class BookingSuccessScreen extends StatefulWidget {
  final ServiceModel service;
  final DateTime bookingDate;

  const BookingSuccessScreen({super.key, required this.service, required this.bookingDate});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Animated check icon
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.check_rounded, size: 64, color: Colors.white),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    const Text(
                      'Pemesanan Berhasil! 🎉',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.secondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Penyedia layanan akan segera\nmenghubungi Anda untuk konfirmasi.',
                      style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Booking detail card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          // Order ID
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'ID Pesanan: #BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Service image + name
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: widget.service.serviceImage.isNotEmpty
                                    ? Image.network(widget.service.serviceImage, width: 56, height: 56, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _imgPlaceholder())
                                    : _imgPlaceholder(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.service.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.secondary)),
                                    const SizedBox(height: 2),
                                    Text(widget.service.providerName, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
                          _infoRow(Icons.calendar_today_rounded, 'Tanggal', dateFmt.format(widget.bookingDate)),
                          const SizedBox(height: 10),
                          _infoRow(Icons.person_rounded, 'Teknisi', widget.service.providerName),
                          const SizedBox(height: 10),
                          _infoRow(Icons.payments_rounded, 'Total Bayar', fmt.format(widget.service.price + 5000)),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status', style: TextStyle(fontSize: 13, color: AppColors.grey)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                                    SizedBox(width: 4),
                                    Text('Dikonfirmasi', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                          (route) => false,
                        ),
                        icon: const Icon(Icons.home_rounded, size: 20),
                        label: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 2)),
                          (route) => false,
                        ),
                        icon: const Icon(Icons.receipt_long_rounded, size: 20),
                        label: const Text('Lihat Pesanan Saya', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
      ],
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 56, height: 56,
      color: AppColors.primary.withOpacity(0.1),
      child: const Icon(Icons.home_repair_service_rounded, color: AppColors.primary, size: 28),
    );
  }
}
