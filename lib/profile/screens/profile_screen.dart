// в начале файла:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:test/auth/domain/auth_notifier.dart';
import 'package:test/auth/screens/auth_screen.dart';
import 'package:test/profile/domain/profile_service.dart';
import 'package:test/profile/screens/edit_profile_page.dart';
import 'package:test/search/screens/search_calendar.dart';
import 'package:test/search/screens/search_profile_screen.dart';
import 'package:test/user/data/user.dart';
import 'package:test/user/data/user_inventory.dart';
import 'package:test/user/domain/user_preferences.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  ProfileContentState createState() => ProfileContentState();
}

class ProfileContentState extends State<ProfileContent> {
  final ProfileService _profileService = ProfileService();
  Future<User?>? _fetchUserFuture;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _inventoryKey = GlobalKey();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserFuture = _profileService.fetchUserProfile();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await UserPreferences.getRole();
    setState(() {
      _userRole = role;
    });
  }

  void updateUserProfile() {
    setState(() {
      _fetchUserFuture = _profileService.fetchUserProfile();
    });
  }

  Future<void> pickAndUploadImage() async {
    final file = await _profileService.pickImage();
    if (file != null) {
      final success = await _profileService.uploadImage(file.path);
      if (success) {
        setState(() {
          _fetchUserFuture = _profileService.fetchUserProfile();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: FutureBuilder<User?>(
        future: _fetchUserFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text("Ошибка загрузки данных пользователя"));
          } else if (snapshot.hasData) {
            return _buildProfileLayout(snapshot.data!);
          } else {
            return const Center(child: Text("Пользователь не найден"));
          }
        },
      ),
    );
  }

  Widget _buildProfileLayout(User user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(30, 20, 20, 30),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0E3C6E), Color(0xFF265AA6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Профиль',
                          style: const TextStyle(
                            fontFamily: 'CeraPro',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Consumer(
                        builder: (context, ref, _) {
                          return PopupMenuButton<String>(
                            color: Colors.white,
                            icon: const Icon(Icons.more_vert,
                                color: Colors.white),
                            onSelected: (value) async {
                              if (value == 'edit_profile') {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditProfilePage(
                                    onUpdate: updateUserProfile,
                                  ),
                                ));
                              } else if (value == 'logout') {
                                await UserPreferences.logout();
                                ref.read(authStateProvider.notifier).state =
                                    false;
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const AuthScreen()),
                                );
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit_profile',
                                child: Text('Редактировать профиль'),
                              ),
                              PopupMenuItem(
                                value: 'logout',
                                child: Text('Выйти'),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: user.photo_link != null
                          ? NetworkImage(user.photo_link!)
                          : null,
                      child: user.photo_link == null
                          ? const Icon(Icons.person, size: 110)
                          : null,
                    ),
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: FloatingActionButton(
                        heroTag: null,
                        mini: true,
                        onPressed: pickAndUploadImage,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.camera_alt,
                            color: Color(0xFF0E3C6E)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.surname} ${user.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'CeraPro',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        UserCalendarPage(userId: user.id ?? ''),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.calendar_today,
                                  size: 16, color: Colors.white),
                              label: const Text(
                                'Календарь',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'CeraPro',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                side: const BorderSide(color: Colors.white70),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          final inventoryContext = _inventoryKey.currentContext;
                          if (inventoryContext != null) {
                            Scrollable.ensureVisible(
                              inventoryContext,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white70),
                          ),
                          child: const Text(
                            'Инвентарь',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'CeraPro',
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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
          const SizedBox(height: 30),
          _buildContactRow(
              context, Icons.email, "Email", user.email ?? "Не указано"),
          _buildContactRow(context, Icons.work_outline, "Должность",
              user.jobPosition ?? "Нет должности"),
          if (user.headInfo != null)
            _buildContactRow(
              context,
              Icons.supervisor_account,
              "Руководитель",
              '${user.headInfo!.surname} ${user.headInfo!.name}',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SearchProfileScreen(userId: user.headInfo!.id),
                  ),
                );
              },
            ),
          _buildContactRow(
            context,
            FontAwesomeIcons.calendarXmark,
            "День рождения",
            user.birthday != null
                ? DateFormat('d MMMM yyyy', 'ru_RU')
                    .format(DateTime.tryParse(user.birthday!) ?? DateTime(2000))
                : "Не указано",
          ),
          _buildContactRow(context, Icons.phone, "Mobile",
              user.phones?.join(", ") ?? "Нет телефонов"),
          _buildContactRow(context, FontAwesomeIcons.telegram, "Telegram",
              user.telegram_id ?? "Не указано"),
          _buildContactRow(
              context, FontAwesomeIcons.vk, "VK", user.vk_id ?? "Не указано"),
          const SizedBox(height: 20),
          Container(
            key: _inventoryKey,
            child: _buildSectionTitle('Мой инвентарь', user),
          ),
          if (user.inventory != null && user.inventory!.isNotEmpty)
            ...user.inventory!.map((item) => _buildInventoryCard(item)).toList()
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Нет инвентаря",
                style: TextStyle(
                    fontFamily: 'CeraPro', fontSize: 16, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactRow(
      BuildContext context, IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => _showInfo(context, "$label: $value"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0E3C6E)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontFamily: 'CeraPro',
                          fontSize: 14,
                          color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          fontFamily: 'CeraPro',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1C1C1E))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, User user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CeraPro')),
          if (_userRole == 'admin')
            ElevatedButton.icon(
              onPressed: () => _showAddInventoryDialog(user),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Добавить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E3C6E),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 14, fontFamily: 'CeraPro'),
              ),
            ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String info) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.circleInfo,
                      color: Color(0xFF0E3C6E), size: 36),
                  const SizedBox(height: 16),
                  const Text(
                    'Информация',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E3C6E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: info));
                      Navigator.of(dialogContext).pop();
                      _showCopiedDialog(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD0DCE8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.copy, color: Color(0xFF0E3C6E)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              info,
                              style: const TextStyle(
                                fontFamily: 'CeraPro',
                                fontSize: 16,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0E3C6E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text(
                        'Закрыть',
                        style: TextStyle(
                          fontFamily: 'CeraPro',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCopiedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle_outline,
                    size: 42, color: Color(0xFF0E3C6E)),
                SizedBox(height: 16),
                Text(
                  'Скопировано в буфер обмена',
                  style: TextStyle(
                    fontFamily: 'CeraPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C1C1E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    });
  }

  Widget _buildInventoryCard(InventoryItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.inventory, size: 28, color: Color(0xFF265AA6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name ?? "Без названия",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'CeraPro')),
                const SizedBox(height: 4),
                Text(item.description ?? "Без описания",
                    style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'CeraPro',
                        color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddInventoryDialog(User user) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Добавить инвентарь',
                  style: TextStyle(
                    fontFamily: 'CeraPro',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E3C6E),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Color(0xFF0E3C6E)),
                  decoration: InputDecoration(
                    labelText: 'Название',
                    labelStyle: const TextStyle(
                        fontFamily: 'CeraPro', color: Color(0xFF0E3C6E)),
                    filled: true,
                    fillColor: const Color(0xFFF0F4FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Color(0xFF0E3C6E)),
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    labelStyle: const TextStyle(
                        fontFamily: 'CeraPro', color: Color(0xFF0E3C6E)),
                    filled: true,
                    fillColor: const Color(0xFFF0F4FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Отмена',
                          style: TextStyle(
                              fontFamily: 'CeraPro',
                              color: Colors.grey,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E3C6E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final description = descriptionController.text.trim();
                        if (name.isNotEmpty) {
                          final success =
                              await _profileService.addInventoryItem(
                            name,
                            description,
                            user.id ?? '',
                          );
                          if (success) {
                            Navigator.of(dialogContext).pop();
                            setState(() {
                              _fetchUserFuture =
                                  _profileService.fetchUserProfile();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Ошибка при добавлении инвентаря')),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Сохранить',
                        style: TextStyle(
                            fontFamily: 'CeraPro',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
