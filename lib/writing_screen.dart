// lib/writing_screen.dart
import 'package:flutter/material.dart';

class WritingScreen extends StatefulWidget {
  const WritingScreen({
    super.key,
    required this.testId,
    required this.taskNo, // 1 or 2
    this.credits = 0,
  });

  final int testId;
  final int taskNo;
  final int credits;

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  bool openSample = false;
  bool showFeedback = false;
  bool submitted = false;

  late final _MockWritingData data = _mockWriting(widget.testId, widget.taskNo);

  late final TextEditingController essayCtrl;

  int get wordCount => _countWords(essayCtrl.text);
  int get minWords => data.minWords;
  bool get meetsMin => wordCount >= minWords;

  int get score => meetsMin ? 1 : 0; // 0/1 or 1/1 (static)

  @override
  void initState() {
    super.initState();
    essayCtrl = TextEditingController(text: "");
  }

  @override
  void dispose() {
    essayCtrl.dispose();
    super.dispose();
  }

  void submit() {
    setState(() {
      submitted = true;
      showFeedback = true;
    });
  }

  void toggleFeedback() {
    setState(() {
      showFeedback = !showFeedback;
      if (!showFeedback) submitted = false;
    });
  }

  void goTask(int t) {
    Navigator.of(context).pushReplacementNamed(
      "/ielts/test/${widget.testId}/writing/$t",
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
                    _promptCard(context),
                    const SizedBox(height: 12),
                    _sampleCard(context),
                    const SizedBox(height: 12),
                    _answerCard(context),
                    const SizedBox(height: 12),
                    _feedbackCard(context),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomTasksBar(context),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WRITING – TASK ${widget.taskNo}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Smart Test: ${widget.testId}  •  Credits: ${widget.credits}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          _PillToggle(
            on: openSample,
            label: openSample ? "Sample: ON" : "Sample: OFF",
            onTap: () => setState(() => openSample = !openSample),
          ),
        ],
      ),
    );
  }

  // =========================
  // Prompt card
  // =========================
  Widget _promptCard(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              data.timeHint,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
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
                    data.promptTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.promptBody,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Write at least ${data.minWords} words.",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // Sample card (collapsible)
  // =========================
  Widget _sampleCard(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => openSample = !openSample),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  const Text(
                    "Sample Answer",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    openSample ? "▲" : "▼",
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
            crossFadeState: openSample ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                data.sampleAnswer,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            secondChild: const SizedBox(height: 0),
          ),
        ],
      ),
    );
  }

  // =========================
  // Answer card
  // =========================
  Widget _answerCard(BuildContext context) {
    final ok = meetsMin;

    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Your Answer",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ok ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB),
                  width: 1.1,
                ),
              ),
              child: TextField(
                controller: essayCtrl,
                maxLines: 12,
                minLines: 10,
                readOnly: showFeedback,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "Write your response here...",
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "Words: $wordCount / $minWords",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ok ? const Color(0xFFECFDF3) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: ok ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
                    ),
                  ),
                  child: Text(
                    ok ? "Ready" : "Not enough words",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: ok ? const Color(0xFF166534) : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
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
                    onPressed: toggleFeedback,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(color: Color(0xFF16A34A), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    child: Text(showFeedback ? "Hide feedback" : "Check feedback"),
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
                  "Progress: ${score * 100}%  •  Score: $score / 1",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // Feedback card (static)
  // =========================
  Widget _feedbackCard(BuildContext context) {
    final list = data.staticFeedback(essayCtrl.text);

    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Writing Feedback (Static)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _feedbackRow("Minimum words", meetsMin ? "OK" : "Below $minWords"),
                  const SizedBox(height: 8),
                  ...list.map(
                    (x) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        "• $x",
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackRow(String k, String v) {
    return Row(
      children: [
        Text(
          k,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Color(0xFF6B7280),
          ),
        ),
        const Spacer(),
        Text(
          v,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: meetsMin ? const Color(0xFF166534) : const Color(0xFFB91C1C),
          ),
        ),
      ],
    );
  }

  // =========================
  // Bottom tasks bar
  // =========================
  Widget _bottomTasksBar(BuildContext context) {
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
                label: "Writing 1",
                active: widget.taskNo == 1,
                onTap: () => goTask(1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PartPill(
                label: "Writing 2",
                active: widget.taskNo == 2,
                onTap: () => goTask(2),
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

// =========================
// Static models/data
// =========================

int _countWords(String t) {
  final s = t.trim();
  if (s.isEmpty) return 0;
  return s.split(RegExp(r"\s+")).where((x) => x.trim().isNotEmpty).length;
}

class _MockWritingData {
  _MockWritingData({
    required this.timeHint,
    required this.minWords,
    required this.promptTitle,
    required this.promptBody,
    required this.sampleAnswer,
  });

  final String timeHint;
  final int minWords;
  final String promptTitle;
  final String promptBody;
  final String sampleAnswer;

  List<String> staticFeedback(String essay) {
    final txt = essay.trim();
    final notes = <String>[];

    if (txt.isEmpty) {
      notes.add("Write a complete response (introduction + body + conclusion).");
      return notes;
    }

    if (minWords >= 250) {
      if (!RegExp(r"\b(agree|disagree)\b", caseSensitive: false).hasMatch(txt)) {
        notes.add("Make your position clear (agree/disagree).");
      }
      if (!RegExp(r"\b(in conclusion|to conclude|to sum up)\b", caseSensitive: false).hasMatch(txt)) {
        notes.add("Add a clear conclusion.");
      }
      notes.add("Use 2–3 main ideas and support each with an example.");
      notes.add("Check grammar: subject-verb agreement and articles (a/an/the).");
      return notes;
    }

    if (!RegExp(r"\boverall\b", caseSensitive: false).hasMatch(txt)) {
      notes.add("Add an ‘Overall,’ sentence summarising the main trends.");
    }
    notes.add("Mention key comparisons (highest/lowest, increases/decreases).");
    notes.add("Avoid giving opinions; describe data only.");
    notes.add("Use a variety of structures: ‘whereas’, ‘compared to’, ‘in contrast’.");
    return notes;
  }
}

_MockWritingData _mockWriting(int testId, int taskNo) {
  if (taskNo == 2) {
    return _MockWritingData(
      timeHint: "You should spend about 40 minutes on this task.",
      minWords: 250,
      promptTitle: "Some people believe that online learning is as effective as classroom learning.",
      promptBody:
          "To what extent do you agree or disagree?\n\nGive reasons for your answer and include any relevant examples from your own knowledge or experience.",
      sampleAnswer:
          "I strongly agree that online learning can be as effective as traditional classroom education when it is well designed. Firstly, digital platforms provide flexible access to high-quality resources, allowing learners to study at their own pace. For example, recorded lessons enable students to revisit difficult points until they fully understand them.\n\nSecondly, online learning can be highly interactive. Live sessions, discussion boards, and instant feedback tools encourage participation, especially for shy students who may hesitate to speak in class. Additionally, many courses include quizzes and progress tracking, which motivates learners to stay consistent.\n\nHowever, classroom learning still offers benefits such as face-to-face social interaction and immediate support. In my view, the most effective approach is a blended model that combines online convenience with occasional in-person meetings.\n\nIn conclusion, online learning is capable of matching classroom learning in effectiveness, provided that learners have discipline and the course structure promotes engagement.",
    );
  }

  return _MockWritingData(
    timeHint: "You should spend about 20 minutes on this task.",
    minWords: 150,
    promptTitle: "The chart below shows the percentage of people using different transport methods in a city.",
    promptBody:
        "Summarise the information by selecting and reporting the main features, and make comparisons where relevant.",
    sampleAnswer:
        "The chart compares the proportions of residents who used four types of transport in a city over a given period. Overall, private cars accounted for the largest share, while cycling was the least common method.\n\nAt the beginning, car use represented just over half of all journeys, considerably higher than public transport. Bus and train usage together made up roughly a third. Walking remained relatively stable throughout, showing only small fluctuations.\n\nBy the end of the period, reliance on cars declined slightly, whereas public transport saw a moderate increase. In contrast, cycling stayed at a low level despite a minor rise.\n\nIn summary, although cars continued to be the dominant choice, the data suggests a gradual shift towards public transport, with other methods showing limited change.",
  );
}
