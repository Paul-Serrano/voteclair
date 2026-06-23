import 'package:flutter/material.dart';

class GlobalSearchBar extends StatelessWidget {
  const GlobalSearchBar({
    required this.onChanged,
    this.controller,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Rechercher un député, un groupe ou un scrutin...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
