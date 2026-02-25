import 'package:flutter/material.dart';

class TestOverviewScreen extends StatelessWidget {
  const TestOverviewScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    const totalMinutes = 165;
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;

    final sections = <SectionEntry>[
      SectionEntry(
        keyName: "listening",
        title: "Listening",
        desc: "Four sections with increasing difficulty",
        durationLabel: "30 min",
        bg: const Color(0xFFECFDF3),
        ring: const Color(0xFFBBF7D0),
        icon: Icons.headset_mic,
      ),
      SectionEntry(
        keyName: "reading",
        title: "Reading",
        desc: "Three passages with 40 questions",
        durationLabel: "60 min",
        bg: const Color(0xFFFFFBEB),
        ring: const Color(0xFFFEF3C7),
        icon: Icons.menu_book,
      ),
      SectionEntry(
        keyName: "writing",
        title: "Writing",
        desc: "Two writing tasks (Task 1 & Task 2)",
        durationLabel: "60 min",
        bg: const Color(0xFFEFF6FF),
        ring: const Color(0xFFDBEAFE),
        icon: Icons.edit,
      ),
      SectionEntry(
        keyName: "speaking",
        title: "Speaking",
        desc: "Three-part speaking test with AI examiner",
        durationLabel: "11–14 min",
        bg: const Color(0xFFFDF2FF),
        ring: const Color(0xFFFCE7FF),
        icon: Icons.mic,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Back to Tests"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 16,
            vertical: isDesktop ? 28 : 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 14,
                      offset: Offset(0, 8),
                      color: Color(0x14000000),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Smart Test $id",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Complete all four sections to receive your IELTS band score and detailed feedback.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Total Test Duration: ${h}h ${m}m",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Column(
                      children: sections.map((s) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SectionTile(
                            section: s,
                            isDesktop: isDesktop,
                            onStart: () {
                              // ✅ Listening
                              if (s.keyName == "listening") {
                                Navigator.of(context).pushNamed(
                                  "/ielts/test/$id/listening/1",
                                );
                                return;
                              }

                              // ✅ Reading
                              if (s.keyName == "reading") {
                                Navigator.of(context).pushNamed(
                                  "/ielts/test/$id/reading/1",
                                );
                                return;
                              }
                              if (s.keyName == "writing") {
                                Navigator.of(context).pushNamed(
                                  "/ielts/test/$id/writing/1",
                                );
                                return;
                              }
                                if (s.keyName == "speaking") {
                                Navigator.of(context).pushNamed(
                                  "/ielts/test/$id/speaking/1",
                                );
                                return;
                              }


                              // Other sections (later)
                              ScaffoldMessenger.of(context)
                                ..clearSnackBars()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text("${s.title} is not wired yet."),
                                  ),
                                );
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Tip: You can complete the sections in any order. Your progress is saved automatically.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.isDesktop,
    required this.onStart,
  });

  final SectionEntry section;
  final bool isDesktop;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: section.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: section.ring),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBox(icon: section.icon),
                const SizedBox(width: 12),
                Expanded(child: _SectionText(section: section)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _StartButton(onStart: onStart),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: section.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: section.ring),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBox(icon: section.icon),
          const SizedBox(width: 12),
          Expanded(child: _SectionText(section: section)),
          const SizedBox(width: 12),
          SizedBox(width: 260, child: _StartButton(onStart: onStart)),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Icon(icon, size: 20),
    );
  }
}

class _SectionText extends StatelessWidget {
  const _SectionText({required this.section});
  final SectionEntry section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(
          section.desc,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, size: 16, color: Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              section.durationLabel,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onStart,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      child: const Text("Start"),
    );
  }
}

class SectionEntry {
  final String keyName;
  final String title;
  final String desc;
  final String durationLabel;
  final Color bg;
  final Color ring;
  final IconData icon;

  SectionEntry({
    required this.keyName,
    required this.title,
    required this.desc,
    required this.durationLabel,
    required this.bg,
    required this.ring,
    required this.icon,
  });
}
