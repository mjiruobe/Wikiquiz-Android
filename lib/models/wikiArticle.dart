import 'package:json_annotation/json_annotation.dart';

part 'wikiArticle.g.dart';

@JsonSerializable()
class WikiArticle {
  @JsonKey(name: 'title', defaultValue: null)
  final String title;
  @JsonKey(name: 'pageId', defaultValue: null)
  final int pageId;
  @JsonKey(name: 'url', defaultValue: null)
  final String? url;
  @JsonKey(name: 'mainImg', defaultValue: null)
  final String? mainImg;
  WikiArticle(
      {required this.title,
      required this.pageId,
      required this.url,
      required this.mainImg});

  factory WikiArticle.fromJson(Map<String, dynamic> json) =>
      _$WikiArticleFromJson(json);
  Map<String, dynamic> toJson() => _$WikiArticleToJson(this);
}
