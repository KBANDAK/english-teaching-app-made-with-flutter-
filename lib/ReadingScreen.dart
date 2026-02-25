import 'package:flutter/material.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({
    super.key,
    required this.testId,
    required this.passageNo, // 1|2|3
  });

  final String testId;
  final int passageNo;

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  bool showHighlights = true;
  bool showAnswers = false;
  bool submitted = false;

  // answers by question number
  final Map<int, String> answers = {};

  // controllers for inline blanks (to avoid cursor jumping)
  final Map<int, TextEditingController> _controllers = {};

  late ReadingCfg cfg;

  @override
  void initState() {
    super.initState();
    cfg = mockReadingCfg(widget.testId, widget.passageNo);
  }

  @override
  void didUpdateWidget(covariant ReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.testId != widget.testId || oldWidget.passageNo != widget.passageNo) {
      // reset for new passage/test
      submitted = false;
      showAnswers = false;
      showHighlights = true;
      answers.clear();
      _disposeControllers();
      cfg = mockReadingCfg(widget.testId, widget.passageNo);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }

  TextEditingController _ensureController(int no, String text) {
    final existing = _controllers[no];
    if (existing != null) {
      // keep controller in sync when toggling showAnswers
      if (existing.text != text) {
        existing.value = existing.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
          composing: TextRange.empty,
        );
      }
      return existing;
    }
    final c = TextEditingController(text: text);
    _controllers[no] = c;
    return c;
  }

  List<int> get questionNos => cfg.allQuestionNumbers..sort((a, b) => a - b);

  int get totalQuestions => questionNos.length;

  int get answeredCount {
    int c = 0;
    for (final no in questionNos) {
      final v = (answers[no] ?? "").trim();
      if (v.isNotEmpty) c++;
    }
    return c;
  }

  int get score {
    if (!submitted) return 0;
    int s = 0;
    for (final no in questionNos) {
      final user = normLower(answers[no]);
      final correct = normLower(cfg.correctAnswers[no]);
      if (user.isNotEmpty && correct.isNotEmpty && user == correct) s++;
    }
    return s;
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

  void goPassage(int p) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReadingScreen(testId: widget.testId, passageNo: p),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 900;

    final bg = const Color(0xFFEAF2FF);
    final cardBg = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "READING – PASSAGE ${widget.passageNo}",
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => showHighlights = !showHighlights),
            icon: Icon(
              Icons.circle,
              size: 10,
              color: showHighlights ? const Color(0xFF10B981) : const Color(0xFFCBD5F5),
            ),
            label: Text(
              showHighlights ? "Highlights: ON" : "Highlights: OFF",
              style: const TextStyle(color: Color(0xFF111827)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 18 : 12, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _Card(color: cardBg, child: _buildPassage())),
                        const SizedBox(width: 14),
                        Expanded(flex: 5, child: _buildRightPanel(cardBg)),
                      ],
                    )
                  : DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          _Card(
                            color: cardBg,
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: TabBar(
                                      indicator: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(999),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10,
                                            offset: const Offset(0, 6),
                                            color: Colors.black.withValues(alpha: 0.08),
                                          )
                                        ],
                                      ),
                                      labelColor: const Color(0xFF111827),
                                      unselectedLabelColor: const Color(0xFF6B7280),
                                      dividerColor: Colors.transparent,
                                      tabs: const [
                                        Tab(text: "Passage"),
                                        Tab(text: "Questions"),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _Card(color: cardBg, child: _buildPassage(scrollable: true)),
                                _buildRightPanel(cardBg, scrollable: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _NavPill(
              label: "Passage 1",
              active: widget.passageNo == 1,
              onTap: () => goPassage(1),
            ),
            _NavPill(
              label: "Passage 2",
              active: widget.passageNo == 2,
              onTap: () => goPassage(2),
            ),
            _NavPill(
              label: "Passage 3",
              active: widget.passageNo == 3,
              onTap: () => goPassage(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel(Color cardBg, {bool scrollable = false}) {
    final body = _Card(
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cfg.questionHeader,
              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 6),
            Text(
              cfg.questionSubHeader,
              style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),

            // Questions blocks
            ..._buildQuestionBlocks(),

            const SizedBox(height: 10),
            _statsAndActions(),
          ],
        ),
      ),
    );

    if (!scrollable) return body;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: body,
    );
  }

  List<Widget> _buildQuestionBlocks() {
    final blocks = <Widget>[];

    for (final block in cfg.blocks) {
      blocks.add(_BlockCard(
        title: block.title,
        child: _buildBlock(block),
      ));
      blocks.add(const SizedBox(height: 12));
    }

    if (blocks.isNotEmpty) blocks.removeLast();
    return blocks;
  }

  Widget _buildBlock(ReadingBlock block) {
    switch (block.kind) {
      case ReadingBlockKind.tfng:
        return _TFNGBlock(
          items: block.tfItems,
          getValue: (no) => answers[no] ?? "",
          onChange: (no, v) {
            if (showAnswers) return;
            setState(() => answers[no] = v);
          },
          showAnswers: showAnswers,
          correctAnswers: cfg.correctAnswers,
          submitted: submitted,
        );

      case ReadingBlockKind.notesInline:
        return _InlineNotesBlock(
          title: block.inlineTitle,
          lines: block.inlineLines,
          showAnswers: showAnswers,
          submitted: submitted,
          correctAnswers: cfg.correctAnswers,
          getUser: (no) => answers[no] ?? "",
          onChange: (no, v) {
            if (showAnswers) return;
            setState(() => answers[no] = v);
          },
          ensureController: _ensureController,
        );

      case ReadingBlockKind.select:
        return _SelectBlock(
          items: block.selectItems,
          options: block.selectOptions,
          showAnswers: showAnswers,
          submitted: submitted,
          correctAnswers: cfg.correctAnswers,
          getValue: (no) => answers[no] ?? "",
          onChange: (no, v) {
            if (showAnswers) return;
            setState(() => answers[no] = v);
          },
        );

      case ReadingBlockKind.summaryInline:
        return _InlineNotesBlock(
          title: block.inlineTitle,
          lines: block.inlineLines,
          showAnswers: showAnswers,
          submitted: submitted,
          correctAnswers: cfg.correctAnswers,
          getUser: (no) => answers[no] ?? "",
          onChange: (no, v) {
            if (showAnswers) return;
            setState(() => answers[no] = v);
          },
          ensureController: _ensureController,
        );

      case ReadingBlockKind.mcq4:
        return _MCQ4Block(
          items: block.mcqItems,
          showAnswers: showAnswers,
          submitted: submitted,
          correctAnswers: cfg.correctAnswers,
          getValue: (no) => answers[no] ?? "",
          onChange: (no, v) {
            if (showAnswers) return;
            setState(() => answers[no] = v);
          },
        );
    }
  }

  Widget _statsAndActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Answered: $answeredCount / $totalQuestions",
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        if (submitted) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF93C5FD)),
            ),
            child: Text(
              "Score: $score / $totalQuestions",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  side: const BorderSide(color: Color(0xFF16A34A)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(showAnswers ? "Hide answers" : "Check answers"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPassage({bool scrollable = false}) {
    final content = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cfg.passageLabel,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          if (cfg.introText.isNotEmpty)
            Text(
              cfg.introText,
              style: const TextStyle(fontSize: 12, height: 1.35, color: Color(0xFF6B7280)),
            ),
          const SizedBox(height: 12),
          if (cfg.passageTitle.isNotEmpty)
            Center(
              child: Text(
                cfg.passageTitle,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          if (cfg.passageSubtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                cfg.passageSubtitle,
                style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (cfg.footnote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              cfg.footnote,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
          const SizedBox(height: 12),

          // Body paragraphs with marks [[n]]
          ...cfg.passageParagraphs.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MarkedParagraph(
                text: p,
                showHighlights: showHighlights,
              ),
            );
          }),
        ],
      ),
    );

    if (!scrollable) return content;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: content,
    );
  }
}

