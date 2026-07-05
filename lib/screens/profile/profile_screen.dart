import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/firebase_auth_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _isUploading = true);
        
        // For now, just update the local state (since Firebase config has issues)
        // In production, you would upload to Firebase Storage here
        final currentUser = FirebaseAuthService.currentUser;
        if (currentUser != null) {
          // Create a mock URL for now
          final updatedUser = User(
            id: currentUser.id,
            name: currentUser.name,
            email: currentUser.email,
            avatar: 'https://via.placeholder.com/100', // Mock uploaded image
            isAdmin: currentUser.isAdmin,
            createdAt: currentUser.createdAt,
          );
          
          FirebaseAuthService.setMockUser(updatedUser);
        }
        
        setState(() => _isUploading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuthService.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Header dengan gradient yang lebih modern
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF8F28), Color(0xFFFF6B35)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      children: [
                        // App bar yang lebih rapi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, color: Colors.white),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                iconSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Profile photo dengan animasi
                        GestureDetector(
                          onTap: _pickImage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer ring
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 3,
                                    ),
                                  ),
                                ),
                                // Main photo container
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: _isUploading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFFFF8F28),
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : currentUser?.avatar != null && currentUser!.avatar!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(50),
                                              child: Image.network(
                                                currentUser.avatar!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.person_rounded,
                                                    size: 60,
                                                    color: Color(0xFFFF8F28).withOpacity(0.5),
                                                  );
                                                },
                                              ),
                                            )
                                          : Icon(
                                              Icons.person_rounded,
                                              size: 60,
                                              color: Color(0xFFFF8F28).withOpacity(0.5),
                                            ),
                                ),
                                // Camera button
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Color(0xFFFF8F28),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      color: Color(0xFFFF8F28),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Info user yang lebih clear
                        Text(
                          currentUser?.name ?? 'Guest User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUser?.email ?? 'guest@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        if (currentUser?.isAdmin == true)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.4)),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Menu Items dengan spacing yang lebih baik
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Account Section
                _buildMenuCard('AKUN', [
                  _buildMenuItem(Icons.person_outline_rounded, 'Edit Profil', () {}),
                  _buildMenuItem(Icons.notifications_none_rounded, 'Notifikasi', () {}),
                  _buildMenuItem(Icons.shield_outlined, 'Keamanan', () {}),
                ]),
                
                const SizedBox(height: 20),
                
                // Services Section
                _buildMenuCard('LAYANAN', [
                  _buildMenuItem(Icons.history_outlined, 'Riwayat Pesanan', () {}),
                  _buildMenuItem(Icons.favorite_border, 'Favorit', () {}),
                  _buildMenuItem(Icons.payment_outlined, 'Metode Pembayaran', () {}),
                ]),
                
                const SizedBox(height: 20),
                
                // Other Section
                _buildMenuCard('LAINNYA', [
                  _buildMenuItem(Icons.help_outline, 'Bantuan & FAQ', () {}),
                  _buildMenuItem(Icons.privacy_tip_outlined, 'Kebijakan Privasi', () {}),
                  _buildMenuItem(Icons.info_outline, 'Tentang Aplikasi', () {}),
                  _buildMenuItem(
                    Icons.logout_rounded,
                    'Keluar',
                    () async {
                      await FirebaseAuthService.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    isLogout: true,
                  ),
                ]),
                
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey.withOpacity(0.8),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
          ...items,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Icon container yang lebih modern
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLogout 
                      ? Colors.red.withOpacity(0.08)
                      : Color(0xFFFF8F28).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon, 
                  color: isLogout ? Colors.red : Color(0xFFFF8F28), 
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isLogout ? Colors.red : const Color(0xFF2D3436),
                  ),
                ),
              ),
              // Arrow icon
              Icon(
                Icons.chevron_right_rounded, 
                color: isLogout ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.6), 
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}