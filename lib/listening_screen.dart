import 'package:flutter/material.dart';

import 'ielts/data/listening_part1_data.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({
    super.key,
    required this.testId,
    required this.partNo,
    this.credits = 0,
  });

  final String testId;
  final int partNo;
  final int credits;

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  bool audioscriptOn = false;
  bool showAnswers = false;
  bool submitted = false;

  // Demo audio timeline (no external packages)
  double currentSec = 0;
  final double totalSec = 242; // 4:02

  // Static data
  late final _MockListeningData data = _listeningData(widget.testId, widget.partNo);

  // Answers + controllers
  final Map<String, String> ans = {};
  late final Map<String, TextEditingController> ctrls;

  int get totalQuestions => data.allQuestions.length;

  int get answeredCount {
    int c = 0;
    for (final q in data.allQuestions) {
      final v = (ans[q.key] ?? "").trim();
      if (v.isNotEmpty) c++;
    }
    return c;
  }

  int get correctCount {
    int c = 0;
    for (final q in data.allQuestions) {
      final user = (ans[q.key] ?? "").trim().toLowerCase();
      final correct = q.correct.trim().toLowerCase();
      if (user.isNotEmpty && user == correct) c++;
    }
    return c;
  }

  @override
  void initState() {
    super.initState();
    ctrls = {
      for (final q in data.allQuestions)
        q.key: TextEditingController(text: ans[q.key] ?? ""),
    };
  }

  @override
  void dispose() {
    for (final c in ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void submit() {
    setState(() {
      submitted = true;
      showAnswers = true;
    });
  }

  void toggleAnswers() {
    setState(() {
      showAnswers = !showAnswers;
      if (!showAnswers) submitted = false;
    });
  }

  void goPart(int p) {
    // Keep your named route structure
    Navigator.of(context).pushReplacementNamed(
      "/ielts/test/${widget.testId}/listening/$p",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _topHeader(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _audioCard(context),
                    const SizedBox(height: 12),
                    _audioscriptCard(context),
                    const SizedBox(height: 12),
                    _questionsCard(context),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomPartsBar(context),
    );
  }

  // =========================
  // Header
  // =========================
  Widget _topHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "LISTENING – PART ${widget.partNo}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Credits: ${widget.credits}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Right pill toggle
          _PillToggle(
            on: audioscriptOn,
            label: audioscriptOn ? "Audioscript: ON" : "Audioscript: OFF",
            onTap: () => setState(() => audioscriptOn = !audioscriptOn),
          ),
        ],
      ),
    );
  }

  // =========================
  // Audio Card
  // =========================
  Widget _audioCard(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  _IconChip(icon: Icons.play_arrow_rounded, onTap: () {}),
                  const SizedBox(width: 10),
                  Text(
                    "${_fmt(currentSec)} / ${_fmt(totalSec)}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: currentSec.clamp(0, totalSec),
                        min: 0,
                        max: totalSec,
                        onChanged: (v) => setState(() => currentSec = v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconChip(icon: Icons.volume_up_outlined, onTap: () {}),
                  const SizedBox(width: 6),
                  _IconChip(icon: Icons.more_vert, onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  _fmt(currentSec),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "Answered: $answeredCount / $totalQuestions",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // Audioscript Card (collapsible)
  // =========================
  Widget _audioscriptCard(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => audioscriptOn = !audioscriptOn),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  const Text(
                    "Audioscript",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    audioscriptOn ? "▲" : "▼",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: audioscriptOn ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    data.scriptTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...data.script.map((seg) {
                    final active = currentSec >= seg.start && currentSec <= seg.end;
                    return _ScriptBlock(seg: seg, active: active);
                  }),
                ],
              ),
            ),
            secondChild: const SizedBox(height: 0),
          ),
        ],
      ),
    );
  }

  // =========================
  // Questions Card
  // =========================
  Widget _questionsCard(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              data.instructionsTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.instructionsText,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF111827), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    data.paperTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 14),

                  ...data.sections.map(_paperSection),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                          child: const Text("Submit"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: toggleAnswers,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF16A34A),
                            side: const BorderSide(color: Color(0xFF16A34A), width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                          child: Text(showAnswers ? "Hide answers" : "Check answers"),
                        ),
                      ),
                    ],
                  ),

                  if (submitted) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF93C5FD)),
                      ),
                      child: Text(
                        "Your score: $correctCount / $totalQuestions",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paperSection(_PaperSection s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (s.title.isNotEmpty) ...[
            Text(
              s.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (s.subtitle.isNotEmpty) ...[
            Text(
              s.subtitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
          ],
          ...s.questions.map(_paperQuestionRow),
        ],
      ),
    );
  }

  Widget _paperQuestionRow(_Question q) {
    final controller = ctrls[q.key]!;
    final user = (ans[q.key] ?? controller.text).trim();
    final correct = q.correct.trim();

    final ok = user.isNotEmpty && user.toLowerCase() == correct.toLowerCase();
    final empty = user.isEmpty;

    Color border() {
      if (!showAnswers) return const Color(0xFFD1D5DB);
      if (ok) return const Color(0xFF22C55E);
      if (empty) return const Color(0xFF9CA3AF);
      return const Color(0xFFEF4444);
    }

    Color fill() {
      if (!showAnswers) return Colors.white;
      if (ok) return const Color(0xFFECFDF3);
      if (empty) return const Color(0xFFF3F4F6);
      return const Color(0xFFFFF1F2);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              Text(
                "${q.no}. ${q.prefix}",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: controller,
                  readOnly: showAnswers,
                  onChanged: (v) => setState(() => ans[q.key] = v),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "answer",
                    filled: true,
                    fillColor: fill(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: border(), width: 1.1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.3),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: showAnswers ? FontWeight.w900 : FontWeight.w700,
                    color: showAnswers
                        ? (ok
                            ? const Color(0xFF166534)
                            : (empty ? const Color(0xFF374151) : const Color(0xFF991B1B)))
                        : const Color(0xFF111827),
                  ),
                ),
              ),
              if (q.suffix.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  q.suffix,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
          if (showAnswers) ...[
            const SizedBox(height: 6),
            Text(
              ok
                  ? "Correct"
                  : empty
                      ? "No answer • Correct: $correct"
                      : "Incorrect • Correct: $correct",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: ok
                    ? const Color(0xFF166534)
                    : (empty ? const Color(0xFF6B7280) : const Color(0xFFB91C1C)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // =========================
  // Bottom parts bar
  // =========================
  Widget _bottomPartsBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFEAF2FF),
        border: Border(top: BorderSide(color: Color(0xFFD7E3FF))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _PartPill(
                label: "Part 1",
                active: widget.partNo == 1,
                onTap: () => goPart(1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PartPill(
                label: "Part 2",
                active: widget.partNo == 2,
                onTap: () => goPart(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PartPill(
                label: "Part 3",
                active: widget.partNo == 3,
                onTap: () => goPart(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PartPill(
                label: "Part 4",
                active: widget.partNo == 4,
                onTap: () => goPart(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// UI components
// =========================

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          )
        ],
      ),
      child: child,
    );
  }
}

class _PillToggle extends StatelessWidget {
  const _PillToggle({
    required this.on,
    required this.label,
    required this.onTap,
  });

  final bool on;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF111827), width: 0.6),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: on ? const Color(0xFF10B981) : const Color(0xFFCBD5F5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF111827)),
      ),
    );
  }
}

class _PartPill extends StatelessWidget {
  const _PartPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF6B7280),
        side: const BorderSide(color: Color(0xFF9CA3AF)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
      ),
      child: Text(label),
    );
  }
}

