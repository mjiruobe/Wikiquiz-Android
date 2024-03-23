import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  @JsonKey(name: 'question', defaultValue: null)
  final String question;
  @JsonKey(name: 'answers', defaultValue: null)
  final List<String> answers;
  @JsonKey(name: 'correctAnswer', defaultValue: null)
  final int correctAnswer;

  Question(
      {required this.question,
      required this.answers,
      required this.correctAnswer});

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
