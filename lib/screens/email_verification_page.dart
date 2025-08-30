// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/screens/login_page.dart';
import 'package:kasir/screens/home_page.dart';
import 'package:kasir/services/auth_services.dart';
import 'package:loader_overlay/loader_overlay.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final api = AuthServices();
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = false;

  // Define the primary color - same as LoginPage
  static const Color primary = Color(0xFF00ADFE);

  Future<void> verifyEmail() async {
    if (_tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan kode verifikasi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.loaderOverlay.show();

    try {
      final resp = await api.verifyEmail({
        "email": widget.email,
        "token": _tokenController.text.trim(),
      }, context);

      if (resp['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp['message'] ?? 'Email berhasil diverifikasi!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home page since user is now logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(resp['message'] ?? 'Verifikasi gagal. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      context.loaderOverlay.hide();
    }
  }

  Future<void> resendVerification() async {
    setState(() => _isLoading = true);
    context.loaderOverlay.show();

    try {
      final resp = await api.resendVerification({
        "email": widget.email,
      }, context);

      if (resp['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(resp['message'] ?? 'Kode verifikasi baru telah dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp['message'] ?? 'Gagal mengirim kode verifikasi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final logoSize = screenSize.width * 0.45; // Increased logo size (was 0.35)

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
                color:
                    primary.withOpacity(0.1),
              ),
            ),

            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo_rk.png',
                          height: logoSize,
                          width: logoSize,
                        ),
                        const SizedBox(height: 30),

                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Verifikasi Email',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kami telah mengirim kode verifikasi ke ${widget.email}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Verification Form Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 30),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Token input field
                              const Text(
                                'Kode Verifikasi',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _tokenController,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan kode verifikasi',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFA0AEC0), fontSize: 14),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: primary),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Verify Button
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
                                  onPressed: _isLoading ? null : verifyEmail,
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
                                          'Verifikasi Email',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Resend Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onPressed:
                                      _isLoading ? null : resendVerification,
                                  child: const Text(
                                    'Kirim Ulang Kode',
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Back to login link
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()),
                                    );
                                  },
                                  child: const Text(
                                    'Kembali ke Login',
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

// Custom clipper for the diagonal background
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
