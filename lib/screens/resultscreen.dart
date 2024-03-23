import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wikiquiz_connector_android/models/quizresult.dart';
import 'package:wikiquiz_connector_android/screens/quizsettile_swipeoverview.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final QuizResult quizResult;

  ResultScreen({super.key, required this.quizResult});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final opacityProvider = StateProvider<double>((ref) => 0.0);
  Timer? animationTimer;
  @override
  void initState() {
    super.initState();
    Future(() {
      animationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        double opacity = ref.read(opacityProvider);
        ref.read(opacityProvider.notifier).state = opacity == 0 ? 1 : 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: InkWell(
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            animationTimer?.cancel();
            return QuizSetTileSwipeOverview();
          }), (Route<dynamic> route) => false),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 20),
                AnimatedTextKit(isRepeatingAnimation: false, animatedTexts: [
                  TypewriterAnimatedText("Ergebnis:\n",
                      textStyle:
                          const TextStyle(fontSize: 20, color: Colors.white)),
                  TypewriterAnimatedText(
                      "Anzahl Fragen: ${widget.quizResult.answercount}\n\nRichtig: ${widget.quizResult.correct}\nFalsch: ${widget.quizResult.wrong}",
                      textStyle: const TextStyle(color: Colors.white))
                ]),
                AnimatedOpacity(
                  opacity: ref.watch(opacityProvider),
                  duration: const Duration(seconds: 1),
                  child: const AutoSizeText("Zum Fortfahren berühren",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ],
            ),
          ),
        ));
  }
}
