import 'package:flutter/material.dart';

import 'kassel_navbar.dart';
import 'kassel_bottom_nav.dart';

import 'home_screen.dart';
import 'ielts_prep_screen.dart';
import 'profile_screen.dart';
import 'core/config/api_config.dart';

// ✅ Plans page
import 'plan_details_screen.dart';

// ✅ Learn & Play page
import 'learn_and_play_screen.dart';

// ✅ AI CHAT
import 'widgets/ai_chat.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.initialTabIndex = 0,
  });

  static const routeName = "/app";

  /// 0=Home, 1=IELTS, 2=Learn, 3=Account
  final int initialTabIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static final ValueNotifier<bool> _demoLoggedIn = ValueNotifier<bool>(false);

  late int _tabIndex;

  /// ✅ Demo user id used by AI + other services
  /// Important: Many backends reject placeholder values like "USER_ID_HERE".
  static const String _demoUserId = "demo_user_001";

  /// ✅ AI endpoint
  static const String _aiApiUrl = ApiConfig.aiChatUrl;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex.clamp(0, 3);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _login() {
    _demoLoggedIn.value = true;
    _toast("Logged in (demo)");
  }

  void _logout() {
    _demoLoggedIn.value = false;
    setState(() => _tabIndex = 0);
    _toast("Logged out (demo)");
  }

  void _freeTrial() => _toast("Free Trial (TODO)");

  // ✅ Plans: push صفحة البلان
  void _openPlans() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlanDetailsScreen()),
    );
  }

  // ✅ Account: يفتح تبويب الحساب داخل IndexedStack
  void _openAccountTab() {
    setState(() => _tabIndex = 3);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _demoLoggedIn,
      builder: (context, isLoggedIn, _) {
        final tabs = <Widget>[
          HomeScreen(
            insideShell: true,
            isLoggedIn: isLoggedIn,
            onRequestTab: (i) => setState(() => _tabIndex = i),
          ),
          const IeltsPrepDemoScreen(insideShell: true),
          const LearnAndPlayScreen(),
          ProfileScreen(onLogout: _logout),
        ];

        final media = MediaQuery.of(context);
        final safeBottom = media.padding.bottom;

        final double bottomNavTotal =
            isLoggedIn ? (kBottomNavigationBarHeight + safeBottom) : 0.0;

        const double baseMargin = 18.0;
        const double gapAboveNav = 12.0;

        final double aiButtonBottom = baseMargin + bottomNavTotal + gapAboveNav;

        /// ✅ Important:
        /// Use a real userId string when logged in, otherwise null to block opening the overlay.
        final String? effectiveUserId = isLoggedIn ? _demoUserId : null;

        return Stack(
          children: [
            Scaffold(
              bottomNavigationBar: isLoggedIn
                  ? KasselBottomNav(
                      currentIndex: _tabIndex,
                      onTap: (i) => setState(() => _tabIndex = i),
                    )
                  : null,
              body: SafeArea(
                child: Column(
                  children: [
                    KasselNavbar(
                      isLoggedIn: isLoggedIn,
                      hideNavWhenLoggedOut: true,

                      // Tabs
                      onGoHome: () => setState(() => _tabIndex = 0),
                      onGoIelts: () => setState(() => _tabIndex = 1),
                      onGoGames: () => setState(() => _tabIndex = 2),

                      // ✅ المطلوب
                      onGoPlans: _openPlans,
                      onGoAccount: _openAccountTab,

                      onLogin: _login,
                      onFreeTrial: _freeTrial,

                      // خليها null لأننا نستخدم callback للحساب
                      profileRouteName: null,
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: _tabIndex.clamp(0, tabs.length - 1),
                        children: tabs,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ✅ AI Overlay
            /// Fix: Provide a real userId. Placeholder breaks many backends.
            AIChatbotOverlay(
              apiUrl: _aiApiUrl,
              userId: effectiveUserId,
              title: "QuickLingo",
              initialBotMessage:
                  "Hello! I'm QuickLingo from Kassel Academy. You can ask me anything.",
              buttonLabel: "",
              buttonRight: 18,
              buttonBottom: aiButtonBottom,
            ),
          ],
        );
      },
    );
  }
}
