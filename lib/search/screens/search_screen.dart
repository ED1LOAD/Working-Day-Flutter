import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test/search/domain/search_service.dart';
import 'package:test/search/screens/search_profile_screen.dart';
import 'package:test/user/data/user.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final SearchService _searchService = SearchService();
  List<User> _users = [];
  bool _isSearchPerformed = false;

  @override
  void initState() {
    super.initState();
    _loadAllUsers(); // загружаем всех сотрудников при входе
  }

  Future<void> _loadAllUsers() async {
    final allUsers = await _searchService.fetchAllUsers();
    setState(() {
      _users = allUsers;
      _isSearchPerformed = true;
    });
  }

  Future<void> _search() async {
    if (_controller.text.isEmpty) {
      _loadAllUsers();
      return;
    }

    final users = await _searchService.searchUsers(_controller.text, limit: 5);
    setState(() {
      _isSearchPerformed = true;
      _users = users;
    });
  }

  void _suggestUsers(String query) async {
    if (query.isNotEmpty) {
      final suggestions = await _searchService.suggestUsers(query, limit: 5);
      setState(() {
        _users = suggestions;
        _isSearchPerformed = true;
      });
    } else {
      _loadAllUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Поиск',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 20),
            _buildSearchButton(),
            const SizedBox(height: 20),
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Поиск по компании',
        labelStyle: const TextStyle(
          fontFamily: 'CeraPro',
          color: Color.fromARGB(255, 22, 79, 148),
        ),
        hintText: 'Введите имя',
        hintStyle: const TextStyle(
          fontFamily: 'CeraPro',
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 22, 79, 148),
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 22, 79, 148),
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 22, 79, 148),
            width: 2.0,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            _controller.clear();
            _suggestUsers('');
          },
          icon: const FaIcon(
            FontAwesomeIcons.circleXmark,
            color: Color.fromARGB(255, 22, 79, 148),
          ),
        ),
      ),
      onChanged: _suggestUsers,
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _search,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
      ),
      child: const Text(
        'Поиск',
        style: TextStyle(
          fontFamily: 'CeraPro',
          color: Color.fromARGB(255, 245, 245, 245),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: !_isSearchPerformed
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Сотрудники',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CeraPro',
                      color: Color.fromARGB(255, 22, 79, 148),
                    ),
                  ),
                ),
                Expanded(
                  child: _users.isEmpty
                      ? const Center(
                          child: Text(
                            'Ничего не найдено',
                            style: TextStyle(
                              fontFamily: 'CeraPro',
                              fontSize: 18,
                              color: Color.fromARGB(255, 22, 79, 148),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _users.length,
                          separatorBuilder: (context, index) =>
                              Divider(color: Colors.blueGrey.shade100),
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: user.photo_link != null
                                    ? CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            NetworkImage(user.photo_link!),
                                      )
                                    : const CircleAvatar(
                                        radius: 30,
                                        child: Icon(Icons.person),
                                      ),
                                title: Text(
                                  '${user.surname} ${user.name} ${user.patronymic ?? ""}',
                                  style: const TextStyle(
                                    fontFamily: 'CeraPro',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 22, 79, 148),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchProfileScreen(
                                        userId: user.id ?? '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
