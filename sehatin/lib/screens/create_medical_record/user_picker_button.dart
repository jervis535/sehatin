import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../user_search/user_search_screen.dart';

class UserPickerButton extends StatelessWidget {
  final UserModel? selectedUser;
  final void Function(UserModel) onUserSelected;

  const UserPickerButton({
    super.key,
    required this.selectedUser,
    required this.onUserSelected,
  });

  Future<void> _pickUser(BuildContext context) async {
    final user = await Navigator.push<UserModel?>(
      context,
      MaterialPageRoute(builder: (_) => const UserSearchScreen()),
    );
    if (user != null) onUserSelected(user);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _pickUser(context),
      icon: const Icon(Icons.person_search),
      label: Text(
        selectedUser != null
            ? 'User: ${selectedUser!.username}'
            : 'Select User',
      ),
    );
  }
}
