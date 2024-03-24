import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wikiquiz_connector_android/constants/tile_colors.dart';
import 'package:wikiquiz_connector_android/main.dart';
import 'package:wikiquiz_connector_android/models/quizset.dart';
import 'package:wikiquiz_connector_android/screens/quiz_config.dart';
import 'package:wikiquiz_connector_android/widgets/loading_widget.dart';
import 'package:wikiquiz_connector_android/widgets/quizset_tile.dart';
import 'package:wikiquiz_connector_android/widgets/quizsetdialog.dart';

class QuizSetTileSwipeOverview extends ConsumerStatefulWidget {
  @override
  ConsumerState<QuizSetTileSwipeOverview> createState() =>
      _QuizSetTileSwipeOverviewState();
}

class _QuizSetTileSwipeOverviewState
    extends ConsumerState<QuizSetTileSwipeOverview> {
  final isListViewProvider = StateProvider<bool>((ref) => false);
  final loadNotifierProvider = StateProvider<(int, int)>((ref) => (0, 0));
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future(() {
      ref.read(watchConnectivityProvider).messageStream.listen(
        (event) {
          if (event['command'] == 'sync') {
            final data = json.decode(event['data']);
            ref.read(quizSetsProvider.notifier).state =
                List.generate(data.length, (i) => QuizSet.fromJson(data[i]));
            QuizSet.saveQuizSets(ref);
          }
        },
      );
    });
  }

  final _navKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    var quizSets = ref.watch(quizSetsProvider);
    final isListView = ref.watch(isListViewProvider);
    final quizSetLoading = ref.watch(loadNotifierProvider);
    ref.listen(loadNotifierProvider, (before, after) {
      if (after.$2 == after.$1 && after.$1 != 0) {
        Future.delayed(const Duration(seconds: 1), () {
          ref.read(loadNotifierProvider.notifier).state = (0, 0);
          _navKey.currentState?.push(MaterialPageRoute(
            builder: (context) => QuizConfig(),
          ));
        });
      }
    });
    return LayoutBuilder(builder: (context, constraints) {
      final isClock = constraints.maxWidth < 300;
      return MaterialApp(
          navigatorKey: _navKey,
          home: quizSetLoading.$2 != 0
              ? SafeArea(
                  child: Material(
                    child: Container(
                      color: Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DefaultTextStyle(
                            style: const TextStyle(color: Colors.white),
                            child: LoadingWiget(
                              progressIndicator:
                                  "${quizSetLoading.$1}/${quizSetLoading.$2}",
                              showProgressTextindicator: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Scaffold(
                  appBar: isClock
                      ? null
                      : AppBar(
                          title: const Text('WikiQuiz Connector'),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          actions: [
                            IconButton(
                                onPressed: () {
                                  ref.read(isListViewProvider.notifier).state =
                                      !isListView;
                                },
                                icon: isListView
                                    ? const Icon(Icons.image)
                                    : const Icon(Icons.list)),
                            IconButton(
                                onPressed: () {
                                  ref
                                      .read(watchConnectivityProvider)
                                      .sendMessage({
                                    "command": "sync",
                                    "data": json.encode(ref
                                        .read(quizSetsProvider)
                                        .map((e) => e.toJson())
                                        .toList())
                                  });
                                },
                                icon: const Icon(Icons.sync))
                          ],
                        ),
                  body: isListView
                      ? ListView.builder(
                          itemBuilder: ((context, index) {
                            QuizSet quizset = quizSets[index];
                            final tileColor =
                                tileColors[index % tileColors.length];
                            return QuizSetTile(
                                quizset: quizset, tileColor: tileColor);
                          }),
                          itemCount: quizSets.length)
                      : Container(
                          color: isClock ? Colors.black : Colors.red,
                          child: quizSets.isEmpty
                              ? buildAddQuizSetButton(ref)
                              : PageView.builder(
                                  controller: PageController(initialPage: 1),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, pageIndex) {
                                    if (pageIndex == 0) {
                                      return buildAddQuizSetButton(ref);
                                    }

                                    final index = pageIndex - 1;
                                    QuizSet quizset = quizSets[index];
                                    return PageView(
                                        key: Key(quizset.hashCode.toString()),
                                        controller:
                                            PageController(initialPage: 1),
                                        scrollDirection: Axis.vertical,
                                        children: [
                                          buildAddQuizSetButton(ref,
                                              editIndex: index),
                                          InkWell(
                                            onLongPress: () async {
                                              ref
                                                  .read(loadNotifierProvider
                                                      .notifier)
                                                  .state = (
                                                0,
                                                quizSets[index]
                                                        .articles
                                                        .length +
                                                    1
                                              );
                                              ref
                                                  .read(
                                                      quizSetProvider.notifier)
                                                  .state = quizSets[index];
                                              quizSets[index]
                                                  .loadQuizset(
                                                      ref, loadNotifierProvider)
                                                  .then((_) {});
                                            },
                                            child: Container(
                                              color: isClock
                                                  ? Colors.black
                                                  : tileColors[index],
                                              child: Center(
                                                  child: QuizSetTile(
                                                      quizset: quizset,
                                                      tileColor: isClock
                                                          ? Colors.black
                                                          : tileColors[index])),
                                            ),
                                          ),
                                          Container(
                                              color: Colors.red,
                                              child: Center(
                                                  child: ElevatedButton.icon(
                                                      onPressed: () async {
                                                        ref
                                                            .read(
                                                                quizSetsProvider
                                                                    .notifier)
                                                            .state = quizSets
                                                                .getRange(
                                                                    0, index)
                                                                .toList() +
                                                            quizSets
                                                                .getRange(
                                                                    index + 1,
                                                                    quizSets
                                                                        .length)
                                                                .toList();
                                                        await QuizSet
                                                            .saveQuizSets(ref);
                                                      },
                                                      icon: const Icon(
                                                          Icons.delete),
                                                      label:
                                                          const Text("Löschen"),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              foregroundColor:
                                                                  Colors
                                                                      .white)))),
                                        ]);
                                  },
                                  itemCount: quizSets.length + 1),
                        ),
                ));
    });
  }

  Widget buildAddQuizSetButton(ref, {editIndex}) {
    return Builder(builder: (context) {
      return Container(
          color: Colors.green,
          child: Center(
              child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return QuizSetDialog(editIndex: editIndex);
                      },
                    );
                  },
                  icon: Icon(editIndex == null ? Icons.add : Icons.edit),
                  label: Text(editIndex != null ? "Bearbeiten" : "Hinzufügen"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white))));
    });
  }
}
