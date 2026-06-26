import 'dart:io';

Future<bool> openExternalUrlWithPlatformFallback(Uri uri) async {
  if (!Platform.isLinux) {
    return false;
  }

  final launchCommands = <List<String>>[
    ..._browserEnvCommands(),
    ['gio', 'open'],
    ['xdg-open'],
    ['x-www-browser'],
    ['sensible-browser'],
    ['firefox'],
    ['firefox-esr'],
    ['google-chrome'],
    ['chromium'],
    ['chromium-browser'],
    ['brave-browser'],
    ['microsoft-edge'],
  ];

  final url = uri.toString();

  for (final command in launchCommands) {
    try {
      final result = await Process.run(command.first, [...command.skip(1), url]);
      if (result.exitCode == 0) {
        return true;
      }
    } on ProcessException {
      continue;
    }
  }

  return false;
}

Iterable<List<String>> _browserEnvCommands() sync* {
  final browser = Platform.environment['BROWSER']?.trim();
  if (browser == null || browser.isEmpty) {
    return;
  }

  final parts = browser.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList(growable: false);
  if (parts.isEmpty) {
    return;
  }

  yield parts;
}