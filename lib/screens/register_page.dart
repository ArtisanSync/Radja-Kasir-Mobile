// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/services/auth_services.dart';
import 'package:kasir/screens/login_page.dart';
import 'package:kasir/screens/email_verification_page.dart';
import 'package:loader_overlay/loader_overlay.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final api = AuthServices();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  // Define the primary color - same as LoginPage
  static const Color primary = Color(0xFF00ADFE);

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    context.loaderOverlay.show();
    
    try {
      final resp = await api.register({
        "name": _name.text.trim(),
        "email": _email.text.trim(),
        "password": _password.text,
      }, context);

      if (resp['success'] == true) {
        _showSnackBar(
          message: resp['message'] ?? 'Registrasi berhasil! Silakan cek email untuk verifikasi.',
          isError: false,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationPage(email: _email.text.trim()),
          ),
        );
      } else {
        _showSnackBar(
          message: resp['message'] ?? 'Registrasi gagal. Silakan coba lagi.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar(
        message: 'Error: ${e.toString()}',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
      context.loaderOverlay.hide();
    }
  }

  void _showSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: LoaderOverlay(
        overlayOpacity: 0.2,
        overlayColor: Colors.black12,
        useDefaultLoading: false,
        overlayWidget: Center(
          child: SpinKitDoubleBounce(
            color: primary,
            size: 50.0,
          ),
        ),
        child: Stack(
          children: [
            // Background with adjusted diagonal angle - same as LoginPage
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
            ),
            ClipPath(
              clipper: DiagonalClipper(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: primary.withOpacity(0.1),
              ),
            ),
            
            // Content - Using Center to position the content lower
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Welcome text - styled like LoginPage but larger
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 10),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat Akun Baru',
                              style: TextStyle(
                                fontSize: 24, // Increased from 18 to 24
                                fontWeight: FontWeight.w700, // Bolder font
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            SizedBox(height: 4), // Slightly increased spacing
                            Text(
                              'Lengkapi form di bawah untuk mendaftar',
                              style: TextStyle(
                                fontSize: 14, // Increased from 12 to 14
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20), // Slightly increased spacing
                      
                      // Registration Form Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name TextField
                              const Text(
                                'Nama Lengkap',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _name,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan nama lengkap',
                                  hintStyle: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: primary),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Email TextField
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan email',
                                  hintStyle: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: primary),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Password TextField
                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _password,
                                      obscureText: _obscurePassword,
                                      decoration: const InputDecoration(
                                        hintText: 'Masukkan password',
                                        hintStyle: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: primary),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword 
                                          ? Icons.visibility_off_outlined 
                                          : Icons.visibility_outlined,
                                      color: Colors.grey,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Minimal 8 karakter',
                                style: TextStyle(
                                  color: Color(0xFFA0AEC0),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 30),
                              
                              // Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _isLoading ? null : _submit,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Daftar',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Sudah punya akun?',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LoginPage(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(50, 30),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        color: primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for the diagonal background - copied from LoginPage
class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.65); // Start from bottom-left
    path.lineTo(size.width, size.height * 0.35); // Diagonal line to right side
    path.lineTo(size.width, 0); // Line to top-right
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
