import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareLocation({
    required double latitude,
    required double longitude,
  }) async {
    final url =
        "https://www.google.com/maps?q=$latitude,$longitude";

    final message = """
🚨 ALERTA SOS 🚨

Necesito ayuda.

Mi ubicación es:

$url
""";

    await SharePlus.instance.share(
      ShareParams(
        text: message,
      ),
    );
  }
}