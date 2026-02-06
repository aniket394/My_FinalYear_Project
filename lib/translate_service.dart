import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TranslatorService {
  // Using the deployed URL found in app.py
  // If testing locally on Android Emulator, use "http://10.0.2.2:5000"
  static const String baseUrl = "https://my-finalyear-project.onrender.com";

  Future<String> translateText(String text, String targetLang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/translate'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text, "target_lang": targetLang}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_text'] ?? "";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<Map<String, dynamic>> translateFile(File file, String targetLang) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/file_translate'));
      request.fields['target_lang'] = targetLang;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {"error": "Server Error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "Exception: $e"};
    }
  }
}