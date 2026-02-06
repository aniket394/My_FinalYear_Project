// ===================== IMPORTS =====================
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:final_year/api_service.dart';

/// ===================== UI THEME =====================
const Color kBgColor = Color(0xFFF5F7FA);
const Color kCardColor = Colors.white;
const Color kTextPrimary = Color(0xFF2D3436);
const Color kTextSecondary = Color(0xFF636E72);
const Color kPrimaryColor = Color(0xFF6C5CE7);
const Color kSecondaryColor = Color(0xFFA29BFE);
const LinearGradient kGradient = LinearGradient(
  colors: [Color(0xFF6C5CE7), Color(0xFFa29bfe)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Map<String, Map<String, String>> kLanguages = {
  // Indian Languages
  "Hindi": {"code": "hi", "flag": "🇮🇳"},
  "Marathi": {"code": "mr", "flag": "🇮🇳"},
  "Bengali": {"code": "bn", "flag": "🇮🇳"},
  "Gujarati": {"code": "gu", "flag": "🇮🇳"},
  "Tamil": {"code": "ta", "flag": "🇮🇳"},
  "Telugu": {"code": "te", "flag": "🇮🇳"},
  "Kannada": {"code": "kn", "flag": "🇮🇳"},
  "Malayalam": {"code": "ml", "flag": "🇮🇳"},
  "Punjabi": {"code": "pa", "flag": "🇮🇳"},
  "Urdu": {"code": "ur", "flag": "🇮🇳"},
  "Odia": {"code": "or", "flag": "🇮🇳"},
  "Assamese": {"code": "as", "flag": "🇮🇳"},
  "Maithili": {"code": "mai", "flag": "🇮🇳"},
  "Santali": {"code": "sat", "flag": "🇮🇳"},
  "Kashmiri": {"code": "ks", "flag": "🇮🇳"},
  "Nepali": {"code": "ne", "flag": "🇳🇵"},
  "Konkani": {"code": "gom", "flag": "🇮🇳"},
  "Sindhi": {"code": "sd", "flag": "🇮🇳"},
  "Dogri": {"code": "doi", "flag": "🇮🇳"},
  "Manipuri": {"code": "mni", "flag": "🇮🇳"},
  "Bodo": {"code": "brx", "flag": "🇮🇳"},
  "Sanskrit": {"code": "sa", "flag": "🇮🇳"},
  "Bhojpuri": {"code": "bho", "flag": "🇮🇳"},

  // International
  "English": {"code": "en", "flag": "🇬🇧"},
  "French": {"code": "fr", "flag": "🇫🇷"},
  "Spanish": {"code": "es", "flag": "🇪🇸"},
  "German": {"code": "de", "flag": "🇩🇪"},
  "Chinese": {"code": "zh", "flag": "🇨🇳"},
  "Japanese": {"code": "ja", "flag": "🇯🇵"},
  "Korean": {"code": "ko", "flag": "🇰🇷"},
  "Russian": {"code": "ru", "flag": "🇷🇺"},
  "Arabic": {"code": "ar", "flag": "🇸🇦"},
  "Portuguese": {"code": "pt", "flag": "🇵🇹"},
  "Italian": {"code": "it", "flag": "🇮🇹"},
  "Dutch": {"code": "nl", "flag": "🇳🇱"},
  "Turkish": {"code": "tr", "flag": "🇹🇷"},
  "Vietnamese": {"code": "vi", "flag": "🇻🇳"},
  "Thai": {"code": "th", "flag": "🇹🇭"},
  "Indonesian": {"code": "id", "flag": "🇮🇩"},
  "Polish": {"code": "pl", "flag": "🇵🇱"},
  "Ukrainian": {"code": "uk", "flag": "🇺🇦"},
  "Romanian": {"code": "ro", "flag": "🇷🇴"},
  "Greek": {"code": "el", "flag": "🇬🇷"},
  "Czech": {"code": "cs", "flag": "🇨🇿"},
  "Swedish": {"code": "sv", "flag": "🇸🇪"},
  "Hungarian": {"code": "hu", "flag": "🇭🇺"},
  "Hebrew": {"code": "he", "flag": "🇮🇱"},
  "Malay": {"code": "ms", "flag": "🇲🇾"},
  "Persian": {"code": "fa", "flag": "🇮🇷"},
  "Filipino": {"code": "tl", "flag": "🇵🇭"},
  "Finnish": {"code": "fi", "flag": "🇫🇮"},
  "Danish": {"code": "da", "flag": "🇩🇰"},
  "Norwegian": {"code": "no", "flag": "🇳🇴"},
  "Swahili": {"code": "sw", "flag": "🇰🇪"},
  "Afrikaans": {"code": "af", "flag": "🇿🇦"},
  "Sinhala": {"code": "si", "flag": "🇱🇰"},
  "Burmese": {"code": "my", "flag": "🇲🇲"},
  "Khmer": {"code": "km", "flag": "🇰🇭"},
  "Lao": {"code": "lo", "flag": "🇱🇦"},
};

/// ===================== MAIN =====================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  runApp(const MyApp());
}

/// ===================== APP =====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      theme: ThemeData(
        scaffoldBackgroundColor: kBgColor,
        fontFamily: 'Roboto',
      ),
      home: const TranslatorHome(),
    );
  }
}

