import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

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
      _results = await UserService.fetchUsers(query: _searchCtrl.text.trim());
    } catch (e) {
      _error = e.toString();
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
      appBar: AppBar(title: const Text('Select User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search by name or email',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _search,
              child: _loading
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Search'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (!_loading && _results.isEmpty)
              const Text('No users found.'),
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, i) {
                  final u = _results[i];
                  return ListTile(
                    title: Text(u.username),
                    subtitle: Text(u.email),
                    onTap: () => Navigator.pop(context, u),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
