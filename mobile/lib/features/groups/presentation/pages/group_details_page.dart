import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/group_member.dart';
import '../providers/group_details_provider.dart';
import '../providers/group_members_provider.dart';
import '../widgets/group_header.dart';
import '../widgets/group_member_tile.dart';
import '../widgets/group_stats_card.dart';

class GroupDetailsPage extends ConsumerStatefulWidget {
  const GroupDetailsPage({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends ConsumerState<GroupDetailsPage> {
  late final ScrollController _scrollController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < 300) {
      ref.read(groupMembersProvider(widget.slug).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupDetailsProvider(widget.slug));
    final membersState = ref.watch(groupMembersProvider(widget.slug));

    final isLoading = groupAsync.isLoading || (membersState.isLoadingInitial && !membersState.hasInitialData);
    if (isLoading) {
      return const _ScaffoldShell(
        title: 'Groupe parlementaire',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final hasError = groupAsync.hasError || (membersState.errorMessage != null && !membersState.hasInitialData);
    if (hasError) {
      return _ScaffoldShell(
        title: 'Groupe parlementaire',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Impossible de charger ce groupe.'),
                const SizedBox(height: 8),
                Text(
                  groupAsync.hasError ? '${groupAsync.error}' : membersState.errorMessage ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(groupDetailsProvider(widget.slug));
                    ref.read(groupMembersProvider(widget.slug).notifier).loadInitial();
                  },
                  child: const Text('Reessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final group = groupAsync.value!;
    final accentColor = _toColor(group.couleur);
    final filteredMembers = _filteredMembers(membersState.members);

    return _ScaffoldShell(
      title: group.nom,
      accentColor: accentColor,
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.refresh(groupDetailsProvider(widget.slug).future),
            ref.read(groupMembersProvider(widget.slug).notifier).refresh(),
          ]);
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            GroupHeader(group: group),
            const SizedBox(height: 12),
            GroupStatsCard(group: group),
            const SizedBox(height: 16),
            SearchBar(
              hintText: 'Rechercher un membre',
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 12),
            if (filteredMembers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Aucun depute trouve.')),
              )
            else
              ...filteredMembers.map(
                (member) => GroupMemberTile(
                  member: member,
                  onTap: () => context.push('/deputies/${member.slug}'),
                ),
              ),
            if (membersState.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  List<GroupMember> _filteredMembers(List<GroupMember> members) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return members;
    }

    return members.where((member) {
      return member.nom.toLowerCase().contains(query) ||
          member.prenom.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  Color? _toColor(String? hex) {
    if (hex == null || hex.trim().isEmpty) {
      return null;
    }

    final normalized = hex.replaceFirst('#', '').trim();
    if (normalized.length != 6) {
      return null;
    }

    final value = int.tryParse('FF$normalized', radix: 16);
    if (value == null) {
      return null;
    }

    return Color(value);
  }
}

class _ScaffoldShell extends StatelessWidget {
  const _ScaffoldShell({required this.title, required this.child, this.accentColor});

  final String title;
  final Widget child;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: accentColor == null ? null : Colors.white,
        title: Text(title),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/');
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
        ),
      ),
      body: child,
    );
  }
}
