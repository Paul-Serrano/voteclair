import 'dart:io';

void main(List<String> args) {
  final options = _ArgsParser.parse(args);

  if (options.containsKey('help') ||
      !options.containsKey('output') ||
      !options.containsKey('import') ||
      !options.containsKey('widget') ||
      !options.containsKey('mode')) {
    _printUsage();
    exit(options.containsKey('help') ? 0 : 64);
  }

  final output = options['output']!;
  final widgetImport = options['import']!;
  final widgetClass = options['widget']!;
  final mode = options['mode']!;
  final slug = options['slug'] ?? 'jean-dupont';
  final force = options.containsKey('force');

  final file = File(output);
  if (file.existsSync() && !force) {
    stderr.writeln('Refusing to overwrite existing file: $output');
    stderr.writeln('Use --force to overwrite it.');
    exit(1);
  }

  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    _renderTemplate(
      widgetImport: widgetImport,
      widgetClass: widgetClass,
      mode: mode,
      slug: slug,
    ),
  );

  stdout.writeln('Created $output');
}

String _renderTemplate({
  required String widgetImport,
  required String widgetClass,
  required String mode,
  required String slug,
}) {
  return switch (mode) {
    'list' => _renderListTemplate(widgetImport, widgetClass),
    'details' => _renderDetailsTemplate(widgetImport, widgetClass, slug),
    'votes' => _renderVotesTemplate(widgetImport, widgetClass, slug),
    _ => throw ArgumentError('Unsupported mode: $mode'),
  };
}

String _renderListTemplate(String widgetImport, String widgetClass) {
  return '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '$widgetImport';
import 'package:voteclair_mobile/features/deputies/presentation/providers/deputies_provider.dart';

import '../../../../helpers/deputy_fixtures.dart';
import '../../../../helpers/fake_deputy_repository.dart';

void main() {
  group('$widgetClass', () {
    testWidgets('shows loading then displays deputies list', (tester) async {
      final repository = FakeDeputyRepository(
        deputies: const [sampleDeputy],
        fetchDeputiesDelay: const Duration(milliseconds: 50),
      );

      await _pumpPage(tester, repository);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Dupont'), findsOneWidget);
    });

    testWidgets('shows empty state when repository returns no deputies',
        (tester) async {
      final repository = FakeDeputyRepository(deputies: const []);

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Aucun depute trouve.'), findsOneWidget);
    });

    testWidgets('shows error state when repository throws', (tester) async {
      final repository = FakeDeputyRepository(throwOnFetchDeputies: true);

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger les deputes.'), findsOneWidget);
    });
  });
}

Future<void> _pumpPage(WidgetTester tester, FakeDeputyRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        deputyRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: $widgetClass(),
      ),
    ),
  );
}
''';
}

String _renderDetailsTemplate(String widgetImport, String widgetClass, String slug) {
  return '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '$widgetImport';
import 'package:voteclair_mobile/features/deputies/presentation/providers/deputies_provider.dart';

import '../../../../helpers/deputy_fixtures.dart';
import '../../../../helpers/fake_deputy_repository.dart';

void main() {
  group('$widgetClass', () {
    testWidgets('shows loading then renders details and actions',
        (tester) async {
      final repository = FakeDeputyRepository(
        deputyBySlug: const {'$slug': sampleDeputy},
        getBySlugDelay: const Duration(milliseconds: 50),
      );

      await _pumpPage(tester, repository);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Fiche depute'), findsOneWidget);
      expect(find.text('Jean'), findsOneWidget);
      expect(find.text('Dupont'), findsOneWidget);
    });

    testWidgets('shows error state when details loading fails', (tester) async {
      final repository = FakeDeputyRepository(
        throwOnGetBySlug: true,
      );

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger ce depute.'), findsOneWidget);
    });
  });
}

Future<void> _pumpPage(WidgetTester tester, FakeDeputyRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        deputyRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: $widgetClass(slug: '$slug'),
      ),
    ),
  );
}
''';
}

