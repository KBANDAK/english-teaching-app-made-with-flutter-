import 'package:flutter/material.dart';

class LearnAndPlayScreen extends StatelessWidget {
  const LearnAndPlayScreen({super.key});

  static const List<_GameModel> _games = [
    _GameModel(
      title: "Flinq",
      desc: "Create room and start playing",
      color: Color(0xFFD9263E),
      cta: _GameCta.soon,
      buttonLabel: "Coming Soon 🚀",
      gradient: [Color(0xFFD9266E), Color(0xFFD99A26)],
      icon: Icons.sports_esports,
    ),
    _GameModel(
      title: "Listen And Choose",
      desc: "Listen And Choose games",
      color: Color(0xFFD3D926),
      cta: _GameCta.soon,
      buttonLabel: "Coming Soon 🚀",
      gradient: [Color(0xFFE3E689), Color(0xFFD3D926)],
      icon: Icons.grid_on,
    ),
    _GameModel(
      title: "English Match",
      desc: "Royal Match–style puzzle with vocabulary learning",
      color: Color(0xFF2563EB),
      cta: _GameCta.soon,
      buttonLabel: "Coming Soon 🚀",
      gradient: [Color(0xFF2563EB), Color(0xFF6366F1)],
      icon: Icons.extension, // puzzle-ish
    ),
    _GameModel(
      title: "Snakes & Ladders Quiz",
      desc: "Answer questions to climb ladders and avoid snakes",
      color: Color(0xFFC026D3),
      cta: _GameCta.soon,
      buttonLabel: "Coming Soon 🚀",
      gradient: [Color(0xFFC026D3), Color(0xFFEC4899)],
      icon: Icons.apps,
    ),
    _GameModel(
      title: "Reading Adventure",
      desc: "Interactive reading comprehension games",
      color: Color(0xFF0EA5A4),
      cta: _GameCta.soon,
      buttonLabel: "Coming Soon 🚀",
      gradient: [Color(0xFF67E8F9), Color(0xFF22D3EE)],
      icon: Icons.menu_book,
    ),
    _GameModel(
      title: "Scramble Word",
      desc: "Scarmble Word games",
      color: Color(0xFFD99A26),
      cta: _GameCta.soon,
      buttonLabel: "Coming Soon 🚀",
      gradient: [Color(0xFFDEAE54), Color(0xFFD9263E)],
      icon: Icons.hearing,
    ),
    _GameModel(
      title: "Speaking Challenge",
      desc: "Practice speaking with an animated character guide",
      color: Color(0xFF16A34A),
      cta: _GameCta.soon,
      buttonLabel: "Coming Soon 🚀",
      gradient: [Color(0xFF16A34A), Color(0xFF10B981)],
      icon: Icons.mic,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final crossAxisCount = isWide ? 2 : 1;

            // ✅ ارتفاع ثابت للكارد يمنع الـOverflow
            final double cardHeight = isWide ? 190 : 200;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),

                  // Header
                  Text(
                    "Choose Your Game Mode 🎮",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Make learning fun with interactive game-based exercises!",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _games.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: cardHeight, // ✅ الحل
                    ),
                    itemBuilder: (context, i) => _GameCard(g: _games[i]),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _GameCta { soon, play }

class _GameModel {
  final String title;
  final String desc;
  final Color color;
  final _GameCta cta;
  final String buttonLabel;
  final List<Color> gradient;
  final IconData icon;

  const _GameModel({
    required this.title,
    required this.desc,
    required this.color,
    required this.cta,
    required this.buttonLabel,
    required this.gradient,
    required this.icon,
  });
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.g});

  final _GameModel g;

  @override
  Widget build(BuildContext context) {
    final disabled = g.cta == _GameCta.soon;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9E9EE)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 6),
            color: Color(0x11000000),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: g.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(g.icon, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            g.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (disabled)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE08A),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0x33B45309)),
                            ),
                            child: Text(
                              "Soon!",
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF3B2F00),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      g.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ حشو مرن يدفع الزر للأسفل بدون Overflow
          const Expanded(child: SizedBox()),

          // Button
          SizedBox(
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: g.gradient),
                borderRadius: BorderRadius.circular(999),
              ),
              child: ElevatedButton(
                onPressed: disabled
                    ? null
                    : () {
                        // بدون ربط - لاحقاً تضع التنقل هنا إذا أردت
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Opacity(
                  opacity: disabled ? 0.75 : 1,
                  child: Text(
                    g.buttonLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
