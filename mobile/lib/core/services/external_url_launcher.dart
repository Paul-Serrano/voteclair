import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'external_url_launcher_stub.dart'
    if (dart.library.io) 'external_url_launcher_io.dart' as platform_launcher;

Future<bool> openExternalUrl(Uri uri) async {
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched) {
      return true;
    }
  } on PlatformException {
    // Some Linux desktop environments do not support the portal path used by
    // url_launcher, so we fall back to common system openers below.
  }

  return platform_launcher.openExternalUrlWithPlatformFallback(uri);
}