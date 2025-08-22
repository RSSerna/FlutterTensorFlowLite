import 'package:speech_to_text/speech_recognition_result.dart' as st;
import 'package:speech_to_text/speech_to_text.dart' as st;

class SpeechService {
  final st.SpeechToText _speechToText = st.SpeechToText();
  bool _isListening = false;
  String _recognizedText = 'Say something...';

  String get recognizedText => _recognizedText;
  bool get isListening => _isListening;

  Future<void> startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      _isListening = true;
      _speechToText.listen(onResult: _onSpeechResult);
    } else {
      _recognizedText = 'Speech recognition not available';
    }
  }

  void _onSpeechResult(st.SpeechRecognitionResult result) {
    if (result.finalResult) {
      _recognizedText = result.recognizedWords;
      _isListening = false;
      _speechToText.stop();
    }
  }

  void stopListening() {
    _speechToText.stop();
    _isListening = false;
  }
}
