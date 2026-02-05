import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class ApiService {
  // Use a persistent client to keep the connection open (Reduces latency by ~50%)
  static final http.Client _client = http.Client();

  // Function to translate simple text
  static Future<String> translateText(String text, String targetLang) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.translateEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "target_lang": targetLang,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_text'] ?? "";
      } else {
        try {
          final body = jsonDecode(response.body);
          return body['error'] ?? "Error: Server returned ${response.statusCode}";
        } catch (e) {
          return "Error: Server returned ${response.statusCode}";
        }
      }
    } catch (e) {
      return "Error: Connection failed. $e";
    }
  }

  // Function to upload a file (Image/PDF/Docx) for translation
  static Future<Map<String, dynamic>> translateFile(
      File file, String targetLang) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.fileTranslateEndpoint),
      );

      request.fields['target_lang'] = targetLang;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final body = jsonDecode(response.body);
          return {"error": body['error'] ?? "Server error: ${response.statusCode}"};
        } catch (e) {
          return {"error": "Server error: ${response.statusCode}"};
        }
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }
}