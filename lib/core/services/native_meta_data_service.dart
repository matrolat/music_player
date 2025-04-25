import 'dart:io';
import 'package:flutter/services.dart';

class NativeMetadataService {
  static const MethodChannel _channel = MethodChannel('music_metadata');

  static Future<Map<String, String>> getMetadata(String filePath) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Native metadata reading is only supported on Android");
    }

    try {
      final result = await _channel.invokeMethod('getMetadata', {'path': filePath});
      return Map<String, String>.from(result);
    } catch (e) {
      return {'title': '', 'artist': ''};
    }
  }
}
