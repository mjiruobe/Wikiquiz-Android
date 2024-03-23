// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wikiArticle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WikiArticle _$WikiArticleFromJson(Map<String, dynamic> json) => WikiArticle(
      title: json['title'] as String,
      pageId: json['pageId'] as int,
      url: json['url'] as String?,
      mainImg: json['mainImg'] as String?,
    );

Map<String, dynamic> _$WikiArticleToJson(WikiArticle instance) =>
    <String, dynamic>{
      'title': instance.title,
      'pageId': instance.pageId,
      'url': instance.url,
      'mainImg': instance.mainImg,
    };
