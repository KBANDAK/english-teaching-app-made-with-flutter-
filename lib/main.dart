// lib/main.dart
import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'app_shell.dart';

// Pages
import 'home_screen.dart';
import 'ielts_prep_screen.dart';
import 'exam_screen.dart';
import 'profile_screen.dart' as profile;
import 'learn_play_screen.dart';
import 'smart_tests_screen.dart';

// Overview + Listening
import 'test_overview_screen.dart';
import 'listening_screen.dart';

// Reading
import 'ReadingScreen.dart';

// Writing
import 'writing_screen.dart';

// Speaking
import 'SpeakingScreen.dart' as speaking hide ProfileScreen;

void main() {
  runApp(const KasselApp());
}

class KasselApp extends StatelessWidget {
  const KasselApp({super.key});

  static const String splashRoute = '/splash';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kassel Academy",
      debugShowCheckedModeBanner: false,

      initialRoute: splashRoute,

      routes: {
        splashRoute: (_) => const SplashScreen(),

        AppShell.routeName: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          int idx = 0;

          if (args is int) {
            idx = args;
          } else if (args is Map) {
            final v = args['tabIndex'];
            if (v is int) idx = v;
          }

          return AppShell(initialTabIndex: idx);
        },

        HomeScreen.routeName: (_) => const HomeScreen(),
        ExamScreen.routeName: (_) => const ExamScreen(),
        IeltsPrepDemoScreen.routeName: (_) => const IeltsPrepDemoScreen(),

        // ✅ fixed: use the prefixed ProfileScreen
        profile.ProfileScreen.routeName: (_) => const profile.ProfileScreen(),

        LearnPlayScreen.routeName: (_) => const LearnPlayScreen(),
        SmartTestsScreen.routeName: (_) => const SmartTestsScreen(),
      },

      onGenerateRoute: (settings) {
        final name = settings.name ?? "";

        // READING
        final readingMatch =
            RegExp(r'^/ielts/test/([^/]+)/reading/(\d+)$').firstMatch(name);
        if (readingMatch != null) {
          final testId = readingMatch.group(1)!;
          final passageNo = int.tryParse(readingMatch.group(2) ?? "1") ?? 1;
          final safePassage = (passageNo < 1 || passageNo > 3) ? 1 : passageNo;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ReadingScreen(testId: testId, passageNo: safePassage),
          );
        }

        final readingRoot =
            RegExp(r'^/ielts/test/([^/]+)/reading$').firstMatch(name);
        if (readingRoot != null) {
          final testId = readingRoot.group(1)!;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ReadingScreen(testId: testId, passageNo: 1),
          );
        }

        // LISTENING
        final listeningMatch =
            RegExp(r'^/ielts/test/([^/]+)/listening/(\d+)$').firstMatch(name);
        if (listeningMatch != null) {
          final testId = listeningMatch.group(1)!;
          final partNo = int.tryParse(listeningMatch.group(2) ?? "1") ?? 1;
          final safePart = (partNo < 1 || partNo > 4) ? 1 : partNo;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ListeningScreen(testId: testId, partNo: safePart),
          );
        }

        final listeningRoot =
            RegExp(r'^/ielts/test/([^/]+)/listening$').firstMatch(name);
        if (listeningRoot != null) {
          final testId = listeningRoot.group(1)!;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ListeningScreen(testId: testId, partNo: 1),
          );
        }

        // WRITING
        final writingMatch =
            RegExp(r'^/ielts/test/([^/]+)/writing/(\d+)$').firstMatch(name);
        if (writingMatch != null) {
          final testIdStr = writingMatch.group(1)!;
          final taskNo = int.tryParse(writingMatch.group(2) ?? "1") ?? 1;
          final safeTask = (taskNo < 1 || taskNo > 2) ? 1 : taskNo;
          final testIdInt = int.tryParse(testIdStr) ?? 1;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => WritingScreen(testId: testIdInt, taskNo: safeTask),
          );
        }

        final writingRoot =
            RegExp(r'^/ielts/test/([^/]+)/writing$').firstMatch(name);
        if (writingRoot != null) {
          final testIdStr = writingRoot.group(1)!;
          final testIdInt = int.tryParse(testIdStr) ?? 1;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => WritingScreen(testId: testIdInt, taskNo: 1),
          );
        }

        // SPEAKING
        final speakingMatch =
            RegExp(r'^/ielts/test/([^/]+)/speaking/(\d+)$').firstMatch(name);
        if (speakingMatch != null) {
          final testIdStr = speakingMatch.group(1)!;
          final partNo = int.tryParse(speakingMatch.group(2) ?? "1") ?? 1;
          final safePart = (partNo < 1 || partNo > 3) ? 1 : partNo;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => speaking.SpeakingScreen(
              testId: testIdStr,
              initialPart: safePart,
            ),
          );
        }

        final speakingRoot =
            RegExp(r'^/ielts/test/([^/]+)/speaking$').firstMatch(name);
        if (speakingRoot != null) {
          final testIdStr = speakingRoot.group(1)!;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => speaking.SpeakingScreen(testId: testIdStr, initialPart: 1),
          );
        }

        // OVERVIEW
        final overviewMatch = RegExp(r'^/ielts/test/([^/]+)$').firstMatch(name);
        if (overviewMatch != null) {
          final testId = overviewMatch.group(1)!;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => TestOverviewScreen(id: testId),
          );
        }

        return null;
      },

      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Route Not Found")),
          body: Center(
            child: Text("No route defined for: ${settings.name}"),
          ),
        ),
      ),
    );
  }
}
