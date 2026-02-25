import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ielts_prep_screen.dart';
import 'kassel_navbar.dart';

import 'kassel_bottom_nav.dart';
import 'app_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.insideShell = false,
    this.isLoggedIn = false,
    this.onRequestTab,
  });

  static const routeName = "/home";

  final bool insideShell;
  final bool isLoggedIn;

  /// 0=Home,1=IELTS,2=Learn,3=Account
  final ValueChanged<int>? onRequestTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _gamesKey = GlobalKey();
  final GlobalKey _ieltsKey = GlobalKey();

  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOut,
      alignment: 0.06,
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // ✅ Bottom Nav handler (only used when HomeScreen is standalone)
  void _onBottomNavTap(int i) {
    if (widget.insideShell) {
      widget.onRequestTab?.call(i);
      return;
    }

    // ✅ افتح AppShell مباشرة على التبويب المطلوب
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AppShell(initialTabIndex: i)),
    );
  }

  String t(String key) {
    const map = {
      "title": "Kassel",
      "subtitle": "Academy",
      "description":
          "Learn English with smart practice, AI feedback, and exam preparation.",
      "StartLearningNow": "Start Learning Now",
      "btn placment test": "Placement Test",
      "learnAndPlay": "Learn & Play",
      "subTitleLearnAndPlay": "Fun practice tools to build real skills.",
      "EnglishExamPreparationTitle": "English Exam Preparation",
      "EnglishExamPreparationSubTitle":
          "IELTS-focused preparation with structured practice.",
    };
    return map[key] ?? key;
  }

  final List<_LPFeature> learnAndPlayFeatures = const [
    _LPFeature("game", "Games", "Mini-games to practice vocabulary and grammar."),
    _LPFeature("mic", "Speaking", "Practice speaking prompts with feedback."),
    _LPFeature("listen", "Listening", "Listening drills aligned with exam style."),
    _LPFeature("progress", "Progress", "Track your performance and improvements."),
  ];

  final List<_ExamPoint> examPrepPoints = const [
    _ExamPoint("ai", "AI Feedback", "Get targeted feedback to improve faster.", 0xFFE3F2FD),
    _ExamPoint("study", "Real Exam Style", "Practice questions formatted like IELTS.", 0xFFE8F5E9),
    _ExamPoint("chart", "Performance Reports", "Understand weaknesses with reports.", 0xFFFFF3E0),
    _ExamPoint("user", "Personalized Path", "Study plan tailored to your level.", 0xFFF3E5F5),
  ];

  IconData iconFromKey(String key) {
    return switch (key) {
      "game" => Icons.sports_esports,
      "mic" => Icons.mic,
      "medal" => Icons.emoji_events,
      "user" => Icons.person,
      "ai" => Icons.auto_awesome,
      "listen" => Icons.headphones,
      "progress" => Icons.trending_up,
      "study" => Icons.school,
      "chart" => Icons.bar_chart,
      _ => Icons.star,
    };
  }

  Future<void> _openSmartTest() async {
    final uri = Uri.parse("https://smarttest.kasselacademy.xyz");
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) _toast("Could not open SmartTest link");
  }

  void _goToPlans() {
    _toast("Plans handled in AppShell Navbar");
  }

  void _openIeltsPrep() {
    if (widget.insideShell && widget.onRequestTab != null) {
      widget.onRequestTab!(1);
      return;
    }
    Navigator.pushNamed(context, IeltsPrepDemoScreen.routeName);
  }

  void _openLearnPlay() {
    if (widget.insideShell && widget.onRequestTab != null) {
      widget.onRequestTab!(2);
      return;
    }
    _toast("Learn & Play page is inside AppShell tab.");
  }

  void _openaccount() {
    if (widget.insideShell && widget.onRequestTab != null) {
      widget.onRequestTab!(3);
      return;
    }
    _onBottomNavTap(3);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isMobile = width < 768;
        final bool isDesktop = width >= 992;

        final double horizontalPadding = isMobile ? 16 : 24;
        final double heroTitleSize = isMobile ? 30 : (isDesktop ? 46 : 40);
        final double heroDescSize = isMobile ? 15 : 16;

        return Scaffold(
          bottomNavigationBar: widget.insideShell
              ? null
              : KasselBottomNav(
                  currentIndex: 0,
                  onTap: _onBottomNavTap,
                ),
          body: SafeArea(
            child: Column(
              children: [
                if (!widget.insideShell)
                  KasselNavbar(
                    isLoggedIn: widget.isLoggedIn,
                    hideNavWhenLoggedOut: true,
                    onGoHome: () => _scrollTo(_homeKey),
                    onGoIelts: _openIeltsPrep,
                    onGoGames: () => _scrollTo(_gamesKey),
                    onGoPlans: _goToPlans,
                    onGoAccount: _openaccount,
                    onLogin: () => _toast("Login handled elsewhere"),
                    onFreeTrial: () => _toast("Free Trial handled elsewhere"),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              // HERO
                              Container(
                                key: _homeKey,
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: isMobile ? 18 : 26,
                                ),
                                child: isDesktop
                                    ? Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: _HeroText(
                                              title: t("title"),
                                              subtitle: t("subtitle"),
                                              description: t("description"),
                                              titleSize: heroTitleSize,
                                              descSize: heroDescSize,
                                              isMobile: isMobile,
                                              onStartLearning: _goToPlans,
                                              onPlacementTest: _openSmartTest,
                                              startText: t("StartLearningNow"),
                                              placementText: t("btn placment test"),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(child: _HeroImage(floatAnim: _floatAnim)),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          _HeroText(
                                            title: t("title"),
                                            subtitle: t("subtitle"),
                                            description: t("description"),
                                            titleSize: heroTitleSize,
                                            descSize: heroDescSize,
                                            isMobile: isMobile,
                                            onStartLearning: _goToPlans,
                                            onPlacementTest: _openSmartTest,
                                            startText: t("StartLearningNow"),
                                            placementText: t("btn placment test"),
                                          ),
                                          const SizedBox(height: 16),
                                          _HeroImage(floatAnim: _floatAnim),
                                        ],
                                      ),
                              ),

                              // LEARN & PLAY SECTION
                              Container(
                                key: _gamesKey,
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: 18,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      t("learnAndPlay"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isMobile ? 26 : 32,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(t("subTitleLearnAndPlay"), textAlign: TextAlign.center),
                                    const SizedBox(height: 14),
                                    LayoutBuilder(
                                      builder: (context, c) {
                                        final bool twoCols = !isMobile && c.maxWidth >= 680;
                                        final double cardWidth =
                                            twoCols ? (c.maxWidth - 12) / 2 : c.maxWidth;

                                        return Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: learnAndPlayFeatures.map((f) {
                                            return SizedBox(
                                              width: cardWidth,
                                              child: _LearnCard(
                                                icon: iconFromKey(f.iconKey),
                                                title: f.title,
                                                text: f.text,
                                                isMobile: isMobile,
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _AssetImageBox(
                                      assetPath: "assets/images/learnimg.png",
                                      isMobile: isMobile,
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: isMobile ? double.infinity : 280,
                                      child: OutlinedButton.icon(
                                        onPressed: _openLearnPlay,
                                        icon: const Icon(Icons.videogame_asset),
                                        label: const Text("Open Learn & Play"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // IELTS PREP SECTION
                              Container(
                                key: _ieltsKey,
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: 18,
                                ),
                                child: isDesktop
                                    ? Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _AssetImageBox(
                                              assetPath: "assets/images/englishprep.png",
                                              isMobile: isMobile,
                                            ),
                                          ),
                                          const SizedBox(width: 18),
                                          Expanded(
                                            child: _ExamPrepSection(
                                              title: t("EnglishExamPreparationTitle"),
                                              subtitle: t("EnglishExamPreparationSubTitle"),
                                              points: examPrepPoints,
                                              iconFromKey: iconFromKey,
                                              isMobile: isMobile,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Text(
                                            t("EnglishExamPreparationTitle"),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: isMobile ? 26 : 32,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            t("EnglishExamPreparationSubTitle"),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 14),
                                          _AssetImageBox(
                                            assetPath: "assets/images/englishprep.png",
                                            isMobile: isMobile,
                                          ),
                                          const SizedBox(height: 14),
                                          _ExamPrepCards(
                                            points: examPrepPoints,
                                            iconFromKey: iconFromKey,
                                            isMobile: isMobile,
                                          ),
                                        ],
                                      ),
                              ),

                              const SizedBox(height: 24),
                              SizedBox(
                                width: isMobile ? double.infinity : 260,
                                child: ElevatedButton.icon(
                                  onPressed: _openIeltsPrep,
                                  icon: const Icon(Icons.school),
                                  label: const Text("Go to IELTS Prep"),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ===================== HERO TEXT ===================== */

class _HeroText extends StatelessWidget {
  const _HeroText({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.titleSize,
    required this.descSize,
    required this.isMobile,
    required this.onStartLearning,
    required this.onPlacementTest,
    required this.startText,
    required this.placementText,
  });

  final String title;
  final String subtitle;
  final String description;
  final double titleSize;
  final double descSize;
  final bool isMobile;
  final VoidCallback onStartLearning;
  final VoidCallback onPlacementTest;
  final String startText;
  final String placementText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
            children: [
              TextSpan(text: "$title ", style: const TextStyle(color: Colors.blue)),
              TextSpan(text: subtitle, style: const TextStyle(color: Colors.black)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(description, style: TextStyle(fontSize: descSize, height: 1.45)),
        const SizedBox(height: 16),
        if (isMobile) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStartLearning,
              icon: const Icon(Icons.gps_fixed),
              label: Text(startText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPlacementTest,
              icon: const Icon(Icons.bar_chart),
              label: Text(placementText),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ] else ...[
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: onStartLearning,
                icon: const Icon(Icons.gps_fixed),
                label: Text(startText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onPlacementTest,
                icon: const Icon(Icons.bar_chart),
                label: Text(placementText),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/* ===================== HERO IMAGE ===================== */

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.floatAnim});
  final Animation<double> floatAnim;

  @override
  Widget build(BuildContext context) {
    const url =
        "https://res.cloudinary.com/dqimsdiht/image/upload/f_auto,q_auto:eco/v1761462788/hero-ai-transparent_lbzwmz.webp";

    return AnimatedBuilder(
      animation: floatAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -floatAnim.value),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 10),
                  color: Color(0x22000000),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 1.15,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (_, __, ___) =>
                    const Center(child: Text("Hero image failed to load")),
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ===================== LEARN CARD ===================== */

class _LearnCard extends StatelessWidget {
  const _LearnCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.isMobile,
  });

  final IconData icon;
  final String title;
  final String text;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFEEF5FF),
                  border: Border.all(color: const Color(0x22000000)),
                ),
                child: Icon(icon),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(text),
        ],
      ),
    );
  }
}

/* ===================== ASSET IMAGE BOX ===================== */

class _AssetImageBox extends StatelessWidget {
  const _AssetImageBox({required this.assetPath, required this.isMobile});
  final String assetPath;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 260 : 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22000000)),
        color: const Color(0xFFF7F7F7),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              "Missing asset:\n$assetPath",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== EXAM SECTION ===================== */

class _ExamPrepSection extends StatelessWidget {
  const _ExamPrepSection({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.iconFromKey,
    required this.isMobile,
  });

  final String title;
  final String subtitle;
  final List<_ExamPoint> points;
  final IconData Function(String) iconFromKey;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        _ExamPrepCards(points: points, iconFromKey: iconFromKey, isMobile: isMobile),
      ],
    );
  }
}

class _ExamPrepCards extends StatelessWidget {
  const _ExamPrepCards({
    required this.points,
    required this.iconFromKey,
    required this.isMobile,
  });

  final List<_ExamPoint> points;
  final IconData Function(String) iconFromKey;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final bool twoCols = !isMobile && c.maxWidth >= 700;
        final double w = twoCols ? (c.maxWidth - 12) / 2 : c.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: points.map((p) {
            return SizedBox(
              width: w,
              child: _ExamPointCard(
                icon: iconFromKey(p.iconKey),
                title: p.title,
                text: p.text,
                bgColor: Color(p.color),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ExamPointCard extends StatelessWidget {
  const _ExamPointCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.bgColor,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22000000)),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(color: const Color(0x22000000)),
            ),
            child: Icon(icon, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 6),
                Text(text, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== MODELS ===================== */

class _LPFeature {
  final String iconKey;
  final String title;
  final String text;
  const _LPFeature(this.iconKey, this.title, this.text);
}

class _ExamPoint {
  final String iconKey;
  final String title;
  final String text;
  final int color;
  const _ExamPoint(this.iconKey, this.title, this.text, this.color);
}
