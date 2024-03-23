// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quizset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizSet _$QuizSetFromJson(Map<String, dynamic> json) => QuizSet(
      name: json['name'] as String,
      description: json['description'] as String,
      articles: (json['articles'] as List<dynamic>)
          .map((e) => WikiArticle.fromJson(e as Map<String, dynamic>))
          .toList(),
      fullyLoaded: json['fullyLoaded'] as bool,
      lastSynced: json['lastSynced'] == null
          ? null
          : DateTime.parse(json['lastSynced'] as String),
    )..questions = (json['questions'] as List<dynamic>)
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$QuizSetToJson(QuizSet instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'articles': instance.articles,
      'fullyLoaded': instance.fullyLoaded,
      'lastSynced': instance.lastSynced?.toIso8601String(),
      'questions': instance.questions,
    };