/// ===================== HOME WITH BOTTOM NAV =====================
class TranslatorHome extends StatefulWidget {
  const TranslatorHome({super.key});

  @override
  State<TranslatorHome> createState() => _TranslatorHomeState();
}

class _TranslatorHomeState extends State<TranslatorHome> {
  int index = 0;

  final pages = [
    const TextTranslatorScreen(),
    const SpeechScreen(),
    const CameraScreenUI(),
    const FilesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => setState(() => index = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kTextSecondary,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded), label: "Text"),
            BottomNavigationBarItem(icon: Icon(Icons.mic_rounded), label: "Voice"),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt_rounded), label: "Camera"),
            BottomNavigationBarItem(icon: Icon(Icons.folder_rounded), label: "File"),
          ],
        ),
      ),
    );
  }
}

/// ===================== TEXT TRANSLATOR =====================
class TextTranslatorScreen extends StatefulWidget {
  const TextTranslatorScreen({super.key});

  @override
  State<TextTranslatorScreen> createState() => _TextTranslatorScreenState();
}

class _TextTranslatorScreenState extends State<TextTranslatorScreen> {
  final TextEditingController _controller = TextEditingController();
  String output = "";
  bool loading = false;

  String fromLang = "en";
  String toLang = "hi";

  Future<void> translate() async {
    if (_controller.text.trim().isEmpty) {
      setState(() => output = "");
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => loading = true);
    final translation = await ApiService.translateText(_controller.text, toLang);
    if (mounted) setState(() { output = translation; loading = false; });
  }

