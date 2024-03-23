import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wikiquiz_connector_android/env.dart';
import 'package:wikiquiz_connector_android/main.dart';
import 'package:wikiquiz_connector_android/models/question.dart';
import 'package:wikiquiz_connector_android/models/wikiArticle.dart';

part 'quizset.g.dart';

@JsonSerializable()
class QuizSet {
  @JsonKey(name: 'name', defaultValue: null)
  final String name;
  @JsonKey(name: 'description', defaultValue: null)
  final String description;
  @JsonKey(name: 'articles', defaultValue: null)
  final List<WikiArticle> articles;
  @JsonKey(name: 'fullyLoaded', defaultValue: null)
  bool fullyLoaded = false;
  @JsonKey(name: 'lastSynced', defaultValue: null)
  final DateTime? lastSynced;
  @JsonKey(name: 'questions', defaultValue: null)
  List<Question> questions = [];

  factory QuizSet.fromJson(Map<String, dynamic> json) =>
      _$QuizSetFromJson(json);
  Map<String, dynamic> toJson() => _$QuizSetToJson(this);

  QuizSet(
      {required this.name,
      required this.description,
      required this.articles,
      required this.fullyLoaded,
      required this.lastSynced});

  Future<void> loadQuizset() async {
    var articleList = json.encode(articles.map((e) => e.url).toList());

    if (!fullyLoaded) {
      await () async {
        var headers = {
          'Content-Type': 'application/json',
          'access_token': apiKey
        };
        var request = http.Request(
            'POST', Uri.parse('$apiBaseUrl/api/v1/requestarticles'));
        request.body = articleList;
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
      }();
    }
    while (!fullyLoaded) {
      await () async {
        var headers = {
          'Content-Type': 'application/json',
          'access_token': apiKey
        };
        var request = http.Request(
            'GET', Uri.parse('$apiBaseUrl/api/v1/getarticlestate'));
        request.body = articleList;

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        var resp = json.decode(await response.stream.bytesToString());
        print(resp);
        fullyLoaded = (resp['data'] as List<dynamic>)
            .every((element) => element['state'] == "finish");
      }();
      await Future.delayed(Duration(seconds: 2));
    }

    if (questions.isEmpty) {
      var headers = {
        'Content-Type': 'application/json',
        'access_token': apiKey
      };
      var request =
          http.Request('GET', Uri.parse('$apiBaseUrl/api/v1/getquestions'));
      request.body = articleList;

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var resp = json.decode(await response.stream.bytesToString());
        for (var questionData in resp) {
          questions.add(Question(
              question: questionData['question'],
              answers: List<String>.from(
                  questionData['answers'].map((e) => e.toString())),
              correctAnswer: questionData['correct_answer'][0]));
        }
      } else {
        print(response.reasonPhrase);
      }
    }
  }

  static Future<void> saveQuizSets(ref) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "quizsets",
        json.encode(
            ref.read(quizSetsProvider).map((e) => e.toJson()).toList()));
  }
}