class _ScriptBlock extends StatelessWidget {
  const _ScriptBlock({required this.seg, required this.active});
  final _ScriptSeg seg;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? const Color(0x193B82F6) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? const Color(0x403B82F6) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${seg.speaker.toUpperCase()} • ${_fmt(seg.start)}–${_fmt(seg.end)}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            seg.text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// Static data models
// =========================

String _fmt(double s) {
  final x = s.floor();
  final mm = x ~/ 60;
  final ss = x % 60;
  return "$mm:${ss.toString().padLeft(2, "0")}";
}

class _ScriptSeg {
  _ScriptSeg({
    required this.speaker,
    required this.start,
    required this.end,
    required this.text,
  });

  final String speaker;
  final double start;
  final double end;
  final String text;
}

class _Question {
  _Question({
    required this.no,
    required this.key,
    required this.prefix,
    required this.correct,
    this.suffix = "",
  });

  final int no;
  final String key;
  final String prefix;
  final String suffix;
  final String correct;
}

class _PaperSection {
  _PaperSection({
    required this.title,
    required this.subtitle,
    required this.questions,
  });

  final String title;
  final String subtitle;
  final List<_Question> questions;
}

class _MockListeningData {
  _MockListeningData({
    required this.instructionsTitle,
    required this.instructionsText,
    required this.paperTitle,
    required this.scriptTitle,
    required this.script,
    required this.sections,
  });

