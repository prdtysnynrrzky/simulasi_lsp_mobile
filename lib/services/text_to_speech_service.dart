import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  late FlutterTts flutterTts;

  double volume = 0.5;
  double rate = 0.4;
  bool isCurrentLanguageInstalled = false;

  List<String> queues = [];

  TextToSpeechService._constructor() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage('id-ID');
  }

  static final TextToSpeechService _instance =
      TextToSpeechService._constructor();

  factory TextToSpeechService() => _instance;

  Future<dynamic> getLanguages() async => await flutterTts.getLanguages;

  Future<void> queue(String text) async {
    queues.add(text);
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.awaitSpeakCompletion(true);

    if (queues.isNotEmpty) {
      await speak();
    }
  }

  Future<void> speak() async {
    if (queues.isEmpty) return;

    final text = queues.removeAt(0);
    await flutterTts.speak(text);

    if (queues.isNotEmpty) {
      await speak();
    }
  }
}
