import 'package:flutter/material.dart';

class PostalCodeSearchCard extends StatefulWidget {
  const PostalCodeSearchCard({
    required this.initialPostalCode,
    required this.initialInstitutionId,
    required this.isLoading,
    required this.onPostalCodeChanged,
    required this.onInstitutionIdChanged,
    required this.onFind,
    super.key,
  });

  final String initialPostalCode;
  final String? initialInstitutionId;
  final bool isLoading;
  final ValueChanged<String> onPostalCodeChanged;
  final ValueChanged<String?> onInstitutionIdChanged;
  final VoidCallback onFind;

  @override
  State<PostalCodeSearchCard> createState() => _PostalCodeSearchCardState();
}

class _PostalCodeSearchCardState extends State<PostalCodeSearchCard> {
  late final TextEditingController _controller;
  late final TextEditingController _institutionController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPostalCode);
    _institutionController = TextEditingController(text: widget.initialInstitutionId ?? '');
  }

  @override
  void didUpdateWidget(covariant PostalCodeSearchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPostalCode != widget.initialPostalCode && _controller.text != widget.initialPostalCode) {
      _controller.text = widget.initialPostalCode;
    }

    final nextInstitution = widget.initialInstitutionId ?? '';
    if ((oldWidget.initialInstitutionId ?? '') != nextInstitution && _institutionController.text != nextInstitution) {
      _institutionController.text = nextInstitution;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entrez votre code postal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 5,
              decoration: const InputDecoration(
                labelText: 'Code postal',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.onPostalCodeChanged(value);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _institutionController,
              decoration: const InputDecoration(
                labelText: 'Institution (optionnel)',
                hintText: "UUID de l'institution",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final normalized = value.trim();
                widget.onInstitutionIdChanged(normalized.isEmpty ? null : normalized);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.isLoading ? null : widget.onFind,
                child: widget.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Trouver mon député'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}