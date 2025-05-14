import 'package:flutter/material.dart';
import 'package:test/auth/screens/auth_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF164F94);

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Фоновое изображение
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Затемнение
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // 🔹 Контент
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'CeraPro',
                        fontSize: 28,
                        height: 1.3,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'Ваш '),
                        TextSpan(
                          text: 'Рабочий День',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(text: '\nначинается здесь'),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 4),

                // 🔹 Изогнутая панель
                ClipPath(
                  clipper: OneSideCurveClipper(),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 48),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Начать.',
                          style: TextStyle(
                            fontFamily: 'CeraPro',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Войдите, чтобы начать рабочий день',
                          style: TextStyle(
                            fontFamily: 'CeraPro',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AuthScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Войти',
                              style: TextStyle(
                                fontFamily: 'CeraPro',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OneSideCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, 0);

    path.lineTo(size.width - 80, 0);
    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      80,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
