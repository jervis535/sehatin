import 'package:flutter/material.dart';

class UserSearchForm extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSearch;

  const UserSearchForm({
    Key? key,
    required this.controller,
    required this.loading,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Search by name or email',
              suffixIcon: Icon(Icons.search),
            ),
            onSubmitted: (_) => onSearch(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: loading ? null : onSearch,
          child: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Search'),
        ),
      ],
    );
  }
}
