import 'package:flutter/material.dart';

class UserSearchForm extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSearch;

  const UserSearchForm({
    super.key,
    required this.controller,
    required this.loading,
    required this.onSearch,
  });

  static const Color primaryColor = Color.fromARGB(255, 52, 43, 182);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person_search, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Search Users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    decoration: InputDecoration(
                      labelText: 'Search by name or email',
                      hintText: 'Enter name or email address...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: primaryColor.withOpacity(0.7),
                        size: 22,
                      ),
                      suffixIcon:
                          controller.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                onPressed: () {
                                  controller.clear();
                                },
                              )
                              : null,
                      labelStyle: TextStyle(
                        color: primaryColor.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors:
                        loading
                            ? [Colors.grey[400]!, Colors.grey[500]!]
                            : [primaryColor, primaryColor.withOpacity(0.8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          loading
                              ? Colors.grey.withOpacity(0.3)
                              : primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: loading ? null : onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child:
                      loading
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Searching...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.search, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Search',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ],
          ),

          if (!loading)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    'Tip: You can search by partial name or email',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
