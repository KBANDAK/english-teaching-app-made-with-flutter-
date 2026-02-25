import 'package:flutter/material.dart';

/// =======================================================
/// IELTS PREP (STATIC)  ->  EXAM SCREEN (STATIC) DEMO
/// هدفه: تدخل على امتحان ويظهر UI حسب موضوعه (qType)
/// =======================================================

class IeltsPrepDemoScreen extends StatefulWidget {
  const IeltsPrepDemoScreen({
    super.key,
    this.insideShell = false,
  });

  static const routeName = "/ielts-prep-demo";

  /// ✅ إذا الصفحة داخل AppShell (تبويب): لا نعرض Scaffold/AppBar/SafeArea
  final bool insideShell;

  @override
  State<IeltsPrepDemoScreen> createState() => _IeltsPrepScreenState();
}

class _IeltsPrepScreenState extends State<IeltsPrepDemoScreen> {
  // نفس tabs عندك تقريباً
  static const List<String> allTabs = [
    "Vocabulary",
    "Grammar",
    "Writing",
    "Listening",
    "Speaking",
    "Reading",
  ];

  String activeTab = "Vocabulary";

  static const Map<String, String> cefrLevels = {
    "A1": "Beginner",
    "A2": "Elementary",
    "B1": "Intermediate",
    "B2": "Upper-Intermediate",
    "C1": "Advanced",
    "C2": "Proficiency",
  };

  String selectedLevel = "C1";

  String get levelLabel {
    final name = cefrLevels[selectedLevel] ?? "Advanced";
    return "$selectedLevel: $name";
  }

  // topics dummy (تظهر كـ cards مثل صفحة StartLearning)
  late final List<_Topic> topics = List.generate(
    15,
    (i) => _Topic(
      id: i,
      title: [
        "Travel",
        "Education",
        "Technology",
        "Health",
        "Family",
        "Sports",
        "Food",
        "Work",
        "Environment",
        "Culture",
        "Hobbies",
        "Shopping",
        "Movies",
        "Music",
        "Future Plans",
      ][i % 15],
      icon: _iconArray[i % _iconArray.length],
    ),
  );

  final Map<int, bool> checked = {};

  bool get allChecked =>
      topics.isNotEmpty && topics.every((t) => checked[t.id] == true);

  void toggleAll(bool val) {
    setState(() {
      for (final t in topics) {
        checked[t.id] = val;
      }
    });
  }

