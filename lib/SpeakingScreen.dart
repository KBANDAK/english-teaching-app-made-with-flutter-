// lib/speaking_screen.dart
import 'dart:convert';
import 'dart:typed_data';

import 'dart:io' show File; // used only on non-web platforms
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'core/config/api_config.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({
    super.key,
    required this.testId,
    this.initialPart = 1,
    this.credits = 0,
  });

  final String testId;
  final int initialPart; // 1..3
  final int credits;

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  // =========================
  // AI URL
  // =========================
  static const String _aiUrl = ApiConfig.speakingAiUrl;

  // =========================
  // State
  // =========================
  late int activePart;
  int currentIdx = 0;

  // idle|reading|readyRecord|recording|answered|finished
  String phase = "idle";
  bool recording = false;

  // AI state
  String aiStatus = "idle"; // idle|loading|done|error
  String? aiError;

  late final _MockSpeakingData data = _mockSpeaking(widget.testId);

  late final List<List<String?>> answers; // filePath on mobile, "web-bytes" on web
  late final List<List<_AIFeedback?>> aiFeedback;

  // =========================
  // TTS
  // =========================
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  bool _isSpeaking = false;

  // =========================
  // Recorder
  // =========================
  final AudioRecorder _recorder = AudioRecorder();
  Uint8List? _webAudioBytes;

  @override
  void initState() {
    super.initState();

    activePart = (widget.initialPart < 1 || widget.initialPart > 3) ? 1 : widget.initialPart;

    final flats = _buildPartFlats();
    answers = List.generate(3, (p) => List.filled(flats[p].length, null));
    aiFeedback = List.generate(3, (p) => List.filled(flats[p].length, null));

    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = true);
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
        if (phase == "reading") phase = "readyRecord";
      });
    });

    _tts.setCancelHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _tts.setErrorHandler((msg) {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
        phase = "idle";
      });
    });

    _ttsReady = true;
  }

  Future<void> _stopTts() async {
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _isSpeaking = false;
      if (phase == "reading") phase = "idle";
    });
  }

  Future<void> _speakText(String text) async {
    if (!_ttsReady) return;
    await _tts.stop();
    if (!mounted) return;
    setState(() => phase = "reading");
    await _tts.speak(text);
  }

  Future<void> _speakCurrentQuestion() async {
    final q = activeFlat[currentIdx];

    // Part 2 cue card: اقرأه بشكل مرتب
    if (partIndex == 1 && q.meta is _CueCardMeta) {
      final m = q.meta as _CueCardMeta;
      final lines = <String>[];

      if (m.taskText.trim().isNotEmpty) lines.add(m.taskText.trim());
      if (m.youTitle.trim().isNotEmpty) lines.add(m.youTitle.trim());
      for (final l in m.youLines) {
        if (l.trim().isNotEmpty) lines.add(l.trim());
      }

      final merged = lines.join(". ");
      await _speakText(merged);
      return;
    }

    await _speakText(q.text);
  }

  @override
  void dispose() {
    _tts.stop();
    _recorder.dispose();
    super.dispose();
  }

  // =========================
  // Derived
  // =========================
  int get partIndex => activePart - 1;

  _SpeakingPart get activePartCfg => data.parts[partIndex];

  List<List<_FlatQ>> _buildPartFlats() {
    final parts = data.parts;

    List<_FlatQ> flatNormal(_SpeakingPart part) {
      final out = <_FlatQ>[];
      int idx = 0;
      for (final sec in part.sections) {
        for (final q in sec.questions) {
          out.add(_FlatQ(section: sec.title, text: q, index: idx));
          idx++;
        }
      }
      return out;
    }

    List<_FlatQ> flatPart2(_SpeakingPart part) {
      _SpeakingSection? findSec(String keyword) {
        for (final s in part.sections) {
          if (s.title.toLowerCase().contains(keyword)) return s;
        }
        return null;
      }

      final taskSec = findSec("task card") ?? part.sections.first;
      final youSec = findSec("you should say");
      final extraSec = findSec("extra prompts");

      final taskText = taskSec.questions.isNotEmpty ? taskSec.questions.first : "";
      final youLines = youSec?.questions ?? <String>[];

      final flat = <_FlatQ>[];

      flat.add(
        _FlatQ(
          section: part.title,
          text: (taskText + (youLines.isNotEmpty ? " ${youLines.join(" ")}" : "")).trim(),
          index: 0,
          meta: _CueCardMeta(
            taskText: taskText,
            youTitle: youSec?.title ?? "You should say",
            youLines: youLines,
          ),
        ),
      );

      if (extraSec != null) {
        for (int i = 0; i < extraSec.questions.length; i++) {
          flat.add(
            _FlatQ(
              section: extraSec.title,
              text: extraSec.questions[i],
              index: flat.length,
              meta: _ExtraPromptMeta(subIndex: i),
            ),
          );
        }
      }

      while (flat.length < 3) {
        flat.add(_FlatQ(section: "Extra prompts", text: "—", index: flat.length));
      }

      return flat;
    }

    return [
      flatNormal(parts[0]),
      flatPart2(parts[1]),
      flatNormal(parts[2]),
    ];
  }

  List<_FlatQ> get activeFlat => _buildPartFlats()[partIndex];

  int get totalQuestions => activeFlat.length;
  bool get isLastQuestion => currentIdx == totalQuestions - 1;

  String? get currentAnswer => answers[partIndex][currentIdx];
  _AIFeedback? get currentAI => aiFeedback[partIndex][currentIdx];

  // =========================
  // Navigation
  // =========================
  void _goPart(int p) {
    _stopTts();
    Navigator.of(context).pushReplacementNamed("/ielts/test/${widget.testId}/speaking/$p");
  }

  // =========================
  // Recording (Web + Mobile)
  // =========================
  Future<void> _startRecording() async {
    if (recording) return;

    await _stopTts();

    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission is required.")),
      );
      return;
    }

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );

    if (kIsWeb) {
      // Web: DO NOT pass path
      await _recorder.start(config, path: '');
    } else {
      final dir = await getTemporaryDirectory();
      final path = "${dir.path}/speaking_${widget.testId}_p$activePart_q$currentIdx.m4a";
      await _recorder.start(config, path: path);
    }

    if (!mounted) return;
    setState(() {
      recording = true;
      phase = "recording";
      aiStatus = "idle";
      aiError = null;
    });
  }

  Future<void> _stopRecording() async {
    if (!recording) return;

    final q = activeFlat[currentIdx];

    if (kIsWeb) {
      final Uint8List? bytes = (await _recorder.stop()) as Uint8List?;
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        setState(() {
          recording = false;
          phase = "idle";
        });
        return;
      }
      _webAudioBytes = bytes;
      answers[partIndex][currentIdx] = "web-bytes";
    } else {
      final String? path = await _recorder.stop();
      if (path == null || path.trim().isEmpty) {
        if (!mounted) return;
        setState(() {
          recording = false;
          phase = "idle";
        });
        return;
      }
      answers[partIndex][currentIdx] = path;
    }

    if (!mounted) return;
    setState(() {
      recording = false;
      phase = isLastQuestion ? "finished" : "answered";
      aiStatus = "loading";
      aiError = null;
    });

    if (kIsWeb) {
      await _evaluateWithAIWebBytes(
        bytes: _webAudioBytes!,
        part: activePart,
        partIndex: partIndex,
        questionIndex: currentIdx,
        questionText: q.text, part_q: null,
      );
    } else {
      await _evaluateWithAIFile(
        filePath: answers[partIndex][currentIdx]!,
        part: activePart,
        partIndex: partIndex,
        questionIndex: currentIdx,
        questionText: q.text,
      );
    }
  }

  // =========================
  // AI Multipart (File)
  // =========================
  Future<void> _evaluateWithAIFile({
    required String filePath,
    required int part,
    required int partIndex,
    required int questionIndex,
    required String questionText,
  }) async {
    try {
      final f = File(filePath);
      final exists = await f.exists();
      if (!exists) throw Exception("Recorded file not found: $filePath");

      final req = http.MultipartRequest("POST", Uri.parse(_aiUrl));
      req.fields["testId"] = widget.testId;
      req.fields["part"] = part.toString();
      req.fields["questionIndex"] = questionIndex.toString();
      req.fields["questionText"] = questionText;

      req.files.add(await http.MultipartFile.fromPath("audio", filePath));

      await _handleAIResponse(req, partIndex, questionIndex);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        aiStatus = "error";
        aiError = e.toString();
      });
    }
  }

  // =========================
  // AI Multipart (Web Bytes)
  // =========================
  Future<void> _evaluateWithAIWebBytes({
    required Uint8List bytes,
    required int part,
    required int partIndex,
    required int questionIndex,
    required String questionText,
    required dynamic part_q,
  }) async {
    try {
      final req = http.MultipartRequest("POST", Uri.parse(_aiUrl));
      req.fields["testId"] = widget.testId;
      req.fields["part"] = part.toString();
      req.fields["questionIndex"] = questionIndex.toString();
      req.fields["questionText"] = questionText;

      req.files.add(
        http.MultipartFile.fromBytes(
          "audio",
          bytes,
          filename: "speaking_${widget.testId}_p$part_q$questionIndex.m4a",
        ),
      );

      await _handleAIResponse(req, partIndex, questionIndex);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        aiStatus = "error";
        aiError = e.toString();
      });
    }
  }

  // =========================
  // Handle AI response (shared)
  // =========================
  Future<void> _handleAIResponse(
    http.MultipartRequest req,
    int partIndex,
    int questionIndex,
  ) async {
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception(body.isNotEmpty ? body : "HTTP ${streamed.statusCode}");
    }

    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid AI response format.");
    }

    final Map<String, dynamic> aiData = decoded;

    final transcript = (aiData["transcript"] ?? aiData["text"] ?? aiData["answer"] ?? "").toString();
    final bandVal = aiData["band"] ?? aiData["score"];
    final String? band = bandVal == null ? null : bandVal.toString();

    String comment = (aiData["comment"] ?? aiData["feedback"] ?? "").toString();
    String suggestions = (aiData["suggestions"] ?? aiData["tips"] ?? "").toString();

    final msg = aiData["message"];
    if (msg is Map && msg["content"] is String) {
      final content = (msg["content"] as String).trim();
      const marker = "Improvement suggestion:";
      final idx = content.indexOf(marker);
      if (idx != -1) {
        final main = content.substring(0, idx).trim();
        final sugg = content.substring(idx + marker.length).trim();
        if (comment.isEmpty) comment = main;
        if (suggestions.isEmpty) suggestions = sugg;
      } else {
        if (comment.isEmpty) comment = content;
      }
    }

    final feedback = _AIFeedback(
      transcript: transcript,
      band: band,
      comment: comment.isEmpty ? "—" : comment,
      suggestions: suggestions,
    );

    if (!mounted) return;
    setState(() {
      aiFeedback[partIndex][questionIndex] = feedback;
      aiStatus = "done";
      aiError = null;
    });

    final chunks = <String>[];
    if (feedback.band != null) chunks.add("Estimated band: ${feedback.band}.");
    if (feedback.comment.trim().isNotEmpty && feedback.comment.trim() != "Incorrect.") {
      chunks.add("Comment: ${feedback.comment}");
    }
    if (feedback.suggestions.trim().isNotEmpty) {
      chunks.add("Suggestions: ${feedback.suggestions}");
    }

    final speakText = chunks.join(" ");
    if (speakText.trim().isNotEmpty) {
      await _speakText(speakText);
    }
  }

  void _next() {
    if (currentIdx < totalQuestions - 1) {
      _stopTts();
      setState(() {
        currentIdx += 1;
        phase = "idle";
        aiStatus = "idle";
        aiError = null;
      });
    }
  }

  // =========================
  // THEME
  // =========================
  static const _bg = Colors.white;
  static const _text = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _link = Color(0xFF2563EB);
  static const _purple = Color(0xFF6D28D9);
  static const _border = Color(0xFFE5E7EB);
  static const _soft = Color(0xFFF3F4F6);
  static const _danger = Color(0xFFEF4444);
  
  get activePart_q => null;

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final q = activeFlat[currentIdx];
    final topicTitle = _topicTitleForPart(activePartCfg);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topTitles(),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  topicTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _sectionsBlockMobile(),
              const SizedBox(height: 18),
              _controlsBlockMobile(q),
              const SizedBox(height: 18),
              _bottomNavPills(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PART $activePart",
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: _text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          activePartCfg.description,
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.35,
            color: _muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "EXAMPLE",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: _text,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _sectionsBlockMobile() {
    final sections = activePartCfg.sections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final sec in sections) ...[
          Text(
            sec.title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 8),
          ..._buildSectionQuestions(sec),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  List<Widget> _buildSectionQuestions(_SpeakingSection sec) {
    final out = <Widget>[];

    for (int i = 0; i < sec.questions.length; i++) {
      final txt = sec.questions[i];
      final globalIdx = _findFlatIndexForText(txt);
      final isCurrent = globalIdx == currentIdx;

      out.add(
        GestureDetector(
          onTap: globalIdx == null
              ? null
              : () {
                  _stopTts();
                  setState(() {
                    currentIdx = globalIdx;
                    phase = "idle";
                    aiStatus = "idle";
                    aiError = null;
                  });
                },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              txt,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                color: isCurrent ? _link : _text,
              ),
            ),
          ),
        ),
      );
    }

    return out;
  }

  int? _findFlatIndexForText(String text) {
    for (int i = 0; i < activeFlat.length; i++) {
      if (activeFlat[i].text.trim() == text.trim()) return i;
    }
    for (int i = 0; i < activeFlat.length; i++) {
      if (activeFlat[i].text.contains(text.trim())) return i;
    }
    return null;
  }

  Widget _controlsBlockMobile(_FlatQ q) {
    final canPlay = phase != "reading" && !recording;
    final canRecord =
        phase == "readyRecord" || phase == "idle" || phase == "answered" || phase == "finished";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Question ${currentIdx + 1} of $totalQuestions",
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _muted,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: canPlay ? _speakCurrentQuestion : null,
          child: Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _purple,
              boxShadow: [
                BoxShadow(blurRadius: 18, offset: Offset(0, 10), color: Color(0x22000000)),
              ],
            ),
            child: Icon(
              phase == "reading" ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: (_isSpeaking || phase == "reading") ? _stopTts : null,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: _border),
              boxShadow: const [
                BoxShadow(blurRadius: 10, offset: Offset(0, 6), color: Color(0x14000000)),
              ],
            ),
            child: const Icon(Icons.graphic_eq_rounded, color: _muted, size: 22),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          "1) Click the button to hear the question.\n2) Then record your answer.\n3) AI feedback will cost 1 credit(s) once.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.45,
            color: _muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: !recording ? (canRecord ? _startRecording : null) : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: _link,
            side: const BorderSide(color: _link, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          child: const Text("Start recording"),
        ),
        const SizedBox(height: 10),
        if (recording)
          ElevatedButton(
            onPressed: _stopRecording,
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            child: const Text("Stop recording"),
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Spacer(),
            OutlinedButton(
              onPressed: (_isSpeaking || phase == "reading") ? _stopTts : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: _danger,
                side: const BorderSide(color: _danger, width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
              ),
              child: const Text("Stop AI Voice"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "AI feedback for this question:",
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _soft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _soft),
          ),
          child: Builder(
            builder: (_) {
              if (aiStatus == "loading") {
                return const Text(
                  "AI is responding to your answer…",
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
              if (aiStatus == "error") {
                return Text(
                  "Could not get AI feedback: ${aiError ?? "Unknown error"}",
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: _danger,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }

              final ai = currentAI;
              if (ai == null) {
                return const Text(
                  "Record your answer to receive AI feedback.",
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }

              return Text(
                _feedbackPreview(ai),
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: _muted,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: currentAnswer != null && !recording ? (isLastQuestion ? null : _next) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _link,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              elevation: 0,
            ),
            child: const Text("Next question >"),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            q.text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
        ),
      ],
    );
  }

  String _feedbackPreview(_AIFeedback ai) {
    final b = StringBuffer();
    b.writeln("Estimated band: ${ai.band ?? "–"}");
    if (ai.comment.trim().isNotEmpty) b.writeln(ai.comment.trim());
    if (ai.suggestions.trim().isNotEmpty) b.writeln("\nSuggestions: ${ai.suggestions.trim()}");
    return b.toString().trim();
  }

  Widget _bottomNavPills() {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          _navPill("< Writing", onTap: () {}),
          _circleStep("1", active: activePart == 1, onTap: () => _goPart(1)),
          _circleStep("2", active: activePart == 2, onTap: () => _goPart(2)),
          _circleStep("3", active: activePart == 3, onTap: () => _goPart(3)),
          _navPill("Scores >", onTap: () {}),
        ],
      ),
    );
  }

  Widget _navPill(String text, {required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _muted,
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
      ),
      child: Text(text),
    );
  }

  Widget _circleStep(String text, {required bool active, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? _link : Colors.white,
          border: Border.all(color: active ? _link : _border),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : _muted,
          ),
        ),
      ),
    );
  }

  String _topicTitleForPart(_SpeakingPart part) {
    if (part.sections.isEmpty) return part.title;
    if (part.sections.length == 1) return part.sections.first.title;
    final a = part.sections.first.title;
    final b = part.sections.length > 1 ? part.sections[1].title : "";
    if (b.isEmpty) return a;
    return "$a & $b";
  }
}

