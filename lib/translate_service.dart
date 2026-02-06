import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TranslatorService {
  // The URL for your Python backend. 
  // Use "http://10.0.2.2:5000" if running locally on Android Emulator.
  static const String baseUrl = "https://my-finalyear-project.onrender.com";

  // Handles text translation
  Future<String> translateText(String text, String targetLang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/translate'),
        body: jsonEncode({"text": text, "target_lang": targetLang}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data["translated_text"] ?? "No translation found").toString();
      } else {
        return "Error: Server returned ${response.statusCode}";
      }
    } catch (e) {
      return "Error: Connection failed. $e";
    }
  }

  // Handles file and image translation
  Future<Map<String, String>> translateFile(File file, String targetLang) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/file_translate'));
      request.fields['target_lang'] = targetLang;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "original_text": (data['original_text'] ?? "").toString(),
          "translated_text": (data['translated_text'] ?? "").toString()
        };
      } else {
        return {"error": "Server Error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "Connection Error: $e"};
    }
  }
}