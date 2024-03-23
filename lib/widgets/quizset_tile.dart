import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_image_layout/image_model.dart';
import 'package:multi_image_layout/multi_image_viewer.dart';
import 'package:wikiquiz_connector_android/models/quizset.dart';

class QuizSetTile extends ConsumerWidget {
  final QuizSet quizset;
  final Color tileColor;
  final double? width;
  final double? height;

  const QuizSetTile({
    Key? key,
    required this.quizset,
    required this.tileColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = quizset.name;
    final isClock = MediaQuery.of(context).size.width > 300;
    final description = quizset.description;
    return LayoutBuilder(builder: (context, constraints) {
      return isClock
          ? SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  ShaderMask(
                    shaderCallback: (bound) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          const Color(0xff575757).withOpacity(0),
                          const Color(0xff000000),
                        ],
                        //tileMode: TileMode.,
                      ).createShader(bound);
                    },
                    blendMode: BlendMode.srcOver,
                    child: Container(
                      width: width,
                      height: height,
                      child: MultiImageViewer(
                        images: quizset.articles
                            .where((article) => article.mainImg != null)
                            .map((article) => ImageModel(
                                imageUrl: article.mainImg!,
                                caption: article.title))
                            .toList(),
                        height: height ?? constraints.maxHeight,
                        width: width,
                      ),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 12, left: 8, right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  Text(description,
                                      style:
                                          const TextStyle(color: Colors.white))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ))
          : Center(
              child: ListTile(
                  title: Text(quizset.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  subtitle: Text(quizset.description,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center)));
    });
  }
}
