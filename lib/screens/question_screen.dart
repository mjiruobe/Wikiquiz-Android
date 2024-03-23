import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wikiquiz_connector_android/models/question.dart';
import 'package:wikiquiz_connector_android/models/quizresult.dart';
import 'package:wikiquiz_connector_android/screens/resultscreen.dart';
import 'package:wikiquiz_connector_android/widgets/swipe_compass.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

final questionsProvider = StateProvider<List<Question>>((ref) => []);
final currentQuestionIndexProvider = StateProvider((ref) {
  int randQuestion;
  randQuestion = Random().nextInt(ref.read(questionsProvider).length);
  return randQuestion;
});
final questionDataProvider = StateProvider<Question>((ref) {
  return ref.watch(questionsProvider)[ref.watch(currentQuestionIndexProvider)];
});

final questionsDoneProvider = StateProvider<int>((ref) => 0);

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  late SwipeCompassController compassController;
  var swiping = false;
  final visibileAnswersProvider = StateProvider((ref) => 0);
  final answerBtnVisibleProvider = StateProvider((ref) => true);
  final cancelProvider = StateProvider((ref) => false);
  final answerChoosedProvider = StateProvider<int?>((ref) => null);
  late ConfettiController _confettiController;

  int correct = 0, wrong = 0;
  void setNewQuestion() {
    final questionsProviderRead = ref.read(questionsProvider);
    final currentQuestionIndexRead = ref.read(currentQuestionIndexProvider);
    if (questionsProviderRead.isNotEmpty) {
      ref.read(currentQuestionIndexProvider.notifier).state = -1;
      ref.read(questionsProvider.notifier).state = questionsProviderRead
              .getRange(0, currentQuestionIndexRead)
              .toList() +
          questionsProviderRead
              .getRange(
                  currentQuestionIndexRead + 1, questionsProviderRead.length)
              .toList();
      ref.read(questionsDoneProvider.notifier).state++;
      print("Called block ${questionsProviderRead.length}");
    }
    final questions = ref.read(questionsProvider);
    final questionsDone = ref.read(questionsDoneProvider);
    if (questions.isEmpty) {
      Future(() {
        ref.read(cancelProvider.notifier).state = true;
      });
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return ResultScreen(
            quizResult: QuizResult(
                answercount: questionsDone, wrong: wrong, correct: correct),
          );
        },
      ));
      return;
    }
    int randQuestion;
    randQuestion = Random().nextInt(questions.length);
    ref.read(currentQuestionIndexProvider.notifier).state = randQuestion;
  }

  @override
  void initState() {
    super.initState();
    Future(() {
      ref.read(currentQuestionIndexProvider.notifier).state = 0;
      ref.read(questionsDoneProvider.notifier).state = 0;
    });
    compassController = SwipeCompassController(
        initFinished: () => compassController.enableSwipe(false));
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
    showAnswers();
  }

  void showAnswers() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !ref.read(cancelProvider)) {
        ref.read(visibileAnswersProvider.notifier).state =
            ref.read(visibileAnswersProvider) + 1;
        Future.delayed(const Duration(seconds: 1), () {
          if (ref.read(cancelProvider)) {
            return;
          }
          if (ref.read(visibileAnswersProvider) == 1) {
            compassController.swipeBottom();
          } else if (ref.read(visibileAnswersProvider) == 2) {
            compassController.swipeRight();
          } else if (ref.read(visibileAnswersProvider) == 3) {
            compassController.swipeLeft();
          } else if (ref.read(visibileAnswersProvider) == 4) {
            compassController.swipeTop();
          }
          Future.delayed(Duration(seconds: 5), () {
            if (ref.read(cancelProvider)) {
              return;
            }
            if (ref.read(visibileAnswersProvider) == 1) {
              compassController.swipeTop();
            } else if (ref.read(visibileAnswersProvider) == 2) {
              compassController.swipeLeft();
            } else if (ref.read(visibileAnswersProvider) == 3) {
              compassController.swipeRight();
            } else if (ref.read(visibileAnswersProvider) == 4) {
              compassController.swipeBottom();
              Future.delayed(Duration(seconds: 1), () {
                compassController.enableSwipe(true);
              });
            }
            if (ref.read(visibileAnswersProvider) < 5) {
              if (ref.read(cancelProvider)) {
                return;
              }
              showAnswers();
            }
          });
        });
      } else {
        print("Not mounted");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final answerChoosed = ref.watch(answerChoosedProvider);
    final answerBtnVisible = ref.watch(answerBtnVisibleProvider);
    final visibleAnswers = ref.watch(visibileAnswersProvider);
    final currentQuestionIndex = ref.watch(currentQuestionIndexProvider);
    final questions = ref.watch(questionsProvider);
    final questionData =
        currentQuestionIndex != -1 ? questions[currentQuestionIndex] : null;

    ref.listen(answerChoosedProvider, (prev, next) {
      print("Changed answerChoosed from $prev to $next");
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Align(
            alignment:

                // confetti will pop from top-center
                Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 1,
              emissionFrequency: 0.5,

              // 10 paticles will pop-up at a time
              numberOfParticles: 20,

              // particles will come down
              gravity: 1,

              // start again as soon as the
              // animation is finished
              shouldLoop: true,

              // assign colors of any choice
              colors: const [
                Colors.green,
                Colors.yellow,
                Colors.pink,
                Colors.orange,
                Colors.blue
              ],
            ),
          ),
          Center(
              child: SwipeCompass(
            controller: compassController,
            left: questionData != null
                ? (Container(
                    key: GlobalKey(),
                    child: answerChoosed == null
                        ? Answer(
                            text: questionData.answers[0],
                            onChoosed: () => giveAnswer(ref, 0),
                            btnvisible: answerBtnVisible,
                          )
                        : finishedWidget(questionData, 0)))
                : const SizedBox.shrink(),
            right: questionData != null
                ? (answerChoosed == null
                    ? Answer(
                        text: questionData.answers[1],
                        onChoosed: () => giveAnswer(ref, 1),
                        btnvisible: answerBtnVisible,
                      )
                    : finishedWidget(questionData, 1))
                : const SizedBox.shrink(),
            top: questionData != null
                ? (answerChoosed == null
                    ? Answer(
                        text: questionData.answers[2],
                        onChoosed: () => giveAnswer(ref, 2),
                        btnvisible: answerBtnVisible,
                      )
                    : finishedWidget(questionData, 2))
                : const SizedBox.shrink(),
            bottom: questionData != null
                ? (answerChoosed == null
                    ? Answer(
                        text: questionData.answers[3],
                        onChoosed: () => giveAnswer(ref, 3),
                        btnvisible: answerBtnVisible,
                      )
                    : finishedWidget(questionData, 3))
                : const SizedBox.shrink(),
            main: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                        maxHeight: MediaQuery.of(context).size.height * 0.5),
                    child: InkWell(
                        child: AutoSizeText(questionData?.question ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white))),
                  ),
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: Text(visibleAnswers > 0 ? "A" : "",
                        style: const TextStyle(color: Colors.white))),
                // v2
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(visibleAnswers > 1 ? "B" : "",
                        style: const TextStyle(color: Colors.white))),
                // v3
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(visibleAnswers > 2 ? "C" : "",
                        style: const TextStyle(color: Colors.white))),
                // v4
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(visibleAnswers > 3 ? "D" : "",
                        style: const TextStyle(color: Colors.white))),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget finishedWidget(Question questionData, givenAnswerIndex) {
    return Center(
        child: questionData.correctAnswer == givenAnswerIndex
            ? AnimatedTextKit(animatedTexts: [
                ScaleAnimatedText("Richtig!",
                    textStyle:
                        const TextStyle(fontSize: 25, color: Colors.white))
              ])
            : AnimatedTextKit(isRepeatingAnimation: false, animatedTexts: [
                TypewriterAnimatedText("Falsch!",
                    textStyle:
                        const TextStyle(fontSize: 25, color: Colors.white)),
                TypewriterAnimatedText(
                    "Die richtige Antwort wäre\n" +
                        questionData.answers[questionData.correctAnswer],
                    textStyle:
                        const TextStyle(fontSize: 25, color: Colors.white),
                    textAlign: TextAlign.center)
              ]));
  }

  Future<void> giveAnswer(ref, answer) {
    compassController.enableSwipe(false);
    ref.read(answerBtnVisibleProvider.notifier).state = false;
    ref.read(cancelProvider.notifier).state = true;
    ref.read(answerChoosedProvider.notifier).state = answer;
    if (ref.read(questionDataProvider).correctAnswer == answer) {
      _confettiController.play();
      correct++;
    } else {
      wrong++;
    }

    Future.delayed(const Duration(seconds: 2), () {
      _confettiController.stop();

      Future.delayed(const Duration(seconds: 2), () {
        resetGame(ref);
      });
    });
    return Future.value(null);
  }

  void resetGame(ref) {
    ref.read(visibileAnswersProvider.notifier).state = 0;
    compassController.backToMain();

    Future.delayed(Duration(seconds: 1), () {
      ref.read(answerBtnVisibleProvider.notifier).state = true;
      ref.read(cancelProvider.notifier).state = false;
      ref.read(answerChoosedProvider.notifier).state = null;
      showAnswers();
      setNewQuestion();
    });
  }
}

class Answer extends StatelessWidget {
  final String text;
  final Function onChoosed;
  final bool btnvisible;
  Answer(
      {required this.text, required this.onChoosed, required this.btnvisible});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Align(
          alignment: Alignment.center,
          child: Text(text, style: const TextStyle(color: Colors.white))),
      btnvisible
          ? Align(
              alignment: Alignment.bottomCenter,
              child: CircleAvatar(
                backgroundColor: Colors.grey[500],
                child: IconButton(
                    color: Colors.green,
                    onPressed: () => onChoosed(),
                    icon: Icon(Icons.check)),
              ))
          : const SizedBox.shrink()
    ]);
  }
}
