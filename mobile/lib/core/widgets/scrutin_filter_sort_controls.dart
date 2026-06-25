import 'package:flutter/material.dart';

enum ScrutinImportanceFilter {
  all,
  important,
  veryImportant,
}

enum ScrutinSortMode {
  numeroDesc,
  numeroAsc,
  importanceDesc,
  importanceAsc,
}

class ScrutinFilterSortControls extends StatelessWidget {
  const ScrutinFilterSortControls({
    required this.importanceFilter,
    required this.sortMode,
    required this.onImportanceChanged,
    required this.onSortModeChanged,
    super.key,
  });

  final ScrutinImportanceFilter importanceFilter;
  final ScrutinSortMode sortMode;
  final ValueChanged<ScrutinImportanceFilter> onImportanceChanged;
  final ValueChanged<ScrutinSortMode> onSortModeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<ScrutinImportanceFilter>(
          initialValue: importanceFilter,
          decoration: const InputDecoration(
            labelText: 'Filtre importance',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(
              value: ScrutinImportanceFilter.all,
              child: Text('Tous'),
            ),
            DropdownMenuItem(
              value: ScrutinImportanceFilter.important,
              child: Text('Importants'),
            ),
            DropdownMenuItem(
              value: ScrutinImportanceFilter.veryImportant,
              child: Text('Tres importants'),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            onImportanceChanged(value);
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ScrutinSortMode>(
          initialValue: sortMode,
          decoration: const InputDecoration(
            labelText: 'Tri',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(
              value: ScrutinSortMode.numeroDesc,
              child: Text('Numero (desc)'),
            ),
            DropdownMenuItem(
              value: ScrutinSortMode.numeroAsc,
              child: Text('Numero (asc)'),
            ),
            DropdownMenuItem(
              value: ScrutinSortMode.importanceDesc,
              child: Text('Importance (desc)'),
            ),
            DropdownMenuItem(
              value: ScrutinSortMode.importanceAsc,
              child: Text('Importance (asc)'),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            onSortModeChanged(value);
          },
        ),
      ],
    );
  }
}
