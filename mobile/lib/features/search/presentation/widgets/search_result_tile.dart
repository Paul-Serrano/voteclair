import 'package:flutter/material.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        trailing: trailing,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