  final String instructionsTitle;
  final String instructionsText;
  final String paperTitle;

  final String scriptTitle;
  final List<_ScriptSeg> script;

  final List<_PaperSection> sections;

  List<_Question> get allQuestions => sections.expand((s) => s.questions).toList();
}

_MockListeningData _listeningData(String testId, int partNo) {
  if (partNo == 1) {
    final id = int.tryParse(testId) ?? 1;
    final src = listeningPart1Data[id];
    if (src != null) {
      return _fromPart1Data(src);
    }
  }
  return _mockData(testId, partNo);
}

_MockListeningData _fromPart1Data(ListeningTestData src) {
  return _MockListeningData(
    instructionsTitle: src.notes.instructionsTitle,
    instructionsText: src.notes.instructionsText,
    paperTitle: src.notes.boxTitle,
    scriptTitle: src.notes.passageTitle,
    script: src.script
        .map(
          (s) => _ScriptSeg(
            speaker: s.speaker,
            start: s.start,
            end: s.end,
            text: s.text,
          ),
        )
        .toList(),
    sections: src.notes.sections
        .map(
          (section) => _PaperSection(
            title: section.heading,
            subtitle: section.bullets.join("\n"),
            questions: section.questions
                .map(
                  (q) => _Question(
                    no: q.no,
                    key: "q${q.no}",
                    prefix: q.label,
                    suffix: q.trailingText,
                    correct: src.correctAnswers[q.no] ?? "",
                  ),
                )
                .toList(),
          ),
        )
        .toList(),
  );
}

_MockListeningData _mockData(String testId, int partNo) {
  return _MockListeningData(
    instructionsTitle: "Questions 1–10",
    instructionsText:
        "Complete the notes below. Write ONE WORD AND/OR A NUMBER for each answer.",
    paperTitle: "CHOOSING A RESTAURANT FOR A 30TH BIRTHDAY",
    scriptTitle: "Restaurant Recommendations for a Celebration",
    script: [
      _ScriptSeg(
        speaker: "Announcer",
        start: 0,
        end: 20,
        text:
            "Part 1. You will hear a woman asking a friend for restaurant recommendations. First, you have some time to look at questions 1 to 4. Now listen carefully and answer questions 1 to 4.",
      ),
      _ScriptSeg(
        speaker: "Woman",
        start: 20,
        end: 70,
        text:
            "I've been meaning to ask you for some advice about restaurants. I need to book somewhere to celebrate my sister's 30th birthday.",
      ),
      _ScriptSeg(
        speaker: "Man",
        start: 70,
        end: 140,
        text:
            "The Junction? Yeah, I'd definitely recommend that for a special occasion. We had a great time there. Everyone really enjoyed it.",
      ),
    ],
    sections: [
      _PaperSection(
        title: "THE JUNCTION",
        subtitle: "Location: on Greyson Street, a short walk from the station.",
        questions: [
          _Question(
            no: 1,
            key: "q1",
            prefix: "Best for:",
            correct: "seafood",
            suffix: "(type of food, especially good there)",
          ),
          _Question(
            no: 2,
            key: "q2",
            prefix: "Before dinner, customers can have a drink on the",
            correct: "terrace",
            suffix: ".",
          ),
        ],
      ),
      _PaperSection(
        title: "PALOMA",
        subtitle:
            "In a beautiful old building on Bow Street, next to the cinema.\nLess formal atmosphere; friendly staff.",
        questions: [
          _Question(
            no: 3,
            key: "q3",
            prefix: "Type of dishes:",
            correct: "tapas",
            suffix: "(good for groups)",
          ),
          _Question(
            no: 4,
            key: "q4",
            prefix: "Main disadvantage:",
            correct: "prices",
            suffix: "are quite high",
          ),
        ],
      ),
    ],
  );
}
