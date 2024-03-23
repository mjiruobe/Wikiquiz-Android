import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SwipeCompassController {
  Function? initFinished;
  SwipeCompassController({this.initFinished});
  Function? left, right, top, bottom;
  Function(bool)? enable;
  Function(Offset)? setPage;
  void init(left, right, top, bottom, enable, setPage) {
    this.left = left;
    this.right = right;
    this.top = top;
    this.bottom = bottom;
    this.enable = enable;
    this.setPage = setPage;
    if (initFinished != null) {
      initFinished!();
    }
  }

  void swipeLeft() {
    if (left != null) {
      left!();
    }
  }

  void swipeRight() {
    if (right != null) {
      right!();
    }
  }

  void swipeTop() {
    if (top != null) {
      top!();
    }
  }

  void swipeBottom() {
    if (bottom != null) {
      bottom!();
    }
  }

  void enableSwipe(b) {
    enable!(b);
  }

  void backToMain() {
    setPage!(const Offset(1, 1));
  }
}

class SwipeCompass extends ConsumerStatefulWidget {
  final Widget left, right, top, bottom, main;
  final SwipeCompassController? controller;

  SwipeCompass(
      {required this.left,
      required this.right,
      required this.top,
      required this.bottom,
      required this.main,
      this.controller});

  @override
  ConsumerState<SwipeCompass> createState() => _SwipeCompassState();
}

class _SwipeCompassState extends ConsumerState<SwipeCompass> {
  PageController hPagerController =
      PageController(keepPage: true, initialPage: 1);
  PageController vPagerController =
      PageController(keepPage: true, initialPage: 1);
  final hEnabledProvider = StateProvider((ref) => true);
  final vEnabledProvider = StateProvider((ref) => true);
  final hEnabledIntervalProvider = StateProvider((ref) => true);

  var vPageVievKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future(() {
      vPagerController.addListener(() {
        try {
          Future(() {
            if (vPagerController.page != 1) {
              ref.read(hEnabledIntervalProvider.notifier).state = false;
            } else {
              ref.read(hEnabledIntervalProvider.notifier).state = true;
            }
          });
        } catch (e) {
          // TODO
        }
      });
      if (widget.controller != null) {
        widget.controller!.init(() {
          try {
            double? hPage = hPagerController.page;
            hPagerController.animateToPage((hPage ?? 1).round() + 1,
                duration: Duration(seconds: 1), curve: Curves.bounceIn);
          } catch (e) {
            // TODO
          }
        }, () {
          try {
            double? hPage = hPagerController.page;
            hPagerController.animateToPage((hPage ?? 1).round() - 1,
                duration: Duration(seconds: 1), curve: Curves.bounceIn);
          } catch (e) {
            // TODO
          }
        }, () {
          try {
            double? vPage = vPagerController.page;
            vPagerController.animateToPage((vPage ?? 1).round() + 1,
                duration: Duration(seconds: 1), curve: Curves.bounceIn);
          } catch (e) {
            // TODO
          }
        }, () {
          try {
            double? vPage = vPagerController.page;
            vPagerController.animateToPage((vPage ?? 1).round() - 1,
                duration: Duration(seconds: 1), curve: Curves.bounceIn);
          } catch (e) {
            // TODO
          }
        }, (value) {
          Future(() {
            ref.read(hEnabledProvider.notifier).state = value;
            ref.read(vEnabledProvider.notifier).state = value;
          });
        }, (offset) {
          hPagerController.animateToPage(offset.dx.round(),
              duration: Duration(seconds: 1), curve: Curves.bounceIn);
          try {
            vPagerController.animateToPage(offset.dy.round(),
                duration: Duration(seconds: 1), curve: Curves.bounceIn);
          } catch (e) {
            // TODO
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final henabled = ref.watch(hEnabledProvider);
    final henabledInterval = ref.watch(hEnabledIntervalProvider);
    return (PageView(
        physics: (henabled && henabledInterval)
            ? null
            : const NeverScrollableScrollPhysics(),
        controller: hPagerController,
        scrollDirection: Axis.horizontal,
        children: [
          widget.left,
          PageView(
            physics: ref.read(vEnabledProvider)
                ? null
                : const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            key: vPageVievKey,
            controller: vPagerController,
            children: [widget.top, widget.main, widget.bottom],
          ),
          widget.right
        ]));
  }
}
