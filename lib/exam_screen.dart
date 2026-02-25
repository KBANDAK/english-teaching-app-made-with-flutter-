import 'package:flutter/material.dart';

/// =============================
/// ExamScreen (UI + Factory)
/// =============================
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  static const routeName = "/exam";

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  // ====== Demo questions (replace later by API fetch) ======
  late final List<Question> questions = [
    Question(
      id: "q1",
      qType: QType.vocabulary,
      title: "Choose the correct meaning",
      prompt: "The word “ubiquitous” most nearly means:",
      choices: const [
        "Rare",
        "Everywhere",
        "Uncertain",
        "Dangerous",
      ],
      correctIndex: 1,
    ),
    Question(
      id: "q2",
      qType: QType.grammar,
      title: "Grammar",
      prompt: "Choose the correct sentence:",
      choices: const [
        "She don’t like coffee.",
        "She doesn’t likes coffee.",
        "She doesn’t like coffee.",
        "She didn’t likes coffee.",
      ],
      correctIndex: 2,
    ),
    Question(
      id: "q3",
      qType: QType.reading,
      title: "Reading Passage",
      passage:
          "Many people believe that regular exercise improves mental health. "
          "Recent studies suggest that even short daily walks can reduce stress levels "
          "and improve concentration. The effect seems stronger when combined with "
          "adequate sleep and healthy nutrition.",
      prompt: "According to the passage, short daily walks can:",
      choices: const [
        "Increase stress levels",
        "Reduce stress and improve concentration",
        "Replace the need for sleep",
        "Make nutrition unnecessary",
      ],
      correctIndex: 1,
    ),
    Question(
      id: "q4",
      qType: QType.listening,
      title: "Listening",
      prompt: "Listen to the audio and answer the question:",
      // لاحقاً ستربطه بـ audioUrl من الباك
      audioUrl: "https://example.com/audio.mp3",
      choices: const [
        "The speaker agrees completely",
        "The speaker partially agrees",
        "The speaker disagrees",
        "The speaker is unsure",
      ],
      correctIndex: 2,
    ),
    Question(
      id: "q5",
      qType: QType.speaking,
      title: "Speaking",
      prompt:
          "Describe a time you helped someone. You should say:\n- Who you helped\n- What you did\n- How you felt",
      speakingSeconds: 60,
    ),
    Question(
      id: "q6",
      qType: QType.writing,
      title: "Writing",
      prompt:
          "Some people think students should wear uniforms at school. To what extent do you agree or disagree? Write at least 150 words.",
      writingMinWords: 150,
    ),
  ];

  int currentIndex = 0;

  // common answer state (simple demo)
  int? selectedChoiceIndex; // for MCQ/Reading/Listening/Vocab/Grammar
  String writingText = "";
  bool isRecording = false; // demo
  bool finished = false;

  Question get currentQuestion => questions[currentIndex];

  double get progress =>
      questions.isEmpty ? 0 : ((currentIndex + 1) / questions.length);

  // Called when question changes
  void _resetPerQuestionState() {
    selectedChoiceIndex = null;
    writingText = "";
    isRecording = false;
  }

  void _goNext() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        _resetPerQuestionState();
      });
    }
  }

  void _goPrev() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _resetPerQuestionState();
      });
    }
  }

  void _finish() {
    setState(() => finished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return const _FinishScreen();
    }

    final q = currentQuestion;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Exam"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ExamHeader(
              title: q.title ?? "Question",
              current: currentIndex + 1,
              total: questions.length,
              progress: progress,
              qType: q.qType,
            ),

            // content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // QuestionFactory: يبدّل الواجهة حسب النوع
                      QuestionFactory(
                        question: q,
                        selectedChoiceIndex: selectedChoiceIndex,
                        onSelectChoice: (idx) {
                          setState(() => selectedChoiceIndex = idx);
                        },
                        writingText: writingText,
                        onWritingChanged: (v) {
                          setState(() => writingText = v);
                        },
                        isRecording: isRecording,
                        onToggleRecording: () {
                          setState(() => isRecording = !isRecording);
                        },
                      ),

                      const SizedBox(height: 14),

                      _ExamButtons(
                        canPrev: currentIndex > 0,
                        canNext: currentIndex < questions.length - 1,
                        onPrev: _goPrev,
                        onNext: _goNext,
                        onFinish: _finish,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =============================
/// QuestionFactory (Core switch)
/// =============================
class QuestionFactory extends StatelessWidget {
  const QuestionFactory({
    super.key,
    required this.question,
    required this.selectedChoiceIndex,
    required this.onSelectChoice,
    required this.writingText,
    required this.onWritingChanged,
    required this.isRecording,
    required this.onToggleRecording,
  });

  final Question question;

  final int? selectedChoiceIndex;
  final ValueChanged<int> onSelectChoice;

  final String writingText;
  final ValueChanged<String> onWritingChanged;

  final bool isRecording;
  final VoidCallback onToggleRecording;

  @override
  Widget build(BuildContext context) {
    switch (question.qType) {
      case QType.listening:
        return _ListeningQuestion(
          question: question,
          selectedChoiceIndex: selectedChoiceIndex,
          onSelectChoice: onSelectChoice,
        );

      case QType.reading:
        return _ReadingQuestion(
          question: question,
          selectedChoiceIndex: selectedChoiceIndex,
          onSelectChoice: onSelectChoice,
        );

      case QType.speaking:
        return _SpeakingQuestion(
          question: question,
          isRecording: isRecording,
          onToggleRecording: onToggleRecording,
        );

      case QType.writing:
        return _WritingQuestion(
          question: question,
          text: writingText,
          onChanged: onWritingChanged,
        );

      case QType.grammar:
      case QType.vocabulary:
      case QType.mcq:
      return _MCQQuestion(
          question: question,
          selectedChoiceIndex: selectedChoiceIndex,
          onSelectChoice: onSelectChoice,
        );
    }
  }
}

/// =============================
/// Header + Buttons + Shell
/// =============================
class _ExamHeader extends StatelessWidget {
  const _ExamHeader({
    required this.title,
    required this.current,
    required this.total,
    required this.progress,
    required this.qType,
  });

  final String title;
  final int current;
  final int total;
  final double progress;
  final QType qType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _Pill(
                text: qType.label,
                bg: const Color(0xFFEEF5FF),
                border: const Color(0xFFDBE8FF),
                fg: const Color(0xFF225FA9),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // progress row
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFEFF2F7),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "$current / $total",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExamButtons extends StatelessWidget {
  const _ExamButtons({
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    required this.onFinish,
  });

  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: canPrev ? onPrev : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text("Previous"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: canNext
              ? _GradientButton(
                  text: "Next",
                  icon: Icons.arrow_forward,
                  onTap: onNext,
                )
              : _GradientButton(
                  text: "Finish",
                  icon: Icons.flag,
                  onTap: onFinish,
                ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDFEAF6)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 10),
            color: Color(0x14000000),
          )
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(73, 176, 231, 0.10),
            Color.fromRGBO(106, 60, 243, 0.09),
          ],
        ),
        color: Colors.white,
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.bg,
    required this.border,
    required this.fg,
  });

  final String text;
  final Color bg;
  final Color border;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF49B0E7), Color(0xFF6A3CF3), Color(0xFF7C3AED)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