String _renderVotesTemplate(String widgetImport, String widgetClass, String slug) {
  return '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '$widgetImport';
import 'package:voteclair_mobile/features/deputies/domain/entities/deputy.dart';
import 'package:voteclair_mobile/features/deputies/domain/entities/deputy_vote.dart';
import 'package:voteclair_mobile/features/deputies/domain/entities/paginated_votes.dart';
import 'package:voteclair_mobile/features/deputies/presentation/providers/deputies_provider.dart';

import '../../../../helpers/deputy_fixtures.dart';
import '../../../../helpers/fake_deputy_repository.dart';

void main() {
  group('$widgetClass', () {
    testWidgets('shows loading then votes and filters locally by scrutin title',
        (tester) async {
      final repository = FakeDeputyRepository(
        deputies: const <Deputy>[sampleDeputy],
        deputyBySlug: const <String, Deputy>{'$slug': sampleDeputy},
        votesBySlugAndPage: <String, Map<int, PaginatedVotes>>{
          '$slug': <int, PaginatedVotes>{
            1: PaginatedVotes(
              votes: <DeputyVote>[
                makeVote(
                  id: 'v1',
                  title: 'Budget 2026',
                  position: 'POUR',
                  sort: 'ADOPTE',
                ),
                makeVote(
                  id: 'v2',
                  title: 'Loi Climat',
                  position: 'CONTRE',
                  sort: 'REJETE',
                ),
              ],
              currentPage: 1,
              lastPage: 1,
            ),
          },
        },
        getVotesDelay: const Duration(milliseconds: 50),
      );

      await _pumpPage(tester, repository);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Budget 2026'), findsOneWidget);
      expect(find.text('Loi Climat'), findsOneWidget);
    });

    testWidgets('shows empty state when no votes are returned', (tester) async {
      final repository = FakeDeputyRepository(
        deputies: const <Deputy>[sampleDeputy],
        deputyBySlug: const <String, Deputy>{'$slug': sampleDeputy},
        votesBySlugAndPage: <String, Map<int, PaginatedVotes>>{
          '$slug': <int, PaginatedVotes>{
            1: const PaginatedVotes(
              votes: <DeputyVote>[],
              currentPage: 1,
              lastPage: 1,
            ),
          },
        },
      );

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Aucun vote trouve.'), findsOneWidget);
    });

    testWidgets('shows error state when initial load fails', (tester) async {
      final repository = FakeDeputyRepository(
        deputies: const <Deputy>[sampleDeputy],
        deputyBySlug: const <String, Deputy>{'$slug': sampleDeputy},
        throwOnGetVotes: true,
      );

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger les votes.'), findsOneWidget);
    });
  });
}

Future<void> _pumpPage(WidgetTester tester, FakeDeputyRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        deputyRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: $widgetClass(slug: '$slug'),
      ),
    ),
  );
}
''';
}

void _printUsage() {
  stdout.writeln('''
Usage:
  dart run tool/generate_deputy_test.dart
    --mode list|details|votes
    --output test/features/deputies/presentation/pages/new_test.dart
    --import package:voteclair_mobile/features/deputies/presentation/pages/new_page.dart
    --widget NewPage
    [--slug jean-dupont]
    [--force]

This generator creates ready-to-edit Flutter widget test scaffolds using the
shared FakeDeputyRepository and fixture helpers from the VoteClair mobile app.
''');
}

class _ArgsParser {
  static Map<String, String> parse(List<String> args) {
    final result = <String, String>{};

    for (var i = 0; i < args.length; i++) {
      final argument = args[i];
      if (!argument.startsWith('--')) {
        continue;
      }

      final trimmed = argument.substring(2);
      final equalsIndex = trimmed.indexOf('=');
      if (equalsIndex != -1) {
        final key = trimmed.substring(0, equalsIndex);
        final value = trimmed.substring(equalsIndex + 1);
        result[key] = value.isEmpty ? 'true' : value;
        continue;
      }

      final key = trimmed;
      final next = i + 1 < args.length ? args[i + 1] : null;
      if (next != null && !next.startsWith('--')) {
        result[key] = next;
        i++;
      } else {
        result[key] = 'true';
      }
    }

    return result;
  }
}