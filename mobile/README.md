# voteclair_mobile

A new Flutter project.

## Test scaffolding

To generate a new deputies screen test scaffold, run:

```bash
cd mobile
dart run tool/generate_deputy_test.dart \
	--mode list|details|votes \
	--output test/features/deputies/presentation/pages/new_test.dart \
	--import package:voteclair_mobile/features/deputies/presentation/pages/new_page.dart \
	--widget NewPage \
	--slug jean-dupont
```

The generator reuses the shared deputy fixtures and fake repository used by the
existing sprint tests.

The full step-by-step workflow is documented in
[docs/copilot/06-mobile-testing-workflow.md](../docs/copilot/06-mobile-testing-workflow.md).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