/// =============================
/// Question Widgets (per type)
/// =============================
class _MCQQuestion extends StatelessWidget {
  const _MCQQuestion({
    required this.question,
    required this.selectedChoiceIndex,
    required this.onSelectChoice,
  });

  final Question question;
  final int? selectedChoiceIndex;
  final ValueChanged<int> onSelectChoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PromptBlock(prompt: question.prompt ?? ""),
        const SizedBox(height: 12),
        ...List.generate(question.choices.length, (i) {
          final text = question.choices[i];
          final selected = selectedChoiceIndex == i;
          return _ChoiceTile(
            text: text,
            selected: selected,
            onTap: () => onSelectChoice(i),
          );
        }),
      ],
    );
  }
}

class _ReadingQuestion extends StatelessWidget {
  const _ReadingQuestion({
    required this.question,
    required this.selectedChoiceIndex,
    required this.onSelectChoice,
  });

  final Question question;
  final int? selectedChoiceIndex;
  final ValueChanged<int> onSelectChoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Passage",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDFEAF6)),
          ),
          child: Text(
            question.passage ?? "",
            style: const TextStyle(height: 1.35),
          ),
        ),
        const SizedBox(height: 14),
        _PromptBlock(prompt: question.prompt ?? ""),
        const SizedBox(height: 12),
        ...List.generate(question.choices.length, (i) {
          final text = question.choices[i];
          final selected = selectedChoiceIndex == i;
          return _ChoiceTile(
            text: text,
            selected: selected,
            onTap: () => onSelectChoice(i),
          );
        }),
      ],
    );
  }
}

class _ListeningQuestion extends StatelessWidget {
  const _ListeningQuestion({
    required this.question,
    required this.selectedChoiceIndex,
    required this.onSelectChoice,
  });

