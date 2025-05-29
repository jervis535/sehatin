import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class UserResultsList extends StatelessWidget {
  final List<UserModel> users;
  final ValueChanged<UserModel> onTap;

  const UserResultsList({
    Key? key,
    required this.users,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, i) {
        final u = users[i];
        return ListTile(
          title: Text(u.username),
          subtitle: Text(u.email),
          onTap: () => onTap(u),
        );
      },
    );
  }
}
