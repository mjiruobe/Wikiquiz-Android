import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wikiquiz_connector_android/main.dart';
import 'package:wikiquiz_connector_android/models/quizset.dart';
import 'package:wikiquiz_connector_android/models/wikiArticle.dart';

class QuizSetDialog extends ConsumerStatefulWidget {
  final int? editIndex;
  QuizSetDialog({super.key, required this.editIndex});

  @override
  ConsumerState<QuizSetDialog> createState() => _QuizSetDialogState();
}

final editIndexProvider = StateProvider<int?>((ref) => null);

class _QuizSetDialogState extends ConsumerState<QuizSetDialog> {
  final articlesProvider = StateProvider<List<WikiArticle>>((ref) => []);

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final articleController =
      StateProvider<TextEditingController?>((ref) => null);
  final addArticleEnabledProvider = StateProvider((ref) => false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future(() {
      final editIndex = widget.editIndex;
      final quizSets = ref.read(quizSetsProvider);
      if (editIndex != null) {
        ref.read(articlesProvider.notifier).state =
            quizSets[editIndex].articles;
        nameController.text = quizSets[editIndex].name;
        descriptionController.text = quizSets[editIndex].description;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final articles = ref.watch(articlesProvider);
      final isClock = MediaQuery.of(context).size.width < 300;
      return AlertDialog(
          title: isClock ? null : const Text("Quizset hinzufügen"),
          content: Builder(builder: (context) {
            return isClock
                ? const Text(
                    "Bitte nutze diese Funktion auf deinem Smartphone und synchronisiere.",
                    style: TextStyle(color: Colors.black, fontSize: 12))
                : Column(
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(child: Text("Name:")),
                            const Spacer(flex: 1),
                            Expanded(
                                flex: 2,
                                child: TextField(controller: nameController))
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(child: Text("Beschreibung:")),
                            const Spacer(flex: 1),
                            Expanded(
                                flex: 2,
                                child: TextField(
                                    controller: descriptionController))
                          ],
                        ),
                      ),
                      Flexible(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                            thumbVisibility:
                                MaterialStateProperty.all<bool>(true),
                          )),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Wrap(
                                  children: List.generate(
                                      articles.length,
                                      (i) => ElevatedButton.icon(
                                          onPressed: () {
                                            ref
                                                .read(articlesProvider.notifier)
                                                .state = articles
                                                    .getRange(0, i)
                                                    .toList() +
                                                articles
                                                    .getRange(
                                                        i + 1, articles.length)
                                                    .toList();
                                          },
                                          icon: const Icon(Icons.cancel),
                                          label: Text(articles[i].title)))),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text("Wikipedia Artikel:"),
                            ),
                            const Spacer(flex: 1),
                            Expanded(
                                flex: 2,
                                child: Autocomplete<WikiArticle>(
                                  optionsBuilder: (textEditingValue) =>
                                      getWikpediaSuggestion(
                                          textEditingValue.text),
                                  displayStringForOption: (suggestion) =>
                                      suggestion.title,
                                  onSelected: (article) {
                                    ref.read(articlesProvider.notifier).state =
                                        ref.read(articlesProvider) + [article];
                                    ref
                                        .read(articleController.notifier)
                                        .state
                                        ?.text = "";
                                  },
                                  fieldViewBuilder: (context,
                                      textEditingController,
                                      focusNode,
                                      onFieldSubmitted) {
                                    Future(() {
                                      ref
                                          .read(articleController.notifier)
                                          .state = textEditingController;
                                    });
                                    return TextField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      onChanged: (value) {},
                                      onSubmitted: (_) async {
                                        final articleText =
                                            textEditingController.text;
                                        final suggestions =
                                            await getWikpediaSuggestion(
                                                articleText);
                                        if (suggestions.any((suggestion) =>
                                            suggestion.title == articleText)) {
                                          ref
                                              .read(articlesProvider.notifier)
                                              .state = ref
                                                  .read(articlesProvider) +
                                              [
                                                suggestions.firstWhere(
                                                    (article) =>
                                                        article.title ==
                                                        articleText)
                                              ];
                                          textEditingController.clear();
                                        }
                                      },
                                    );
                                  },
                                )),
                          ],
                        ),
                      )
                    ],
                  );
          }),
          actions: isClock
              ? null
              : [
                  IconButton(
                      onPressed: () {
                        ref.read(articlesProvider.notifier).state = [];
                      },
                      icon: const Icon(Icons.cancel, color: Colors.red)),
                  IconButton(
                      onPressed: () async {
                        List<WikiArticle> articles = ref.read(articlesProvider);
                        for (int i = 0; i < articles.length; i++) {
                          if (articles[i].mainImg != null &&
                              articles[i].url != null) {
                            continue;
                          }
                          var pageId = articles[i].pageId;
                          var requestURL =
                              "https://de.wikipedia.org/w/api.php?action=query&prop=info|pageimages&pageids=" +
                                  pageId.toString() +
                                  "&inprop=url&pithumbsize=1000&format=json";
                          print(requestURL);
                          var response = json.decode(
                              (await http.get(Uri.parse(requestURL))).body);
                          articles[i] = WikiArticle(
                              title: articles[i].title,
                              pageId: articles[i].pageId,
                              url: response['query']['pages'][pageId.toString()]
                                  ['fullurl'],
                              mainImg: response['query']['pages']
                                  [pageId.toString()]['thumbnail']['source']);
                        }
                        ref.read(articlesProvider.notifier).state = articles;
                        QuizSet quizSet = QuizSet(
                            name: nameController.text,
                            description: descriptionController.text,
                            articles: articles,
                            fullyLoaded: false,
                            lastSynced: null);
                        if (widget.editIndex != null) {
                          ref.read(quizSetsProvider.notifier).state = ref
                                  .read(quizSetsProvider)
                                  .getRange(0, widget.editIndex!)
                                  .toList() +
                              [quizSet] +
                              ref
                                  .read(quizSetsProvider)
                                  .getRange(widget.editIndex! + 1,
                                      ref.read(quizSetsProvider).length)
                                  .toList();
                        } else {
                          ref.read(quizSetsProvider.notifier).state =
                              ref.read(quizSetsProvider) + [quizSet];
                        }
                        QuizSet.saveQuizSets(ref);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.green))
                ]);
    });
  }

  Future<List<WikiArticle>> getWikpediaSuggestion(String text) async {
    if (text != "") {
      var requestURL =
          "https://de.wikipedia.org/w/api.php?action=query&list=search&prop=info&utf8=&format=json&origin=*&srlimit=20&srsearch=" +
              Uri.encodeComponent(text);
      var response = await http.get(Uri.parse(requestURL));
      var data = json.decode(response.body);
      return Future.value(List<WikiArticle>.from(data['query']['search']
          .map((article) => WikiArticle(
              title: article['title'],
              pageId: article['pageid'],
              url: null,
              mainImg: null))
          .toList()));
    }
    return Future.value([]);
  }
}