  final Question question;
  final int? selectedChoiceIndex;
  final ValueChanged<int> onSelectChoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Audio placeholder card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF5FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBE8FF)),
          ),
          child: Row(
            children: [
              const Icon(Icons.headphones, color: Color(0xFF225FA9)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Audio Player (UI فقط) — سيتم ربطه لاحقاً بـ audioUrl",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Play (demo)")),
                  );
                },
                child: const Text("Play"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _PromptBlock(prompt: question.prompt ?? ""),
        const SizedBox(height: 12),
        ...List.generate(question.choices.length, (i) {
          final text = question.choices[i];
          final selected = selectedChoiceIndex == i;
          return _ChoiceTile(
            text: text,
            selected: selected,
            onTap: () => onSelectChoice(i),
          );
        }),
      ],
    );
  }
}

class _SpeakingQuestion extends StatelessWidget {
  const _SpeakingQuestion({
    required this.question,
    required this.isRecording,
    required this.onToggleRecording,
  });

  final Question question;
  final bool isRecording;
  final VoidCallback onToggleRecording;

  @override
  Widget build(BuildContext context) {
    final secs = question.speakingSeconds ?? 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PromptBlock(prompt: question.prompt ?? ""),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDFEAF6)),
          ),
          child: Row(
            children: [
              Icon(
                isRecording ? Icons.mic : Icons.mic_none,
                color: isRecording ? Colors.red : Colors.black87,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isRecording
                      ? "Recording… ($secs s max) (demo)"
                      : "Tap to start recording ($secs s max) (demo)",
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              _GradientButton(
                text: isRecording ? "Stop" : "Record",
                icon: isRecording ? Icons.stop : Icons.fiber_manual_record,
                onTap: onToggleRecording,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Note: هذا UI فقط. لاحقاً نربط Recorder حقيقي + رفع الصوت + AI Feedback.",
          style: TextStyle(
            color: Color(0xFF667085),
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }
}

class _WritingQuestion extends StatelessWidget {
  const _WritingQuestion({
    required this.question,
    required this.text,
    required this.onChanged,
  });

  final Question question;
  final String text;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final minWords = question.writingMinWords ?? 150;
    final wordCount = _countWords(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PromptBlock(prompt: question.prompt ?? ""),
        const SizedBox(height: 12),
        Row(
          children: [
            _Pill(
              text: "Min: $minWords words",
              bg: const Color(0xFFFFF3E0),
              border: const Color(0xFFFFE0B2),
              fg: const Color(0xFF8A4B00),
            ),
            const SizedBox(width: 10),
            _Pill(
              text: "Words: $wordCount",
              bg: const Color(0xFFE8F5E9),
              border: const Color(0xFFC8E6C9),
              fg: const Color(0xFF1B5E20),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          minLines: 8,
          maxLines: 14,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: "Write your answer here…",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFDFEAF6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFDFEAF6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6A3CF3)),
            ),
          ),
        ),
      ],
    );
  }

  int _countWords(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r"\s+")).length;
  }
}

class _PromptBlock extends StatelessWidget {
  const _PromptBlock({required this.prompt});
  final String prompt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDFEAF6)),
      ),
      child: Text(
        prompt,
        style: const TextStyle(
          fontSize: 15,
          height: 1.35,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected ? const Color(0xFF2F7EE5) : const Color(0xFFDFEAF6);
    final bg = selected ? const Color(0xFFEAF2FF) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: border, width: 2),
                    color: selected ? const Color(0xFF2F7EE5) : Colors.white,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =============================
/// Finish screen (demo)
/// =============================
class _FinishScreen extends StatelessWidget {
  const _FinishScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Finished"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFDFEAF6)),
              color: const Color(0xFFEEF5FF),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, size: 46),
                SizedBox(height: 12),
                Text(
                  "Session Finished (UI فقط)",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                SizedBox(height: 6),
                Text(
                  "لاحقاً نعرض النتيجة من الباك (Score/Accuracy/Details).",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =============================
/// Models
/// =============================
enum QType { vocabulary, grammar, reading, listening, speaking, writing, mcq }

extension QTypeLabel on QType {
  String get label {
    switch (this) {
      case QType.vocabulary:
        return "Vocabulary";
      case QType.grammar:
        return "Grammar";
      case QType.reading:
        return "Reading";
      case QType.listening:
        return "Listening";
      case QType.speaking:
        return "Speaking";
      case QType.writing:
        return "Writing";
      case QType.mcq:
        return "MCQ";
    }
  }
}

class Question {
  final String id;
  final QType qType;

  final String? title;

  /// main prompt
  final String? prompt;

  /// reading passage
  final String? passage;

  /// listening url (later)
  final String? audioUrl;

  /// MCQ choices
  final List<String> choices;

  /// demo correct answer
  final int? correctIndex;

  /// speaking config
  final int? speakingSeconds;

  /// writing config
  final int? writingMinWords;

  Question({
    required this.id,
    required this.qType,
    this.title,
    this.prompt,
    this.passage,
    this.audioUrl,
    this.choices = const [],
    this.correctIndex,
    this.speakingSeconds,
    this.writingMinWords,
  });
}
