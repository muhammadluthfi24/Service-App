import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/auth_service.dart';
import '../../widgets/servify_logo.dart';
import '../../utils/firebase_auth_service.dart';
import '../../models/user_model.dart';
import 'register_screen.dart';
import '../main_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // Check if admin credentials
        if (_emailController.text == 'admin@servify.com' && _passwordController.text == 'admin123') {
          // Admin login
          setState(() => _isLoading = false);
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            (route) => false,
          );
        } else {
          // User login - check if user exists in AuthService
          final email = _emailController.text.trim();
          final existingUser = AuthService.allUsers
              .where((user) => user.email.toLowerCase() == email.toLowerCase())
              .firstOrNull;
          
          setState(() => _isLoading = false);
          
          if (existingUser != null) {
            // User exists - login directly
            AuthService.login(existingUser);
            
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          } else {
            // User doesn't exist - show register dialog
            _showRegisterDialog();
          }
        }
      }
    }
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Akun Baru'),
        content: const Text('Akun Anda belum terdaftar. Silakan daftar terlebih dahulu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF8F28),
              foregroundColor: Colors.white,
            ),
            child: const Text('Daftar'),
          ),
        ],
      ),
    );
  }

  void _registerUser() async {
    setState(() => _isLoading = true);
    
    final email = _emailController.text;
    final name = email.split('@')[0];
    final formattedName = name.replaceAll(RegExp(r'[0-9]'), '')
                            .replaceAll(RegExp(r'[_\.]'), ' ')
                            .split(' ')
                            .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
                            .join(' ');
    
    // Create new user
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: formattedName,
      email: email,
      createdAt: DateTime.now(),
    );
    
    FirebaseAuthService.setMockUser(newUser);
    
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registrasi berhasil! Silakan login dengan akun Anda.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    
    // Clear form dan arahkan ke login
    _emailController.clear();
    _passwordController.clear();
    
    // Show dialog untuk login
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      _showLoginSuccessDialog();
    }
  }

  void _showLoginSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registrasi Berhasil!'),
        content: const Text('Akun Anda telah dibuat. Silakan login dengan email dan password Anda.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Clear form untuk login manual
              _emailController.clear();
              _passwordController.clear();
              setState(() {}); // Update UI
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Logo
                const Center(
                  child: ServifyLogo(size: 60, showText: true, darkBackground: false),
                ),
                const SizedBox(height: 32),

                // Title
                const Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF8F28),
                    ),
                  ),
                ),
                
                                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    "Hi! Welcome back, you've been missed",
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Email
                const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                const SizedBox(height: 8),
                _buildField(
                  controller: _emailController,
                  hint: 'Halomaman@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                const SizedBox(height: 8),
                _buildField(
                  controller: _passwordController,
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.grey,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFFFF8F28),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFFF8F28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF8F28),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Sign In', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 24),

                // Or sign in with
                const Center(
                  child: Text('Or Sign In With', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                ),
                const SizedBox(height: 20),

                // Social buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialBtn(Icons.apple, Colors.black),
                    const SizedBox(width: 16),
                    _socialBtn(Icons.g_mobiledata, Colors.red, size: 30),
                    const SizedBox(width: 16),
                    _socialBtn(Icons.facebook, const Color(0xFF1877F2)),
                  ],
                ),
                const SizedBox(height: 32),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have account? ", style: TextStyle(color: AppColors.secondary, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Color(0xFFFF8F28), fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.secondary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
        suffixIcon: suffixIcon != null ? Padding(padding: const EdgeInsets.only(right: 12), child: suffixIcon) : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8F28), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _socialBtn(IconData icon, Color color, {double size = 24}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF5F5F5),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
