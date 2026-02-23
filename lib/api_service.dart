import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ===========================================================================
  // 🔧 CONFIGURATION: SET YOUR SERVER URL HERE
  // ===========================================================================
  // Replace "https://your-app-name.onrender.com" with your actual Render URL.
  // Example: "https://translango-backend.onrender.com"
  static const String _baseUrl = "https://my-finalyear-project.onrender.com"; 

  static Future<String> translateText(String text, String targetLang) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/translate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "target_lang": targetLang,
        }),
      ).timeout(const Duration(seconds: 30)); // Increased timeout for Render cold starts

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_text'] ?? "No translation returned";
      } else {
        return "Error: Server returned ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("Backend Connection Error: $e");
      return "Backend unavailable. Is the server running at $_baseUrl?";
    }
  }
}