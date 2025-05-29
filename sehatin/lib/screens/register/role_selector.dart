import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String?> onRoleChanged;

  const RoleSelector({
    Key? key,
    required this.selectedRole,
    required this.onRoleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      onChanged: onRoleChanged,
      items: const [
        DropdownMenuItem(value: 'user', child: Text('User')),
        DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
        DropdownMenuItem(value: 'customer service', child: Text('Customer Service')),
      ],
      decoration: const InputDecoration(labelText: 'Role'),
    );
  }
}
