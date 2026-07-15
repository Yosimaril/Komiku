import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onEmpty;
  final ValueChanged<String> onSearch;

  const SearchField({
    super.key,
    required this.controller,
    required this.onEmpty,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Search comics by title",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            onSearch(value);
          } else {
            onEmpty();
          }
        },
      ),
    );
  }
}
