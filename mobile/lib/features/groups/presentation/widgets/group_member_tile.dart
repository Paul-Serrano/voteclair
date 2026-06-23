import 'package:flutter/material.dart';

import '../../domain/entities/group_member.dart';

class GroupMemberTile extends StatelessWidget {
  const GroupMemberTile({
    required this.member,
    required this.onTap,
    super.key,
  });

  final GroupMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          foregroundImage: _networkImageOrNull(member.photoUrl),
          child: const Icon(Icons.person_outline),
        ),
        title: Text(member.fullName),
        subtitle: Text('Presence: ${member.statsPresence ?? '-'}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  ImageProvider<Object>? _networkImageOrNull(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    return NetworkImage(url);
  }
}