  void swapLanguages() {
    setState(() {
      final temp = fromLang;
      fromLang = toLang;
      toLang = temp;
      output = "";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("Text Translator",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary)),
            const SizedBox(height: 20),

            // Language selection row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        menuMaxHeight: 300,
                        value: fromLang,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: kTextSecondary),
                        items: kLanguages.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.value["code"],
                                  child: Text(
                                    "${e.value["flag"]} ${e.key}",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: kTextPrimary),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => fromLang = val!),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: swapLanguages,
                      icon: const Icon(Icons.swap_horiz_rounded,
                          color: kPrimaryColor),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        menuMaxHeight: 300,
                        value: toLang,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: kTextSecondary),
                        items: kLanguages.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.value["code"],
                                  child: Text(
                                    "${e.value["flag"]} ${e.key}",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: kTextPrimary),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => toLang = val!),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Input Card
            SizedBox(
              height: 250,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("ORIGINAL TEXT",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: kSecondaryColor)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 20, color: kTextSecondary),
                          onPressed: () => _controller.clear(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(fontSize: 16, color: kTextPrimary),
                        decoration: const InputDecoration(
                          hintText: "Write text to translate...",
                          hintStyle: TextStyle(color: kTextSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Translate Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Container(
                decoration: BoxDecoration(
                  gradient: kGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: translate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text("Translate",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (loading) ...[
              const LinearProgressIndicator(color: kPrimaryColor),
              const SizedBox(height: 20),
            ],

            // Output Card
            SizedBox(
              height: 250,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TRANSLATED TEXT",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: kPrimaryColor)),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded,
                              size: 20, color: kPrimaryColor),
                          onPressed: () {
                            if (output.isEmpty) return;
                            Clipboard.setData(ClipboardData(text: output));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Copied!"),
                                    duration: Duration(seconds: 1)));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          output.isEmpty
                              ? "Translation will appear here"
                              : output,
                          style: TextStyle(
                              fontSize: 18,
                              color: output.isEmpty
                                  ? kTextSecondary
                                  : kTextPrimary,
                              height: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===================== SPEECH SCREEN =====================
class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool isListening = false;
  String text = "";
  String translated = "";
  bool loading = false;
  double soundLevel = 0.0;
  Timer? _debounce;
  String toLang = "hi";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onError: (error) => debugPrint("Error: ${error.errorMsg}"),
      onStatus: (status) => debugPrint("Status: $status"),
    );
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Speech recognition not available. Please check permissions.")),
      );
      return;
    }

    setState(() {
      isListening = true;
      text = "";
      translated = "";
    });
    _speech.listen(
      onResult: (result) {
        setState(() => text = result.recognizedWords);

        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () async {
          if (text.trim().isEmpty) return;
          if (mounted) setState(() => loading = true);
          final tr = await ApiService.translateText(text, toLang);
          if (mounted) setState(() { translated = tr; loading = false; });
        });
      },
      onSoundLevelChange: (level) => setState(() => soundLevel = level),
    );
  }

  void stopListening() {
    _speech.stop();
    setState(() => isListening = false);
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!"), duration: Duration(seconds: 1)));
  }

  Future<void> _reTranslate() async {
    if (text.trim().isEmpty) return;
    setState(() => loading = true);
    final tr = await ApiService.translateText(text, toLang);
    if (mounted) setState(() { translated = tr; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Text("Voice Translator",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kTextPrimary)),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              menuMaxHeight: 300,
              value: toLang,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextSecondary),
              items: kLanguages.entries.map((e) => DropdownMenuItem(
                    value: e.value["code"],
                    child: Text(
                      "${e.value["flag"]} ${e.key}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kTextPrimary),
                    ),
                  )).toList(),
              onChanged: (val) {
                setState(() => toLang = val!);
                _reTranslate();
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(isListening ? "Listening..." : "Tap mic to record",
            style: const TextStyle(color: kTextSecondary, fontSize: 16)),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: text.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isListening)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 12,
                              height: 30 + (soundLevel * 5 + (i * 10)) % 60,
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            );
                          }),
                        )
                      else
                        const Icon(Icons.graphic_eq_rounded, size: 80, color: Color(0xFFE0E0E0)),
                      const SizedBox(height: 20),
                      Text(isListening ? "Listening..." : "Speak now",
                          style: const TextStyle(color: kTextSecondary, fontSize: 18)),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("ORIGINAL",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: kSecondaryColor)),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18, color: kTextSecondary),
                              onPressed: () => _copy(text),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(text,
                            style: const TextStyle(fontSize: 18, color: kTextPrimary)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("TRANSLATED",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor)),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18, color: kPrimaryColor),
                              onPressed: () => _copy(translated),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (loading)
                          const LinearProgressIndicator(color: kPrimaryColor)
                        else
                          Text(translated,
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: kTextPrimary,
                                  fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 40),
          child: GestureDetector(
            onTap: isListening ? stopListening : startListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                gradient: isListening
                    ? const LinearGradient(colors: [Colors.redAccent, Colors.red])
                    : kGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isListening ? Colors.redAccent : kPrimaryColor)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Icon(
                isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ===================== CAMERA SCREEN =====================
class CameraScreenUI extends StatefulWidget {
  const CameraScreenUI({super.key});

  @override
  State<CameraScreenUI> createState() => _CameraScreenUIState();
}

class _CameraScreenUIState extends State<CameraScreenUI> {
  File? image;
  String extracted = "";
  String translated = "";
  bool loading = false;
  String toLang = "hi";
  final picker = ImagePicker();

  Future<void> getImage(ImageSource source) async {
    try {
      final XFile? img = await picker.pickImage(source: source);
      if (img == null || !mounted) return;

      setState(() {
        image = File(img.path);
        loading = true;
        extracted = "";
        translated = "";
      });

      final result = await ApiService.translateFile(image!, toLang);
      if (result.containsKey("error")) {
        extracted = result["error"]!;
        translated = "";
      } else {
        extracted = result["original_text"] ?? "No text extracted.";
        translated = result["translated_text"] ?? "";
      }
    } catch (e) {
      extracted = "Error processing file: $e";
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _reTranslate() async {
    if (extracted.trim().isEmpty) return;
    setState(() => loading = true);
    final tr = await ApiService.translateText(extracted, toLang);
    if (mounted) setState(() { translated = tr; loading = false; });
  }

  Widget cardText(String title, String text) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kPrimaryColor)),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20, color: kTextSecondary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!"), duration: Duration(seconds: 1)));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 16, height: 1.5, color: kTextPrimary)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 30),
            const Center(
              child: Text("Camera Translator",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kTextPrimary)),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  menuMaxHeight: 300,
                  value: toLang,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextSecondary),
                  items: kLanguages.entries.map((e) => DropdownMenuItem(
                        value: e.value["code"],
                        child: Text(
                          "${e.value["flag"]} ${e.key}",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: kTextPrimary),
                        ),
                      )).toList(),
                  onChanged: (val) {
                    setState(() => toLang = val!);
                    _reTranslate();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1E5EA),
                  borderRadius: BorderRadius.circular(30),
                  image: image != null
                      ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover)
                      : null,
                ),
                child: image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_enhance_rounded, size: 60, color: kTextSecondary),
                          SizedBox(height: 10),
                          Text("No image selected", style: TextStyle(color: kTextSecondary)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 4,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      child: Column(
                        children: [
                          if (extracted.isNotEmpty) ...[
                            cardText("Extracted Text", extracted),
                            cardText("Translated Text", translated),
                          ] else if (!loading && image != null)
                            const Text("Processing complete. No text found.", style: TextStyle(color: kTextSecondary)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
        Positioned(
          bottom: 30,
          left: 40,
          right: 40,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF2D3436),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => getImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                  tooltip: "Gallery",
                ),
                GestureDetector(
                  onTap: () => getImage(ImageSource.camera),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 28),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      image = null;
                      extracted = "";
                      translated = "";
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  tooltip: "Reset",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ===================== FILE SCREEN =====================
class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  String extracted = "";
  String translated = "";
  String? fileName;
  bool loading = false;
  String toLang = "hi";

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'docx'],
    );
    if (result == null || !mounted) return;

    setState(() {
      loading = true;
      fileName = result.files.single.name;
    });

    try {
      final file = File(result.files.single.path!);
      final response = await ApiService.translateFile(file, toLang);
      if (response.containsKey("error")) {
        extracted = response["error"]!;
        translated = "";
      } else {
        extracted = response["original_text"] ?? "No text extracted.";
        translated = response["translated_text"] ?? "";
      }
    } catch (e) {
      extracted = "Error processing file: $e";
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> _reTranslate() async {
    if (extracted.trim().isEmpty) return;
    setState(() => loading = true);
    final tr = await ApiService.translateText(extracted, toLang);
    if (mounted) setState(() { translated = tr; loading = false; });
  }

  Widget cardText(String title, String text) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor, fontSize: 12)),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20, color: kTextSecondary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!"), duration: Duration(seconds: 1)));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 16, height: 1.5, color: kTextPrimary)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 30),
            const Text("File Translator",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kTextPrimary)),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  menuMaxHeight: 300,
                  value: toLang,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextSecondary),
                  items: kLanguages.entries.map((e) => DropdownMenuItem(
                        value: e.value["code"],
                        child: Text(
                          "${e.value["flag"]} ${e.key}",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: kTextPrimary),
                        ),
                      )).toList(),
                  onChanged: (val) {
                    setState(() => toLang = val!);
                    _reTranslate();
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(fileName ?? "Select a .txt file",
                style: const TextStyle(color: kTextSecondary, fontSize: 16)),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : extracted.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.folder_open_rounded,
                                  size: 80, color: Color(0xFFE0E0E0)),
                              const SizedBox(height: 20),
                              Text("No file loaded",
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 16)),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                cardText("ORIGINAL CONTENT", extracted),
                                cardText("TRANSLATED CONTENT", translated),
                              ],
                            ),
                          ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 30,
          left: 40,
          right: 40,
          child: Container(
            decoration: BoxDecoration(
              gradient: kGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.upload_file_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Browse Files",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
