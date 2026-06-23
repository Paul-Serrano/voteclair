import 'package:flutter/material.dart';

import 'pages/group_details_page.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return GroupDetailsPage(slug: slug);
  }
}
