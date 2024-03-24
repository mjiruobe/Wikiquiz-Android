import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wikiquiz_connector_android/constants/tile_colors.dart';

class LoadingWiget extends ConsumerStatefulWidget {
  final String progressIndicator;
  final bool showProgressTextindicator;

  const LoadingWiget(
      {super.key,
      this.progressIndicator = "",
      this.showProgressTextindicator = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends ConsumerState<LoadingWiget> {
  final pointCountProvider = StateProvider<int>((ref) => 1);
  Timer? animationTimer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startAnimation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final pointCount = ref.watch(pointCountProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const LoadingIndicator(
          indicatorType: Indicator.ballGridPulse,
          colors: tileColors,
          strokeWidth: 2,
          backgroundColor: Colors.black,
          pathBackgroundColor: Colors.black),
      widget.showProgressTextindicator
          ? Column(children: [
              const SizedBox(height: 24),
              Text(
                "Loading${"".padRight(pointCount, ".")}",
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 6),
              Text(
                widget.progressIndicator,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              )
            ])
          : const SizedBox.shrink()
    ]);
  }

  void startAnimation() {
    animationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      ref.read(pointCountProvider.notifier).state =
          ((ref.read(pointCountProvider)) % 3) + 1;
    });
  }
}
