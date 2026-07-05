import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../utils/constants.dart';
import '../booking/booking_form_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Hero Image AppBar ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.secondary, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => setState(() => _isFavorite = !_isFavorite),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Icon(
                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isFavorite ? Colors.red : AppColors.grey,
                    size: 20,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.share_rounded, color: AppColors.grey, size: 20),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.service.serviceImage.isNotEmpty
                  ? Image.network(
                      widget.service.serviceImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + rating row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.service.category,
                              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star_rounded, color: Color(0xFFFF8F28), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.service.rating}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Text(
                            ' (${widget.service.reviewCount} ulasan)',
                            style: const TextStyle(color: AppColors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.service.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 16),

                      // Stats row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _statChip(Icons.check_circle_rounded, '${widget.service.reviewCount}+ Selesai', Colors.green),
                          _statChip(Icons.verified_rounded, 'Terverifikasi', AppColors.primary),
                          _statChip(Icons.timer_rounded, 'Cepat', Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),

                      // Provider
                      const SizedBox(height: 16),
                      const Text('Penyedia Layanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage: widget.service.providerImage.isNotEmpty
                                  ? NetworkImage(widget.service.providerImage)
                                  : null,
                              backgroundColor: AppColors.primary.withOpacity(0.15),
                              child: widget.service.providerImage.isEmpty
                                  ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 28)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.service.providerName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.secondary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    children: [
                                      Icon(Icons.verified_rounded, color: Colors.green, size: 14),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Terverifikasi · 5 tahun pengalaman',
                                          style: TextStyle(color: AppColors.grey, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Chat', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),

                      // Description
                      const SizedBox(height: 16),
                      const Text('Tentang Layanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                      const SizedBox(height: 10),
                      Text(
                        widget.service.description,
                        style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.7),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),

                      // Includes
                      const SizedBox(height: 16),
                      const Text('Yang Termasuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                      const SizedBox(height: 12),
                      ...[
                        'Peralatan lengkap disediakan',
                        'Garansi kepuasan 30 hari',
                        'Teknisi bersertifikat',
                        'Asuransi kerusakan',
                        'Laporan pekerjaan digital',
                      ].map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                            ),
                            const SizedBox(width: 12),
                            Text(item, style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 20),
                      const Divider(),

                      // Reviews preview
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ulasan Pelanggan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                          Text('Lihat Semua', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildReviewCard('Andi S.', 5, 'Pelayanan sangat memuaskan! Teknisi datang tepat waktu dan hasil kerja rapi.', '2 hari lalu'),
                      _buildReviewCard('Siti R.', 5, 'Recommended banget! Harga terjangkau, kualitas premium.', '1 minggu lalu'),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Harga mulai dari', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                Text(
                  currencyFormat.format(widget.service.price),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BookingFormScreen(service: widget.service),
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Pesan Sekarang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, int rating, String comment, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Row(
                      children: List.generate(rating, (_) => const Icon(Icons.star_rounded, color: Color(0xFFFF8F28), size: 12)),
                    ),
                  ],
                ),
              ),
              Text(time, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(fontSize: 13, color: AppColors.grey, height: 1.5)),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: const Center(child: Icon(Icons.home_repair_service_rounded, size: 80, color: AppColors.primary)),
    );
  }
}
