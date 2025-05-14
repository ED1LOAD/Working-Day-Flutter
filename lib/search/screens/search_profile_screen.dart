import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:test/search/domain/search_profile_service.dart';
import 'package:test/search/screens/search_calendar.dart';
import 'package:test/user/data/user.dart';
import 'package:test/user/data/user_inventory.dart';
import 'package:test/user/domain/user_preferences.dart';

class SearchProfileScreen extends StatefulWidget {
  final String userId;

  const SearchProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SearchProfileScreen> createState() => _SearchProfileScreenState();
}

class _SearchProfileScreenState extends State<SearchProfileScreen> {
  final SearchProfileService _userService = SearchProfileService();
  Future<User?>? _fetchUserFuture;
  String? _userRole;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _inventoryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchUserFuture = _userService.fetchUserById(widget.userId);
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await UserPreferences.getRole();
    setState(() {
      _userRole = role;
    });
  }

  void _reloadUser() {
    setState(() {
      _fetchUserFuture = _userService.fetchUserById(widget.userId);
    });
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
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(
                'Ошибка: ${snapshot.error ?? "Пользователь не найден"}',
                style: const TextStyle(
                  fontFamily: 'CeraPro',
                  fontSize: 16,
                ),
              ),
            );
          }
          return _buildProfileLayout(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _buildProfileLayout(BuildContext context, User user) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
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
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Профиль',
                        style: TextStyle(
                          fontFamily: 'CeraPro',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 70,
                  backgroundImage: user.photo_link != null
                      ? NetworkImage(user.photo_link!)
                      : null,
                  child: user.photo_link == null
                      ? const Icon(Icons.person, size: 110)
                      : null,
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
          _buildContactRow(
            context,
            FontAwesomeIcons.cakeCandles,
            "День рождения",
            user.birthday != null
                ? DateFormat('d MMMM yyyy', 'ru_RU')
                    .format(DateTime.tryParse(user.birthday!) ?? DateTime(2000))
                : "Не указано",
          ),
          _buildContactRow(context, Icons.work_outline, "Должность",
              user.jobPosition ?? "Нет должности"),
          _buildContactRow(context, Icons.phone, "Мобильный",
              user.phones?.join(", ") ?? "Нет телефонов"),
          _buildContactRow(context, FontAwesomeIcons.telegram, "Telegram",
              user.telegram_id ?? "Не указано"),
          _buildContactRow(
              context, FontAwesomeIcons.vk, "VK", user.vk_id ?? "Не указано"),
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
          const SizedBox(height: 20),
          Container(
              key: _inventoryKey,
              child: _buildSectionTitle('Инвентарь сотрудника', user)),
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
            Icon(icon, color: Color.fromARGB(255, 22, 79, 148)),
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
                          final success = await _userService.addInventoryItem(
                            name,
                            description,
                            user.id ?? '',
                          );
                          if (success) {
                            Navigator.of(dialogContext).pop();
                            _reloadUser();
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Скопировано в буфер обмена'),
                          duration: Duration(seconds: 1),
                        ),
                      );
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
}
