import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../utils/constants.dart';
import 'booking_success_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final ServiceModel service;
  const BookingFormScreen({super.key, required this.service});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPayment = 'transfer';
  int _quantity = 1;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'transfer', 'name': 'Transfer Bank', 'icon': Icons.account_balance_rounded, 'color': Colors.blue},
    {'id': 'ewallet', 'name': 'E-Wallet', 'icon': Icons.wallet_rounded, 'color': Colors.green},
    {'id': 'cash', 'name': 'Bayar Tunai', 'icon': Icons.payments_rounded, 'color': Colors.orange},
    {'id': 'cod', 'name': 'COD', 'icon': Icons.delivery_dining_rounded, 'color': Colors.purple},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal => widget.service.price * _quantity;
  double get _platformFee => 5000;
  double get _total => _subtotal + _platformFee;

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal dan waktu layanan'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => BookingSuccessScreen(service: widget.service, bookingDate: _selectedDate!),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.secondary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Form Pemesanan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.secondary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Service Summary ──
              _buildServiceSummary(currencyFormat),
              const SizedBox(height: 20),

              // ── Informasi Pemesan ──
              _sectionTitle('Informasi Pemesan'),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Nomor Telepon',
                      hint: '08xxxxxxxxxx',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Alamat Lengkap',
                      hint: 'Jl. Nama Jalan No. X, Kota',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty ? 'Alamat tidak boleh kosong' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Jadwal Layanan ──
              _sectionTitle('Jadwal Layanan'),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTimePicker()),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Quantity
                    Row(
                      children: [
                        const Icon(Icons.layers_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(child: Text('Jumlah Unit', style: TextStyle(fontSize: 14, color: AppColors.secondary))),
                        _buildQuantityControl(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Metode Pembayaran ──
              _sectionTitle('Metode Pembayaran'),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: _paymentMethods.map((method) {
                    final isSelected = _selectedPayment == method['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPayment = method['id']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.06) : const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (method['color'] as Color).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(method['icon'] as IconData, color: method['color'] as Color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                method['name'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                              )
                            else
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.lightGrey, width: 2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // ── Catatan ──
              _sectionTitle('Catatan (Opsional)'),
              const SizedBox(height: 12),
              _buildCard(
                child: _buildTextField(
                  controller: _notesController,
                  label: 'Catatan untuk teknisi',
                  hint: 'Contoh: Tolong bawa tangga, lantai 2...',
                  icon: Icons.note_alt_outlined,
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 20),

              // ── Ringkasan Biaya ──
              _sectionTitle('Ringkasan Biaya'),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    _buildCostRow('Biaya Layanan', currencyFormat.format(widget.service.price)),
                    if (_quantity > 1) ...[
                      const SizedBox(height: 8),
                      _buildCostRow('Jumlah', '× $_quantity unit'),
                    ],
                    const SizedBox(height: 8),
                    _buildCostRow('Subtotal', currencyFormat.format(_subtotal)),
                    const SizedBox(height: 8),
                    _buildCostRow('Biaya Platform', currencyFormat.format(_platformFee)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                        Text(
                          currencyFormat.format(_total),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Submit Button ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Konfirmasi · ${currencyFormat.format(_total)}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSummary(NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.service.serviceImage.isNotEmpty
                ? Image.network(widget.service.serviceImage, width: 70, height: 70, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgPlaceholder())
                : _imgPlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.service.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.secondary)),
                const SizedBox(height: 4),
                Text(widget.service.providerName, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                const SizedBox(height: 6),
                Text(fmt.format(widget.service.price), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 70, height: 70,
      color: AppColors.primary.withOpacity(0.1),
      child: const Icon(Icons.home_repair_service_rounded, color: AppColors.primary),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.secondary));
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _selectedDate != null ? AppColors.primary : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: _selectedDate != null ? AppColors.primary : AppColors.grey, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDate == null ? 'Tanggal' : DateFormat('dd MMM', 'id_ID').format(_selectedDate!),
                style: TextStyle(
                  fontSize: 13,
                  color: _selectedDate != null ? AppColors.secondary : AppColors.grey,
                  fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _selectedTime != null ? AppColors.primary : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, color: _selectedTime != null ? AppColors.primary : AppColors.grey, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedTime == null ? 'Waktu' : _selectedTime!.format(context),
                style: TextStyle(
                  fontSize: 13,
                  color: _selectedTime != null ? AppColors.secondary : AppColors.grey,
                  fontWeight: _selectedTime != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Row(
      children: [
        GestureDetector(
          onTap: () { if (_quantity > 1) setState(() => _quantity--); },
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _quantity > 1 ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.remove_rounded, size: 16, color: _quantity > 1 ? AppColors.primary : AppColors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.secondary)),
        ),
        GestureDetector(
          onTap: () => setState(() => _quantity++),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
