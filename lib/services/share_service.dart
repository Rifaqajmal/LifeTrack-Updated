import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  /// Shares a full multi-line wish message (e.g. from [WishGeneratorService]).
  static Future<void> shareMessage(String message) async {
    await Share.share(message);
  }

  /// Shares a captured image file (e.g. the birthday card), with the wish
  /// message as accompanying text.
  static Future<void> shareImage(String filePath, {String? text}) async {
    await Share.shareXFiles([XFile(filePath)], text: text);
  }
}