  List<_Topic> get selectedTopics =>
      topics.where((t) => checked[t.id] == true).toList();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    // ✅ محتوى الصفحة الحقيقي (كان داخل body سابقاً)
    final pageContent = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1220),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== HERO =====
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFDFEAF6)),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(73, 176, 231, 0.10),
                      Color.fromRGBO(106, 60, 243, 0.09),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 14,
                      offset: Offset(0, 10),
                      color: Color(0x14000000),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        const Text(
                          "?? Start Learning",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF315B8A),
                            fontSize: 16,
                          ),
                        ),
                        PopupMenuButton<String>(
                          initialValue: selectedLevel,
                          tooltip: "Change level",
                          onSelected: (value) =>
                              setState(() => selectedLevel = value),
                          itemBuilder: (context) => cefrLevels.entries
                              .map(
                                (e) => CheckedPopupMenuItem<String>(
                                  value: e.key,
                                  checked: e.key == selectedLevel,
                                  child: Text("${e.key}: ${e.value}"),
                                ),
                              )
                              .toList(),
                          child: _Pill(
                            text: levelLabel,
                            bg: const Color(0xFFEEF5FF),
                            border: const Color(0xFFDBE8FF),
                            fg: const Color(0xFF225FA9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "English Learning Platform",
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 40,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Static demo now. Later we connect to backend.",
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tabs = موضوع الامتحان (qType)
                    _TabsRow(
                      tabs: allTabs,
                      active: activeTab,
                      onChange: (t) => setState(() => activeTab = t),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ===== Section head =====
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Topics",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: allChecked,
                        onChanged: (v) => toggleAll(v ?? false),
                        activeColor: const Color(0xFF2F7EE5),
                      ),
                      const Text(
                        "Select All",
                        style: TextStyle(
                          color: Color(0xFF2E4A69),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ===== Grid topics =====
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  int crossAxisCount;
                  if (w >= 1200) {
                    crossAxisCount = 5;
                  } else if (w >= 900) {
                    crossAxisCount = 4;
                  } else if (w >= 680) {
                    crossAxisCount = 3;
                  } else {
                    crossAxisCount = 2;
                  }

                  return GridView.builder(
                    itemCount: topics.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isMobile ? 1.20 : 1.45,
                    ),
                    itemBuilder: (context, i) {
                      final t = topics[i];
                      final isChecked = checked[t.id] == true;

                      return _TopicCard(
                        topic: t,
                        checked: isChecked,
                        onToggle: () {
                          setState(() {
                            checked[t.id] = !isChecked;
                          });
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 18),

              // ===== Actions =====
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _GradientButton(
                    text: "Generate Exam",
                    icon: Icons.play_arrow,
                    onTap: () {
                      if (selectedTopics.isEmpty) {
                        _toast(context, "Select at least one topic.");
                        return;
                      }

                      final qType = _mapTabToQType(activeTab);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExamScreenStatic(
                            qType: qType,
                            selectedTopicTitles:
                                selectedTopics.map((e) => e.title).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  _OutlineButton(
                    text: "Choose AI Assistant",
                    onTap: () => _toast(context, "TODO"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Tip: Select multiple topics to create a customized practice exam.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // ✅ داخل الـ AppShell: لا Scaffold ولا AppBar ولا SafeArea (حتى لا تكبر الناف فوق)
    if (widget.insideShell) {
      return Material(
        color: Colors.white,
        child: pageContent,
      );
    }

    // ✅ إذا فتحتها كصفحة مستقلة عبر route
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("IELTS Prep (Static)"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(child: pageContent),
    );
  }

  QType _mapTabToQType(String tab) {
    switch (tab) {
      case "Listening":
        return QType.listening;
      case "Reading":
        return QType.reading;
      case "Speaking":
        return QType.speaking;
      case "Writing":
        return QType.writing;
      case "Grammar":
        return QType.grammar;
      case "Vocabulary":
      default:
        return QType.vocabulary;
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// =======================================================
/// EXAM SCREEN (STATIC) - UI changes by qType
/// =======================================================
class ExamScreenStatic extends StatefulWidget {
  const ExamScreenStatic({
    super.key,
    required this.qType,
    required this.selectedTopicTitles,
  });

  final QType qType;
  final List<String> selectedTopicTitles;

  @override
  State<ExamScreenStatic> createState() => _ExamScreenStaticState();
}

class _ExamScreenStaticState extends State<ExamScreenStatic> {
  late final List<Question> questions = _staticQuestionsFor(widget.qType);

  int currentIndex = 0;
  int? selectedChoiceIndex;
  String writingText = "";
  bool isRecording = false;
  bool finished = false;

  Question get currentQuestion => questions[currentIndex];

  void _resetPerQuestionState() {
    selectedChoiceIndex = null;
    writingText = "";
    isRecording = false;
  }

  void _next() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        _resetPerQuestionState();
      });
    } else {
      setState(() => finished = true);
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _resetPerQuestionState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return _FinishStatic(
        qType: widget.qType,
        topics: widget.selectedTopicTitles,
      );
    }

    final q = currentQuestion;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Exam • ${widget.qType.label}"),
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
              qType: q.qType,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ✅ factory يبدّل UI حسب نوع السؤال
                      QuestionFactory(
                        question: q,
                        selectedChoiceIndex: selectedChoiceIndex,
                        onSelectChoice: (idx) =>
                            setState(() => selectedChoiceIndex = idx),
                        writingText: writingText,
                        onWritingChanged: (v) => setState(() => writingText = v),
                        isRecording: isRecording,
                        onToggleRecording: () =>
                            setState(() => isRecording = !isRecording),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: currentIndex == 0 ? null : _prev,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text("Previous"),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GradientButton(
                              text: currentIndex == questions.length - 1
                                  ? "Finish"
                                  : "Next",
                              icon: currentIndex == questions.length - 1
                                  ? Icons.flag
                                  : Icons.arrow_forward,
                              onTap: _next,
                            ),
                          ),
                        ],
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

  List<Question> _staticQuestionsFor(QType type) {
    // كل نوع يرجع أسئلة ثابتة “مطابقة” لواجهته
    switch (type) {
      case QType.listening:
        return [
          Question(
            id: "l1",
            qType: QType.listening,
            title: "Listening",
            prompt: "Listen (demo) and answer:",
            audioUrl: "https://example.com/audio.mp3",
            choices: const [
              "The speaker agrees",
              "The speaker disagrees",
              "The speaker is neutral",
              "Not mentioned",
            ],
          ),
          Question(
            id: "l2",
            qType: QType.listening,
            title: "Listening",
            prompt: "What is the main topic?",
            audioUrl: "https://example.com/audio2.mp3",
            choices: const [
              "Travel",
              "Health",
              "Technology",
              "Education",
            ],
          ),
        ];

      case QType.reading:
        return [
          Question(
            id: "r1",
            qType: QType.reading,
            title: "Reading Passage",
            passage:
                "Short daily walks may reduce stress and improve concentration. "
                "The effect is stronger when combined with good sleep and nutrition.",
            prompt: "According to the passage, daily walks can:",
            choices: const [
              "Increase stress",
              "Reduce stress & improve concentration",
              "Replace sleep",
              "Make food unnecessary",
            ],
          ),
          Question(
            id: "r2",
            qType: QType.reading,
            title: "Reading",
            passage:
                "Online learning has expanded access to education worldwide. "
                "However, it can increase screen time and requires self-discipline.",
            prompt: "A challenge of online learning is:",
            choices: const [
              "It is always free",
              "It reduces access",
              "It may require self-discipline",
              "It eliminates screen time",
            ],
          ),
        ];

      case QType.speaking:
        return [
          Question(
            id: "s1",
            qType: QType.speaking,
            title: "Speaking",
            prompt:
                "Describe a time you helped someone.\n- Who you helped\n- What you did\n- How you felt",
            speakingSeconds: 60,
          ),
          Question(
            id: "s2",
            qType: QType.speaking,
            title: "Speaking",
            prompt:
                "Talk about your favorite hobby.\n- What it is\n- How often you do it\n- Why you enjoy it",
            speakingSeconds: 45,
          ),
        ];

      case QType.writing:
        return [
          Question(
            id: "w1",
            qType: QType.writing,
            title: "Writing Task",
            prompt:
                "Some people think students should wear uniforms. "
                "To what extent do you agree or disagree? (150+ words)",
            writingMinWords: 150,
          ),
        ];

      case QType.grammar:
        return [
          Question(
            id: "g1",
            qType: QType.grammar,
            title: "Grammar",
            prompt: "Choose the correct sentence:",
            choices: const [
              "She don’t like coffee.",
              "She doesn’t likes coffee.",
              "She doesn’t like coffee.",
              "She didn’t likes coffee.",
            ],
          ),
          Question(
            id: "g2",
            qType: QType.grammar,
            title: "Grammar",
            prompt: "Choose the correct option:",
            choices: const [
              "If I will see him, I tell him.",
              "If I see him, I will tell him.",
              "If I saw him, I tell him.",
              "If I see him, I told him.",
            ],
          ),
        ];

      case QType.vocabulary:
      return [
          Question(
            id: "v1",
            qType: QType.vocabulary,
            title: "Vocabulary",
            prompt: "The word “ubiquitous” most nearly means:",
            choices: const ["Rare", "Everywhere", "Uncertain", "Dangerous"],
          ),
          Question(
            id: "v2",
            qType: QType.vocabulary,
            title: "Vocabulary",
            prompt: "The word “meticulous” most nearly means:",
            choices: const [
              "Careless",
              "Very careful",
              "Very fast",
              "Very loud",
            ],
          ),
        ];
    }
  }
}

/// =======================================================
/// QuestionFactory (switch by qType)
/// =======================================================
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
      return _MCQQuestion(
          question: question,
          selectedChoiceIndex: selectedChoiceIndex,
          onSelectChoice: onSelectChoice,
        );
    }
  }
}

/// =======================================================
/// Per-type Widgets
/// =======================================================
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
          return _ChoiceTile(
            text: question.choices[i],
            selected: selectedChoiceIndex == i,
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
        const Text("Passage",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDFEAF6)),
          ),
          child: Text(question.passage ?? "", style: const TextStyle(height: 1.35)),
        ),
        const SizedBox(height: 14),
        _PromptBlock(prompt: question.prompt ?? ""),
        const SizedBox(height: 12),
        ...List.generate(question.choices.length, (i) {
          return _ChoiceTile(
            text: question.choices[i],
            selected: selectedChoiceIndex == i,
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
                  "Audio Player (UI فقط) — سيتم ربطه لاحقاً",
                  style: TextStyle(fontWeight: FontWeight.w900),
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
          return _ChoiceTile(
            text: question.choices[i],
            selected: selectedChoiceIndex == i,
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
          "Note: UI فقط. لاحقاً نربط Recorder + رفع الصوت + AI.",
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
    final count = _countWords(text);

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
              text: "Words: $count",
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
    final t = s.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r"\s+")).length;
  }
}

/// =======================================================
/// Small UI components
/// =======================================================
class _ExamHeader extends StatelessWidget {
  const _ExamHeader({
    required this.title,
    required this.current,
    required this.total,
    required this.qType,
  });

  final String title;
  final int current;
  final int total;
  final QType qType;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: const Color(0xFF21486F),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
      child: Text(text),
    );
  }
}

class _TabsRow extends StatelessWidget {
  const _TabsRow({
    required this.tabs,
    required this.active,
    required this.onChange,
  });

  final List<String> tabs;
  final String active;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final t = tabs[i];
          final isActive = t == active;

          return InkWell(
            onTap: () => onChange(t),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.black : Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 3,
                  width: isActive ? 28 : 0,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF2F7EE5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

/// =======================================================
/// Topic Card (fixed overflow)
/// =======================================================
class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.checked,
    required this.onToggle,
  });

  final _Topic topic;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final border = checked ? const Color(0xFF2F7EE5) : const Color(0xFFDDE7F6);
    final bg = checked ? const Color(0xFFEAF2FF) : Colors.white;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 6),
                color: Color(0x10000000),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFFEEF5FF),
                      border: Border.all(color: const Color(0x22000000)),
                    ),
                    child: Icon(topic.icon, color: const Color(0xFF2F7EE5)),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: checked,
                      onChanged: (_) => onToggle(),
                      activeColor: const Color(0xFF2F7EE5),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Text(
                    topic.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Color(0xFF21486F),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Tap to select",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// Finish (static)
/// =======================================================
class _FinishStatic extends StatelessWidget {
  const _FinishStatic({required this.qType, required this.topics});
  final QType qType;
  final List<String> topics;

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
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFDFEAF6)),
              color: const Color(0xFFEEF5FF),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 46),
                const SizedBox(height: 12),
                Text(
                  "Finished • ${qType.label}",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "Topics:\n• ${topics.join("\n• ")}",
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

/// =======================================================
/// Models
/// =======================================================
enum QType { vocabulary, grammar, reading, listening, speaking, writing }

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
    }
  }
}

class Question {
  final String id;
  final QType qType;

  final String? title;
  final String? prompt;

  final String? passage; // reading
  final String? audioUrl; // listening (later)

  final List<String> choices; // mcq/reading/listening

  final int? speakingSeconds;
  final int? writingMinWords;

  Question({
    required this.id,
    required this.qType,
    this.title,
    this.prompt,
    this.passage,
    this.audioUrl,
    this.choices = const [],
    this.speakingSeconds,
    this.writingMinWords,
  });
}

class _Topic {
  final int id;
  final String title;
  final IconData icon;
  const _Topic({required this.id, required this.title, required this.icon});
}

const List<IconData> _iconArray = [
  Icons.menu_book,
  Icons.campaign,
  Icons.tune,
  Icons.palette,
  Icons.anchor,
  Icons.star_border,
  Icons.science,
  Icons.public,
  Icons.auto_awesome,
  Icons.music_note,
  Icons.sports_basketball,
  Icons.cloud,
  Icons.bubble_chart,
  Icons.code,
  Icons.hub,
];