/* =========================
   Small UI widgets
========================= */

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.color});
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.08),
          )
        ],
      ),
      child: child,
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
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
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF6B7280),
        side: const BorderSide(color: Color(0xFF9CA3AF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      child: Text(label),
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MarkedParagraph extends StatelessWidget {
  const _MarkedParagraph({required this.text, required this.showHighlights});
  final String text;
  final bool showHighlights;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\[\[(\d+)\]\]');
    int last = 0;

    for (final m in regex.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      final n = m.group(1) ?? "";
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: showHighlights
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                  ),
                  child: Text(
                    "[$n]",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                )
              : Text("[$n]", style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ),
      ));
      last = m.end;
    }

    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF111827)),
        children: spans,
      ),
    );
  }
}

/* =========================
   Blocks
========================= */

class _TFNGBlock extends StatelessWidget {
  const _TFNGBlock({
    required this.items,
    required this.getValue,
    required this.onChange,
    required this.showAnswers,
    required this.correctAnswers,
    required this.submitted,
  });

  final List<TFItem> items;
  final String Function(int no) getValue;
  final void Function(int no, String v) onChange;
  final bool showAnswers;
  final Map<int, String> correctAnswers;
  final bool submitted;

  @override
  Widget build(BuildContext context) {
    const options = ["TRUE", "FALSE", "NOT GIVEN"];

    return Column(
      children: items.map((q) {
        final user = toUpperTrim(getValue(q.no));
        final correct = toUpperTrim(correctAnswers[q.no]);
        final ok = submitted && user.isNotEmpty && user == correct;
        final wrong = submitted && user.isNotEmpty && correct.isNotEmpty && user != correct;

        final border = ok
            ? const Color(0xFF22C55E)
            : wrong
                ? const Color(0xFFEF4444)
                : const Color(0xFFE5E7EB);

        final bg = ok
            ? const Color(0xFFECFDF3)
            : wrong
                ? const Color(0xFFFEE2E2)
                : Colors.white;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${q.no}. ${q.text}", style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: options.map((opt) {
                  final checked = showAnswers ? opt == correct : opt == user;

                  return ChoiceChip(
                    label: Text(opt, style: const TextStyle(fontSize: 12)),
                    selected: checked,
                    onSelected: showAnswers ? null : (_) => onChange(q.no, opt),
                    selectedColor: const Color(0xFFE0F2FE),
                    side: BorderSide(color: checked ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB)),
                  );
                }).toList(),
              ),
              if (showAnswers) ...[
                const SizedBox(height: 6),
                Text(
                  "Correct: $correct",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w800),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SelectBlock extends StatelessWidget {
  const _SelectBlock({
    required this.items,
    required this.options,
    required this.showAnswers,
    required this.submitted,
    required this.correctAnswers,
    required this.getValue,
    required this.onChange,
  });

  final List<SelectItem> items;
  final List<String> options;
  final bool showAnswers;
  final bool submitted;
  final Map<int, String> correctAnswers;
  final String Function(int no) getValue;
  final void Function(int no, String v) onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((q) {
        final user = toUpperTrim(getValue(q.no));
        final correct = toUpperTrim(correctAnswers[q.no]);
        final ok = submitted && user.isNotEmpty && user == correct;
        final wrong = submitted && user.isNotEmpty && correct.isNotEmpty && user != correct;

        final border = showAnswers
            ? const Color(0xFF22C55E)
            : ok
                ? const Color(0xFF22C55E)
                : wrong
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFE5E7EB);

        final bg = showAnswers
            ? const Color(0xFFECFDF3)
            : ok
                ? const Color(0xFFECFDF3)
                : wrong
                    ? const Color(0xFFFEE2E2)
                    : Colors.white;

        final display = showAnswers ? correct : user;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${q.no}. ${q.text}", style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: display.isEmpty ? null : display,
                items: [
                  const DropdownMenuItem(value: null, child: Text("Choose…")),
                  ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
                ],
                onChanged: showAnswers ? null : (v) => onChange(q.no, toUpperTrim(v)),
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: showAnswers ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB)),
                  ),
                ),
              ),
              if (showAnswers) ...[
                const SizedBox(height: 6),
                Text(
                  "Correct: $correct",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w800),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MCQ4Block extends StatelessWidget {
  const _MCQ4Block({
    required this.items,
    required this.showAnswers,
    required this.submitted,
    required this.correctAnswers,
    required this.getValue,
    required this.onChange,
  });

  final List<MCQ4Item> items;
  final bool showAnswers;
  final bool submitted;
  final Map<int, String> correctAnswers;
  final String Function(int no) getValue;
  final void Function(int no, String v) onChange;

  @override
  Widget build(BuildContext context) {
    const letters = ["A", "B", "C", "D"];

    return Column(
      children: items.map((q) {
        final user = toUpperTrim(getValue(q.no));
        final correct = toUpperTrim(correctAnswers[q.no]);

        final ok = submitted && user.isNotEmpty && user == correct;
        final wrong = submitted && user.isNotEmpty && correct.isNotEmpty && user != correct;

        final border = showAnswers
            ? const Color(0xFF22C55E)
            : ok
                ? const Color(0xFF22C55E)
                : wrong
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFE5E7EB);

        final bg = showAnswers
            ? const Color(0xFFECFDF3)
            : ok
                ? const Color(0xFFECFDF3)
                : wrong
                    ? const Color(0xFFFEE2E2)
                    : Colors.white;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${q.no}. ${q.text}", style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...List.generate(4, (idx) {
                final L = letters[idx];
                final opt = q.options.length > idx ? q.options[idx] : "";

                return InkWell(
                  onTap: showAnswers ? null : () => onChange(q.no, L),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: L,
                          groupValue: showAnswers ? correct : user,
                          onChanged: showAnswers ? null : (v) => onChange(q.no, v ?? ""),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "$L. $opt",
                            style: const TextStyle(height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (showAnswers) ...[
                const SizedBox(height: 6),
                Text(
                  "Correct: $correct",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w800),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InlineNotesBlock extends StatelessWidget {
  const _InlineNotesBlock({
    required this.title,
    required this.lines,
    required this.showAnswers,
    required this.submitted,
    required this.correctAnswers,
    required this.getUser,
    required this.onChange,
    required this.ensureController,
  });

  final String title;
  final List<InlineLine> lines;
  final bool showAnswers;
  final bool submitted;
  final Map<int, String> correctAnswers;

  final String Function(int no) getUser;
  final void Function(int no, String v) onChange;

  final TextEditingController Function(int no, String text) ensureController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
        ],
        ...lines.map((line) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _InlinePartsRow(
              parts: line.parts,
              showAnswers: showAnswers,
              submitted: submitted,
              correctAnswers: correctAnswers,
              getUser: getUser,
              onChange: onChange,
              ensureController: ensureController,
            ),
          );
        }),
      ],
    );
  }
}

class _InlinePartsRow extends StatelessWidget {
  const _InlinePartsRow({
    required this.parts,
    required this.showAnswers,
    required this.submitted,
    required this.correctAnswers,
    required this.getUser,
    required this.onChange,
    required this.ensureController,
  });

  final List<InlinePart> parts;
  final bool showAnswers;
  final bool submitted;
  final Map<int, String> correctAnswers;

  final String Function(int no) getUser;
  final void Function(int no, String v) onChange;
  final TextEditingController Function(int no, String text) ensureController;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      spacing: 6,
      children: [
        ...parts.map((p) {
          if (p.kind == InlinePartKind.text) {
            return Text(p.text, style: const TextStyle(height: 1.35));
          }

          final no = p.qNo!;
          final user = getUser(no);
          final correct = correctAnswers[no] ?? "";
          final display = showAnswers ? correct : user;

          final isOk = submitted && normLower(user) == normLower(correct) && user.trim().isNotEmpty;
          final isWrong = submitted && user.trim().isNotEmpty && correct.trim().isNotEmpty && !isOk;

          final borderColor = showAnswers
              ? const Color(0xFF22C55E)
              : isOk
                  ? const Color(0xFF22C55E)
                  : isWrong
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFD1D5DB);

          final fill = showAnswers ? const Color(0xFFECFDF3) : Colors.white;

          return SizedBox(
            width: 150,
            child: TextField(
              controller: ensureController(no, display),
              readOnly: showAnswers,
              onChanged: (v) => onChange(no, v),
              decoration: InputDecoration(
                isDense: true,
                hintText: "($no)",
                filled: true,
                fillColor: fill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: showAnswers ? const Color(0xFF22C55E) : const Color(0xFF3B82F6),
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: showAnswers ? FontWeight.w900 : FontWeight.w600,
                color: showAnswers ? const Color(0xFF166534) : const Color(0xFF111827),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/* =========================
   Data models + Mock data
========================= */

enum ReadingBlockKind { tfng, notesInline, select, summaryInline, mcq4 }

class ReadingCfg {
  ReadingCfg({
    required this.passageLabel,
    required this.introText,
    required this.passageTitle,
    required this.passageSubtitle,
    required this.footnote,
    required this.passageParagraphs,
    required this.blocks,
    required this.correctAnswers,
    required this.questionHeader,
    required this.questionSubHeader,
  });

  final String passageLabel;
  final String introText;
  final String passageTitle;
  final String passageSubtitle;
  final String footnote;

  final List<String> passageParagraphs;

  final List<ReadingBlock> blocks;

  // correct answers by question no
  final Map<int, String> correctAnswers;

  final String questionHeader;
  final String questionSubHeader;

  List<int> get allQuestionNumbers {
    final set = <int>{};
    for (final b in blocks) {
      set.addAll(b.questionNumbers);
    }
    return set.toList();
  }
}

class ReadingBlock {
  ReadingBlock({
    required this.kind,
    required this.title,
    this.tfItems = const [],
    this.inlineTitle = "",
    this.inlineLines = const [],
    this.selectItems = const [],
    this.selectOptions = const [],
    this.mcqItems = const [],
  });

  final ReadingBlockKind kind;
  final String title;

  // TFNG
  final List<TFItem> tfItems;

  // Inline
  final String inlineTitle;
  final List<InlineLine> inlineLines;

  // Select
  final List<SelectItem> selectItems;
  final List<String> selectOptions;

  // MCQ4
  final List<MCQ4Item> mcqItems;

  List<int> get questionNumbers {
    final set = <int>{};
    if (kind == ReadingBlockKind.tfng) {
      for (final q in tfItems) {
        set.add(q.no);
      }
    }
    if (kind == ReadingBlockKind.select) {
      for (final q in selectItems) {
        set.add(q.no);
      }
    }
    if (kind == ReadingBlockKind.mcq4) {
      for (final q in mcqItems) {
        set.add(q.no);
      }
    }
    if (kind == ReadingBlockKind.notesInline || kind == ReadingBlockKind.summaryInline) {
      for (final line in inlineLines) {
        for (final p in line.parts) {
          if (p.kind == InlinePartKind.blank && p.qNo != null) set.add(p.qNo!);
        }
      }
    }
    return set.toList();
  }
}

class TFItem {
  TFItem({required this.no, required this.text});
  final int no;
  final String text;
}

class SelectItem {
  SelectItem({required this.no, required this.text});
  final int no;
  final String text;
}

class MCQ4Item {
  MCQ4Item({required this.no, required this.text, required this.options});
  final int no;
  final String text;
  final List<String> options;
}

class InlineLine {
  InlineLine({required this.parts});
  final List<InlinePart> parts;
}

enum InlinePartKind { text, blank }

class InlinePart {
  InlinePart.text(this.text)
      : kind = InlinePartKind.text,
        qNo = null;

  InlinePart.blank(this.qNo)
      : kind = InlinePartKind.blank,
        text = "";

  final InlinePartKind kind;
  final String text;
  final int? qNo;
}

/* =========================
   Helpers
========================= */

String toUpperTrim(dynamic v) => (v ?? "").toString().trim().toUpperCase();
String normLower(dynamic v) => (v ?? "").toString().trim().toLowerCase();

/* =========================
   Static mock configs
========================= */

ReadingCfg mockReadingCfg(String testId, int passageNo) {
  if (passageNo == 1) {
    final correct = <int, String>{
      1: "TRUE",
      2: "FALSE",
      3: "NOT GIVEN",
      4: "TRUE",
      5: "library",
      6: "two",
      7: "Friday",
      8: "12",
    };

    return ReadingCfg(
      passageLabel: "PASSAGE 1",
      introText: "You should spend about 20 minutes on Questions 1–8, which are based on Passage 1 below.",
      passageTitle: "A Small Town Library Project",
      passageSubtitle: "An example passage with [[numbers]] marks",
      footnote: "",
      passageParagraphs: [
        "The town council approved a plan to expand the public library in 2018 [[1]]. The project aimed to improve access to learning resources for all residents.",
        "A new reading hall was designed to hold community events [[2]]. The architects proposed quiet zones and group-study areas.",
        "Funding was collected from local donors and a small municipal grant [[3]]. Construction started in early spring.",
        "After completion, the library increased membership significantly [[4]].",
      ],
      questionHeader: "Questions 1–8",
      questionSubHeader: "Answer the questions below. For 1–4 choose TRUE/FALSE/NOT GIVEN. For 5–8 write ONE WORD AND/OR A NUMBER.",
      correctAnswers: correct,
      blocks: [
        ReadingBlock(
          kind: ReadingBlockKind.tfng,
          title: "TRUE / FALSE / NOT GIVEN",
          tfItems: [
            TFItem(no: 1, text: "The library expansion plan was approved in 2018."),
            TFItem(no: 2, text: "The new reading hall was designed only for children."),
            TFItem(no: 3, text: "The project was funded entirely by the national government."),
            TFItem(no: 4, text: "Library membership increased after the project finished."),
          ],
        ),
        ReadingBlock(
          kind: ReadingBlockKind.notesInline,
          title: "NOTES (Questions 5–8)",
          inlineTitle: "Project Notes",
          inlineLines: [
            InlineLine(parts: [
              InlinePart.text("The main study area is located in the "),
              InlinePart.blank(5),
              InlinePart.text("."),
            ]),
            InlineLine(parts: [
              InlinePart.text("The building has "),
              InlinePart.blank(6),
              InlinePart.text(" quiet zones."),
            ]),
            InlineLine(parts: [
              InlinePart.text("Community events are usually held on "),
              InlinePart.blank(7),
              InlinePart.text("."),
            ]),
            InlineLine(parts: [
              InlinePart.text("The reading hall can hold up to "),
              InlinePart.blank(8),
              InlinePart.text(" people."),
            ]),
          ],
        ),
      ],
    );
  }

  if (passageNo == 2) {
    final correct = <int, String>{
      9: "B",
      10: "D",
      11: "A",
      12: "C",
      13: "A",
      14: "C",
      15: "digital",
      16: "energy",
      17: "2020",
    };

    return ReadingCfg(
      passageLabel: "PASSAGE 2",
      introText: "You should spend about 20 minutes on Questions 9–17, which are based on Passage 2 below.",
      passageTitle: "Urban Farming Innovations",
      passageSubtitle: "",
      footnote: "",
      passageParagraphs: [
        "Section A [[5]]: Urban farming has grown rapidly due to limited land and rising food demand.",
        "Section B [[6]]: Vertical farms use stacked layers and controlled environments to maximise yield.",
        "Section C [[7]]: Hydroponic systems reduce water usage and can be installed in dense cities.",
        "Section D [[8]]: Some projects integrate renewable energy and automation to reduce costs.",
      ],
      questionHeader: "Questions 9–17",
      questionSubHeader: "For 9–14 choose the correct section (A–D). For 15–17 complete the summary with ONE WORD.",
      correctAnswers: correct,
      blocks: [
        ReadingBlock(
          kind: ReadingBlockKind.select,
          title: "Match statements to sections (9–14)",
          selectOptions: const ["A", "B", "C", "D"],
          selectItems: [
            SelectItem(no: 9, text: "Mentions stacked layers to increase production."),
            SelectItem(no: 10, text: "Discusses reducing costs with automation."),
            SelectItem(no: 11, text: "Focuses on rapid growth due to demand and limited land."),
            SelectItem(no: 12, text: "Highlights systems that reduce water use in cities."),
            SelectItem(no: 13, text: "Describes challenges of land availability."),
            SelectItem(no: 14, text: "Refers to renewable energy integration."),
          ],
        ),
        ReadingBlock(
          kind: ReadingBlockKind.summaryInline,
          title: "SUMMARY (15–17)",
          inlineTitle: "Summary",
          inlineLines: [
            InlineLine(parts: [
              InlinePart.text("Modern urban farms often rely on "),
              InlinePart.blank(15),
              InlinePart.text(" monitoring to control conditions."),
            ]),
            InlineLine(parts: [
              InlinePart.text("Some sites use renewable "),
              InlinePart.blank(16),
              InlinePart.text(" to reduce long-term operating costs."),
            ]),
            InlineLine(parts: [
              InlinePart.text("Several large-scale projects expanded after "),
              InlinePart.blank(17),
              InlinePart.text("."),
            ]),
          ],
        ),
      ],
    );
  }

  // passage 3
  final correct = <int, String>{
    18: "B",
    19: "D",
    20: "A",
    21: "C",
    22: "B",
    23: "A",
  };

  return ReadingCfg(
    passageLabel: "PASSAGE 3",
    introText: "You should spend about 20 minutes on Questions 18–23, which are based on Passage 3 below.",
    passageTitle: "Decision Making Under Pressure",
    passageSubtitle: "",
    footnote: "",
    passageParagraphs: [
      "In high-stakes environments, individuals often rely on heuristics [[9]]: mental shortcuts that simplify complex decisions.",
      "While heuristics can be efficient, they may also introduce systematic errors [[10]]. Training and feedback can reduce these errors over time.",
      "Research suggests that time pressure changes attention allocation [[11]]. People focus on key cues and ignore less relevant information.",
    ],
    questionHeader: "Questions 18–23",
    questionSubHeader: "Choose the correct letter A–D.",
    correctAnswers: correct,
    blocks: [
      ReadingBlock(
        kind: ReadingBlockKind.mcq4,
        title: "Multiple Choice (18–23)",
        mcqItems: [
          MCQ4Item(
            no: 18,
            text: "Heuristics are best described as:",
            options: const [
              "Detailed calculations used in long decisions",
              "Mental shortcuts that simplify decisions",
              "Random guessing strategies",
              "Rules applied only by experts",
            ],
          ),
          MCQ4Item(
            no: 19,
            text: "A main risk of heuristics is that they:",
            options: const [
              "Always take too long",
              "Eliminate the need for training",
              "Guarantee correct outcomes",
              "May cause systematic errors",
            ],
          ),
          MCQ4Item(
            no: 20,
            text: "Time pressure mainly affects decision making by:",
            options: const [
              "Changing attention allocation",
              "Preventing any cue usage",
              "Removing uncertainty",
              "Increasing memory capacity",
            ],
          ),
          MCQ4Item(
            no: 21,
            text: "Training and feedback can:",
            options: const [
              "Make heuristics slower",
              "Stop decisions entirely",
              "Reduce errors over time",
              "Increase systematic bias",
            ],
          ),
          MCQ4Item(
            no: 22,
            text: "Under pressure, people tend to:",
            options: const [
              "Attend equally to all information",
              "Focus on key cues",
              "Ignore all cues",
              "Avoid decisions completely",
            ],
          ),
          MCQ4Item(
            no: 23,
            text: "The passage suggests heuristics are:",
            options: const [
              "Efficient but imperfect",
              "Always harmful",
              "Only useful without time pressure",
              "Unrelated to attention",
            ],
          ),
        ],
      ),
    ],
  );
}