// =========================
// Data
// =========================

class _FlatQ {
  _FlatQ({required this.section, required this.text, required this.index, this.meta});
  final String section;
  final String text;
  final int index;
  final Object? meta;
}

class _CueCardMeta {
  _CueCardMeta({required this.taskText, required this.youTitle, required this.youLines});
  final String taskText;
  final String youTitle;
  final List<String> youLines;
}

class _ExtraPromptMeta {
  _ExtraPromptMeta({required this.subIndex});
  final int subIndex;
}

class _AIFeedback {
  _AIFeedback({
    required this.transcript,
    required this.band,
    required this.comment,
    required this.suggestions,
  });
  final String transcript;
  final String? band;
  final String comment;
  final String suggestions;
}

class _SpeakingSection {
  _SpeakingSection({required this.title, required this.questions});
  final String title;
  final List<String> questions;
}

class _SpeakingPart {
  _SpeakingPart({
    required this.title,
    required this.description,
    required this.exampleTitle,
    required this.sections,
  });

  final String title;
  final String description;
  final String exampleTitle;
  final List<_SpeakingSection> sections;
}

class _MockSpeakingData {
  _MockSpeakingData({required this.parts});
  final List<_SpeakingPart> parts;
}

_MockSpeakingData _mockSpeaking(String testId) {
  return _MockSpeakingData(
    parts: [
      _SpeakingPart(
        title: "PART 1",
        description: "The examiner asks you about your hobbies, interests and other everyday topics.",
        exampleTitle: "EXAMPLE",
        sections: [
          _SpeakingSection(
            title: "Free time",
            questions: [
              "How do you usually spend your free time?",
              "Do you prefer to spend your free time alone or with others? [Why?]",
              "Has your idea of a perfect weekend changed over time? [How?]",
              "Is there a new hobby you would like to try in the future?",
            ],
          ),
          _SpeakingSection(
            title: "Reading",
            questions: [
              "Do you like reading? [Why/Why not?]",
              "What kinds of books or texts do you usually read?",
              "Do you prefer reading on paper or on a screen? [Why?]",
              "Did you read a lot when you were a child?",
            ],
          ),
        ],
      ),
      _SpeakingPart(
        title: "PART 2",
        description: "Long turn. You will receive a task card and speak for 1–2 minutes.",
        exampleTitle: "EXAMPLE",
        sections: [
          _SpeakingSection(
            title: "Task card",
            questions: [
              "Describe a time you helped someone.\nYou should say:\n- who you helped\n- what the situation was\n- what you did\nand explain how you felt about it.",
            ],
          ),
          _SpeakingSection(
            title: "You should say",
            questions: ["who you helped", "what the situation was", "what you did", "how you felt"],
          ),
          _SpeakingSection(
            title: "Extra prompts",
            questions: [
              "Why do people help others?",
              "Do you think helping others is more common now than in the past?",
            ],
          ),
        ],
      ),
      _SpeakingPart(
        title: "PART 3",
        description: "Discussion. Answer more abstract questions related to the Part 2 topic.",
        exampleTitle: "EXAMPLE",
        sections: [
          _SpeakingSection(
            title: "Helping in society",
            questions: [
              "How can communities encourage people to help each other?",
              "Should schools teach children to volunteer?",
              "What are the benefits of volunteering for young people?",
            ],
          ),
        ],
      ),
    ],
  );
}
