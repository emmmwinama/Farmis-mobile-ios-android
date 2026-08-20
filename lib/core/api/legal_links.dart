import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';

/// Public legal pages served by the same backend the mobile app talks to —
/// see Farmis/app/[slug]/page.tsx (VALID_SLUGS includes "terms"/"privacy").
class LegalLinks {
  const LegalLinks._();

  static final Uri terms = Uri.parse('$apiBaseUrl/terms');
  static final Uri privacy = Uri.parse('$apiBaseUrl/privacy');

  static Future<void> open(Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
}
