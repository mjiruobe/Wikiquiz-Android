import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:wikiquiz_connector_android/models/question.dart';
import 'package:wikiquiz_connector_android/models/quizset.dart';
import 'package:wikiquiz_connector_android/screens/question_screen.dart';

final quizSetProvider = StateProvider<QuizSet?>((ref) => null);

class QuizConfig extends ConsumerWidget {
  final opacityProvider = StateProvider((ref) => 1.0);
  QuizConfig({super.key});
  GlobalKey sliderKey = GlobalKey();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizSet = ref.watch(quizSetProvider)!;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: SleekCircularSlider(
          appearance: CircularSliderAppearance(
              customColors: CustomSliderColors(
                  trackColor: Colors.orange[300],
                  progressBarColors: [
                Colors.deepOrange,
                Colors.orange,
                Colors.orangeAccent,
              ])),
          min: 1,
          max: quizSet.questions.length.toDouble(),
          initialValue: lerpDouble(1, quizSet.questions.length.toDouble(), 0.5)!
              .floor()
              .toDouble(),
          onChange: (double value) {
            // callback providing a value while its being changed (with a pan gesture)
          },
          onChangeStart: (double startValue) {
            // callback providing a starting value (when a pan gesture starts)
          },
          onChangeEnd: (double endValue) {
            // ucallback providing an ending value (when a pan gesture ends)
          },
          innerWidget: (double value) {
            final rounded = value.round();
            return InkWell(
              enableFeedback: false,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onLongPress: () {
                final questionCopy = List.from(quizSet.questions);
                questionCopy.shuffle();
                ref.read(questionsProvider.notifier).state =
                    List<Question>.from(
                        questionCopy.getRange(0, rounded).toList());
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuestionScreen()));
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$rounded Fragen",
                        style: TextStyle(color: Colors.white)),
                    SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 2),
                      child: AnimatedOpacity(
                        opacity: ref.watch(opacityProvider),
                        duration: Duration(seconds: 1),
                        child: AutoSizeText("Zum Fortfahren lange drücken",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        )));
  }
}
