import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:wikiquiz_connector_android/models/quizset.dart';
import 'package:wikiquiz_connector_android/screens/quizsettile_swipeoverview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Wakelock.enable();
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      child: QuizSetTileSwipeOverview(),
    ),
  );
}

final sharedPrefs = FutureProvider<SharedPreferences>(
    (_) async => await SharedPreferences.getInstance());

final quizSetsProvider = StateProvider<List<QuizSet>>((ref) {
  final pref = ref.watch(sharedPrefs);
  final value = pref.maybeWhen(
      data: (pref) => pref.getString('quizsets') ?? "[]", orElse: () => "[]");
  return List<QuizSet>.from(
      (json.decode(value) as List<dynamic>).map((e) => QuizSet.fromJson(e)));
});

final watchConnectivityProvider = Provider<WatchConnectivity>((ref) {
  final watch = WatchConnectivity();
  return watch;
});
