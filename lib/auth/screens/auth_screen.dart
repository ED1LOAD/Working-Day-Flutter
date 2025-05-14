import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/main.dart';
import 'package:test/start/screens/start_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends ConsumerState<AuthScreen> {
  late final TextEditingController loginController;
  late final TextEditingController passwordController;
  late final TextEditingController companyIdController;
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    loginController = TextEditingController();
    passwordController = TextEditingController();
    companyIdController = TextEditingController();
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    companyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF164F94);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Text(
                    'Добро пожаловать!',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                ClipPath(
                  clipper: OneSideCurveClipper(),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 48),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Вход в систему',
                            style: TextStyle(
                              fontFamily: 'CeraPro',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(
                          controller: loginController,
                          label: 'Логин',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: passwordController,
                          label: 'Пароль',
                          icon: Icons.lock_outline,
                          obscure: !passwordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: themeColor,
                            ),
                            onPressed: () => setState(
                                () => passwordVisible = !passwordVisible),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: companyIdController,
                          label: 'Компания',
                          icon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await ref
                                  .read(authManagerProvider)
                                  .authenticate(
                                    loginController.text,
                                    passwordController.text,
                                    companyIdController.text,
                                    ref,
                                  );
                              if (success) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const MyApp(isAuthenticated: true),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Colors.red.shade600.withOpacity(0.95),
                                    behavior: SnackBarBehavior.floating,
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: Row(
                                      children: const [
                                        Icon(Icons.error_outline,
                                            color: Colors.white),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Ошибка аутентификации',
                                            style: TextStyle(
                                              fontFamily: 'CeraPro',
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Войти',
                              style: TextStyle(
                                fontFamily: 'CeraPro',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      cursorColor: const Color(0xFF164F94),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'CeraPro',
          fontSize: 16,
          color: Colors.black87,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF164F94)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFE6ECF5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
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
    path.quadraticBezierTo(size.width, 0, size.width, 80);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
