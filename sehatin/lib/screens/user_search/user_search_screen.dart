import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import 'user_search_form.dart';
import 'user_results_list.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});
  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await UserService.fetchUsers(
        query: _searchCtrl.text.trim(),
      );
      setState(() => _results = users);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            UserSearchForm(
              controller: _searchCtrl,
              loading: _loading,
              onSearch: _search,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (!_loading && _results.isEmpty) const Text('No users found.'),
            Expanded(
              child: UserResultsList(
                users: _results,
                onTap: (user) => Navigator.pop(context, user),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
