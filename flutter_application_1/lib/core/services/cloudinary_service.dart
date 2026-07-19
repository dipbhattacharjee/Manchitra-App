import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../config/secrets.dart';

class CloudinaryService {
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1';

  /// Uploads an image to Cloudinary and returns its secure URL.
  /// Uses a secure signed upload with the API secret on-device.
  static Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final cloudName = AppSecrets.cloudinaryCloudName;
      final apiKey = AppSecrets.cloudinaryApiKey;
      final apiSecret = AppSecrets.cloudinaryApiSecret;

      // Define parameters to sign
      final Map<String, String> params = {
        'timestamp': timestamp,
      };
      if (folder != null && folder.isNotEmpty) {
        params['folder'] = folder;
      }

      // Generate signature
      final sortedParams = Map.fromEntries(
        params.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
      );
      final StringBuffer signatureBuffer = StringBuffer();
      sortedParams.forEach((key, value) {
        signatureBuffer.write('$key=$value&');
      });
      final signatureStringToSign = signatureBuffer.toString().substring(0, signatureBuffer.length - 1) + apiSecret;
      final signature = sha1.convert(utf8.encode(signatureStringToSign)).toString();

      // Construct multipart request
      final uri = Uri.parse('$_baseUrl/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['signature'] = signature;
      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      // Attach file
      final fileStream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['secure_url'] as String?;
      } else {
        debugPrint('Cloudinary Upload Failed: Status ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary Upload Exception: $e');
      return null;
    }
  }
}
