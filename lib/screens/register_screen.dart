import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // 1. Logo / Top text
              Image.asset(
                'assets/images/logo_text.png', // path to your Kosply wordmark
                height: 28, // adjust height to match Figma
              ),
              const SizedBox(height: 100),

              // 2. Illustration placeholder
              Image.asset(
                'assets/images/register_artwork.png',
                height: 260,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),

              Image.asset(
                'assets/images/logo_text.png', // path to your Kosply wordmark
                height: 28, // adjust height to match Figma
              ),
              const SizedBox(height: 10),

              const Text(
                'E-commerce barang secondhand\nbagi mahasiswa',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const Spacer(), // Pushes buttons to the bottom!
              // 4. Buttons area placeholder
              OutlinedButton.icon(
                onPressed: () {},
                icon: Image.asset(
                  'assets/images/google.png',
                  height: 20,
                  width: 20,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87, // Text color
                  side: const BorderSide(
                    color: Color(0x38000000),
                  ), // Border color
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Pill or rounded edges
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                label: const Text('Log In with Google'),
              ),
              const SizedBox(height: 7),

              OutlinedButton.icon(
                onPressed: () {},
                icon: Image.asset(
                  'assets/images/apple.png',
                  height: 20,
                  width: 20,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87, // Text color
                  side: const BorderSide(
                    color: Color(0x38000000),
                  ), // Border color
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Pill or rounded edges
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                label: Text('Log In with Apple'),
              ),
              const SizedBox(height: 7),

              const Text(
                'or',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 7),

              ElevatedButton.icon(
                onPressed: () {},
                icon: Image.asset(
                  'assets/images/logo.png',
                  height: 20,
                  width: 20,
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFFFFFFFF),
                  backgroundColor: Color(0xFF4F46E5),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                label: Text('Daftar dengan Email'),
              ),
              const SizedBox(height: 7),

              Text.rich(
                TextSpan(
                  text: 'Sudah punya akun? ',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: const TextStyle(
                        color: Color(0xFF5B4DFF), // Your Kosply brand purple
                        fontWeight: FontWeight.w600,
                      ),
                      // Later when you add navigation, you can hook a tap recognizer here!
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
