import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/const/colors.dart';
import 'package:voice_assistant/services/open_ai_service.dart';
import 'package:voice_assistant/widgets/feature_box.dart';

class HomepageSCreen extends StatefulWidget {
  const HomepageSCreen({super.key});

  @override
  State<HomepageSCreen> createState() => _HomepageSCreenState();
}

class _HomepageSCreenState extends State<HomepageSCreen> {
  final speechToText = SpeechToText();

  String lastWords = '';

  final openAiService = OpenAIServices();

  final flutterTTS = FlutterTts();

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTTS.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  Future<void> onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTTS.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTTS.stop();
  }

  String? generatedContent;
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('AI Voice Assistant'),
        leading: const Icon(Icons.menu_rounded),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Virtual Lottie Animation
                LottieBuilder.asset(
                  'assets/animation/ai.json',
                  animate: true,
                  repeat: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                if (imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Chat bubble
                Visibility(
                  visible: generatedContent == null && imageUrl == null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      border: Border.all(
                        color: Pallete.borderColor,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        generatedContent == null
                            ? 'Good Morning, what task can i do for you'
                            : generatedContent!,
                        style: TextStyle(
                          color: Pallete.mainFontColor,
                          fontSize: generatedContent == null ? 20 : 18,
                        ),
                      ),
                    ),
                  ).marginOnly(left: 5, right: 5),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    'Here are a few features: ',
                    style: TextStyle(
                      color: Pallete.mainFontColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Features list
                Column(
                  children: const [
                    FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      text: 'ChatGPT',
                      descriptionText:
                          'A smart way to stay UpToDate with chatGPT',
                    ),
                    FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      text: 'Dall-E',
                      descriptionText:
                          'Get inspired and stay creative with your personal assistant by Dall-E',
                    ),
                    FeatureBox(
                        color: Pallete.thirdSuggestionBoxColor,
                        descriptionText:
                            'Get the best of both AI with a voice assistant powered by Open-AI',
                        text: 'Smart Voice Assistant'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            final speech = await openAiService.isArtPromptAPI(lastWords);
            if (speech.contains('https')) {
              imageUrl = speech;
              generatedContent = null;
              setState(() {});
            } else {
              imageUrl = null;
              generatedContent = speech;
              setState(() {
                systemSpeak(speech);
              });
            }
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        child: Icon(
          speechToText.isListening
              ? Icons.stop_rounded
              : Icons.mic_none_rounded,
        ),
      ),
    );
  }
}
