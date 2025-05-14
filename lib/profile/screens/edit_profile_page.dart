import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:test/profile/domain/profile_manager.dart';
import 'package:test/user/data/user_profile_update.dart';

class EditProfilePage extends StatefulWidget {
  final Function onUpdate;

  const EditProfilePage({Key? key, required this.onUpdate}) : super(key: key);

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final ProfileManager _profileManager = ProfileManager();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _telegramIdController = TextEditingController();
  final TextEditingController _vkIdController = TextEditingController();
  final TextEditingController _jobPositionController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    fetchProfileAndUpdateUI();
  }

  void fetchProfileAndUpdateUI() async {
    var user = await _profileManager.fetchUserProfile();
    if (user != null) {
      setState(() {
        _passwordController.text = user.password ?? '';
        _emailController.text = user.email ?? '';
        _birthdayController.text = user.birthday ?? '';
        _telegramIdController.text = user.telegram_id ?? '';
        _vkIdController.text = user.vk_id ?? '';
        _jobPositionController.text = user.jobPosition ?? '';
      });
    }
  }

  void saveProfile() async {
    UserProfileUpdate update = UserProfileUpdate(
      email: _emailController.text,
      password: _passwordController.text,
      birthday: _birthdayController.text,
      telegram_id: _telegramIdController.text,
      vk_id: _vkIdController.text,
      jobPosition: _jobPositionController.text,
    );

    bool success = await _profileManager.saveUserProfile(update);
    if (success) {
      widget.onUpdate();
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (_) => _buildDialog('Профиль успешно обновлен.'),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => _buildDialog('Не удалось обновить профиль.'),
      );
    }
  }

  AlertDialog _buildDialog(String message) {
    return AlertDialog(
      title: const Text('Уведомление'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 00, 10, 00),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0E3C6E), Color(0xFF265AA6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E3C6E), Color(0xFF265AA6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Редактировать\nпрофиль',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'CeraPro',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _buildField(
                      _emailController, 'Email', FontAwesomeIcons.envelope),
                  const SizedBox(height: 16),
                  _buildField(
                    _passwordController,
                    'Пароль',
                    FontAwesomeIcons.lock,
                    obscureText: _obscurePassword,
                    onToggleObscure: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
                  ),
                  const SizedBox(height: 16),
                  _buildBirthdayPickerField(context),
                  const SizedBox(height: 16),
                  _buildField(
                    _jobPositionController,
                    'Должность',
                    FontAwesomeIcons.briefcase,
                  ),
                  const SizedBox(height: 16),
                  _buildField(_telegramIdController, 'Telegram ID',
                      FontAwesomeIcons.telegram),
                  const SizedBox(height: 16),
                  _buildField(_vkIdController, 'VK ID', FontAwesomeIcons.vk),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E3C6E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Сохранить',
                        style: TextStyle(
                          fontFamily: 'CeraPro',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: FaIcon(icon, size: 20, color: Color(0xFF0E3C6E)),
        ),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  size: 18,
                  color: Color(0xFF0E3C6E),
                ),
                onPressed: onToggleObscure,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF0F4FA),
      ),
    );
  }

  Widget _buildBirthdayPickerField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final initialDate =
            DateTime.tryParse(_birthdayController.text) ?? DateTime(2000);
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          locale: const Locale('ru'),
        );
        if (picked != null) {
          final formatted = DateFormat('dd MMMM yyyy', 'ru_RU').format(picked);
          _birthdayController.text = formatted;
        }
      },
      child: AbsorbPointer(
        child: _buildField(
          _birthdayController,
          'День рождения',
          FontAwesomeIcons.calendar,
        ),
      ),
    );
  }
}
