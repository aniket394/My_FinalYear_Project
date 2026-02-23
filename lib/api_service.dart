import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator uses 10.0.2.2 to access localhost
  // For iOS Simulator or Web, use 127.0.0.1
  // For a real device, use your PC's local IP address (e.g., 192.168.1.5)
  static const String _baseUrl = "http://10.0.2.2:5000"; 

  static Future<String> translateText(String text, String targetLang) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/translate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "target_lang": targetLang,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_text'] ?? "No translation returned";
      } else {
        return "Error: Server returned ${response.statusCode}";
      }
    } catch (e) {
      return "Backend unavailable (Testing Mode): $text";
    }
  }
}