// lib/widgets/ai_chat.dart
// AI Chatbot Overlay (single file)
// - Web safe (no Tooltip)
// - FAB disappears when chat is open
// - Responsive + SafeArea
// - Text input always enabled (not blocked by TTS)
// - Audio record (WAV 16kHz) + multipart (audio/user_id) + text (user_q/user_id)
// - TTS + stop speaking button
//
// Required deps in pubspec.yaml:
//   http: ^1.2.2
//   http_parser: ^4.0.2
//   flutter_tts: ^4.0.2
//   record: ^5.1.2
//   path_provider: ^2.1.4

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AIChatbotOverlay extends StatefulWidget {
  const AIChatbotOverlay({
    super.key,
    required this.apiUrl,
    required this.userId,
    this.title = "QuickLingo",
    this.initialBotMessage =
        "Hello! I'm QuickLingo from Kassel Academy. You can ask me anything.",
    this.buttonLabel = "AI Chatbot",
    this.buttonRight = 18,
    this.buttonBottom = 18,
  });

  final String apiUrl;
  final String? userId;

  final String title;
  final String initialBotMessage;

  final String buttonLabel;
  final double buttonRight;
  final double buttonBottom;

  @override
  State<AIChatbotOverlay> createState() => _AIChatbotOverlayState();
}

class _AIChatbotOverlayState extends State<AIChatbotOverlay> {
  bool _isOpen = false;

  void _toastLike(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _toggleChat() {
    final uid = widget.userId?.trim() ?? "";
    if (uid.isEmpty) {
      _toastLike("Please login to use this feature");
      return;
    }
    setState(() => _isOpen = !_isOpen);
  }

  @override
  Widget build(BuildContext context) {
    if (_isOpen) {
      return Positioned.fill(
        child: Stack(
          children: [
            // Backdrop (tap outside to close)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _toggleChat,
              child: const SizedBox.expand(),
            ),

            // Chat window anchored bottom-right
            Positioned(
              right: widget.buttonRight,
              bottom: widget.buttonBottom + 52,
              child: _ChatWindow(
                apiUrl: widget.apiUrl,
                userId: (widget.userId ?? "").trim(),
                title: widget.title,
                initialBotMessage: widget.initialBotMessage,
                onClose: _toggleChat,
              ),
            ),
          ],
        ),
      );
    }

    // Closed state: small circular transparent button (icon only)
    return Positioned(
      right: widget.buttonRight,
      bottom: widget.buttonBottom,
      child: FloatingActionButton(
        heroTag: "ai_chat_fab_${widget.title}",
        onPressed: _toggleChat,
        elevation: 0,
        backgroundColor: const Color(0x883B7CE5),
        splashColor: Colors.white24,
        child: const Icon(
          Icons.smart_toy_outlined,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }
}

// =========================
// Chat Window
// =========================

class _ChatWindow extends StatefulWidget {
  const _ChatWindow({
    required this.apiUrl,
    required this.userId,
    required this.title,
    required this.initialBotMessage,
    required this.onClose,
  });

  final String apiUrl;
  final String userId;
  final String title;
  final String initialBotMessage;
  final VoidCallback onClose;

  @override
  State<_ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<_ChatWindow> {
  late List<_Message> messages;
  final TextEditingController inputCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

  bool isLoading = false;
  bool isRecording = false;
  bool voicePlayback = false;

  final AudioRecorder _recorder = AudioRecorder();
  String? _recordPath;

  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  // ✅ SPEED TUNING (FASTER)
  static const double _rateEn = 0.70; // أسرع إنجليزي
  static const double _rateAr = 0.60; // أسرع عربي
  static const double _pitch = 1.05; // أوضح
  static const double _volume = 1.0;

  // ✅ NETWORK
  static const Duration _netTimeout = Duration(seconds: 25);

  String? _lastErrorDetails; // يظهر للمستخدم عند الفشل

  @override
  void initState() {
    super.initState();
    messages = [
      _Message(text: widget.initialBotMessage, sender: _Sender.bot),
    ];
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(jump: true);
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(_rateEn);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(_volume);

      // (اختياري) اختيار Voice إن توفر
      await _tryPickVoice(langCode: "en");

      _tts.setStartHandler(() {
        if (!mounted) return;
        setState(() => voicePlayback = true);
      });
      _tts.setCompletionHandler(() {
        if (!mounted) return;
        setState(() => voicePlayback = false);
      });
      _tts.setCancelHandler(() {
        if (!mounted) return;
        setState(() => voicePlayback = false);
      });
      _tts.setErrorHandler((_) {
        if (!mounted) return;
        setState(() => voicePlayback = false);
      });

      _ttsReady = true;
    } catch (_) {
      _ttsReady = false;
    }
  }

  Future<void> _tryPickVoice({required String langCode}) async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;

      // prefer any voice matching language prefix
      final preferred = voices.cast<dynamic>().where((v) {
        if (v is! Map) return false;
        final l = (v["locale"] ?? "").toString().toLowerCase();
        return l.startsWith(langCode.toLowerCase());
      }).toList();

      if (preferred.isEmpty) return;

      final v = preferred.first;
      if (v is Map) {
        final name = (v["name"] ?? "").toString();
        final locale = (v["locale"] ?? "").toString();
        if (name.isNotEmpty && locale.isNotEmpty) {
          await _tts.setVoice({"name": name, "locale": locale});
        }
      }
    } catch (_) {
      // ignore
    }
  }

  void _scrollToBottom({bool jump = false}) {
    if (!scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollCtrl.hasClients) return;
      final target = scrollCtrl.position.maxScrollExtent;
      if (jump) {
        scrollCtrl.jumpTo(target);
      } else {
        scrollCtrl.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> speakBotResponse(String text, String langCode) async {
    if (!_ttsReady) return;

    final cleanText = text
        .replaceAll(RegExp(r'[*_#`]+'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    await _tts.stop();

    final lc = langCode.toLowerCase();
    if (lc.startsWith("ar")) {
      await _tts.setLanguage("ar-SA");
      await _tts.setSpeechRate(_rateAr);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(_volume);
      await _tryPickVoice(langCode: "ar");
    } else {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(_rateEn);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(_volume);
      await _tryPickVoice(langCode: "en");
    }

    await _tts.speak(cleanText);
  }

  Future<void> handleStopSpeaking() async {
    await _tts.stop();
    if (!mounted) return;
    setState(() => voicePlayback = false);
  }

  // ✅ lightweight internet check
  Future<bool> _hasInternet() async {
    try {
      final r = await InternetAddress.lookup("google.com")
          .timeout(const Duration(seconds: 3));
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> startRecording() async {
    if (isRecording || isLoading) return;

    try {
      if (voicePlayback) await handleStopSpeaking();

      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        _snack("Microphone access is required to record voice input.");
        return;
      }

      final path = await _tempAudioPath();
      _recordPath = path;

      // ✅ WAV 16kHz
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          bitRate: 256000,
        ),
        path: path,
      );

      if (!mounted) return;
      setState(() {
        isRecording = true;
        inputCtrl.text = "Recording...";
      });
    } catch (e) {
      debugPrint("REC START ERROR: $e");
      _snack("Microphone access is required to record voice input.");
    }
  }

  Future<void> stopRecording() async {
    dynamic saved;
    try {
      saved = await _recorder.stop();
    } catch (e) {
      debugPrint("REC STOP ERROR: $e");
    }

    if (!mounted) return;

    setState(() {
      isRecording = false;
      inputCtrl.text = "";
    });

    // Web: some versions may return Uint8List, or String (blob url), or null.
    if (kIsWeb) {
      Uint8List? bytes;
      String? name;

      if (saved is Uint8List) {
        bytes = saved;
        name = "user_query.wav";
      } else if (saved is String) {
        name = _webAudioFileName(saved);
        bytes = await _readWebRecordingBytes(saved);
      } else if (_recordPath != null) {
        // fallback: try reading by recordPath if it is an URL
        name = _webAudioFileName(_recordPath!);
        bytes = await _readWebRecordingBytes(_recordPath!);
      }

      if (bytes == null || bytes.isEmpty) {
        _snack("Recording failed. Please try again.");
        return;
      }

      await processQuery(
        audioBytes: bytes,
        audioFileName: name ?? "user_query.wav",
        audioMime: "audio/wav",
      );
      return;
    }

    // Mobile/desktop: saved is usually a path
    final finalPath = (saved is String ? saved : null) ?? _recordPath;
    if (finalPath == null) return;

    final file = File(finalPath);
    if (!await file.exists()) {
      _snack("Recording failed. Please try again.");
      return;
    }

    await processQuery(
      audioFile: file,
      audioMime: "audio/wav",
    );
  }

  Future<String> _tempAudioPath() async {
    final name = "user_query_${DateTime.now().millisecondsSinceEpoch}.wav";
    if (kIsWeb) return name;
    final dir = await getTemporaryDirectory();
    return "${dir.path}/$name";
  }

  Future<Uint8List?> _readWebRecordingBytes(String url) async {
    try {
      final resp = await http.get(Uri.parse(url)).timeout(_netTimeout);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return resp.bodyBytes;
      }
    } catch (e) {
      debugPrint("WEB READ BYTES ERROR: $e");
    }
    return null;
  }

  String _webAudioFileName(String finalPath) {
    final fallback = _recordPath ?? "user_query.wav";
    try {
      final uri = Uri.parse(finalPath);
      final name =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last.trim() : "";
      if (name.isEmpty || !name.contains(".")) return fallback;
      return name;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> processQuery({
    File? audioFile,
    Uint8List? audioBytes,
    String? audioFileName,
    String audioMime = "audio/wav",
    String textInput = "",
  }) async {
    if (isLoading) return;

    final isAudioQuery = audioFile != null || audioBytes != null;

    String userMessageContent = "";
    if (isAudioQuery) {
      userMessageContent = "🎙️ (Audio Query)";
    } else if (textInput.trim().isNotEmpty) {
      userMessageContent = textInput.trim();
    } else {
      return;
    }

    if (voicePlayback) await handleStopSpeaking();

    final newUserMessage =
        _Message(text: userMessageContent, sender: _Sender.user);

    if (!mounted) return;
    setState(() {
      _lastErrorDetails = null;
      messages = [...messages, newUserMessage];
      inputCtrl.clear();
      isLoading = true;
    });
    _scrollToBottom();

    // ✅ quick net check (optional)
    final okNet = await _hasInternet();
    if (!okNet) {
      final r = _Message(
        text: "No internet connection detected. Please check your network.",
        sender: _Sender.bot,
      );
      if (!mounted) return;
      setState(() {
        messages = [...messages, r];
        isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final uri = Uri.parse(widget.apiUrl);

      final req = http.MultipartRequest("POST", uri);

      // ✅ fields
      req.fields["user_id"] = widget.userId;

      // ✅ headers (helpful for some gateways)
      req.headers["User-Agent"] = "KasselApp/1.0 (Flutter)";
      req.headers["Accept"] = "application/json";

      if (isAudioQuery) {
        final mt = _mediaTypeFromMime(audioMime);

        if (audioBytes != null) {
          final name = (audioFileName?.trim().isNotEmpty ?? false)
              ? audioFileName!.trim()
              : "user_query.wav";

          req.files.add(
            http.MultipartFile.fromBytes(
              "audio",
              audioBytes,
              filename: name,
              contentType: mt,
            ),
          );
        } else {
          final ext = audioFile!.path.split('.').last.toLowerCase();
          final filename = "user_query.$ext";

          req.files.add(
            await http.MultipartFile.fromPath(
              "audio",
              audioFile.path,
              filename: filename,
              // ignore: deprecated_member_use
              contentType: mt,
            ),
          );
        }
      } else {
        req.fields["user_q"] = userMessageContent;
      }

      final streamed = await req.send().timeout(_netTimeout);
      final body = await streamed.stream.bytesToString();

      debugPrint("AI CHAT STATUS: ${streamed.statusCode}");
      debugPrint("AI CHAT BODY: $body");

      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw Exception("HTTP ${streamed.statusCode}: $body");
      }

      final Map<String, dynamic> data = _safeJson(body) ?? {};
      final botResponseText = (data["answer_ai"] as String?) ??
          "I encountered an issue getting a full response.";
      final botResponseLang = (data["language"] as String?) ?? "en";

      final botReply = _Message(text: botResponseText, sender: _Sender.bot);

      if (!mounted) return;
      setState(() {
        messages = [...messages, botReply];
      });
      _scrollToBottom();

      await speakBotResponse(botResponseText, botResponseLang);
    } on TimeoutException catch (e) {
      final details = "Timeout: ${e.message ?? "request exceeded $_netTimeout"}";
      debugPrint("AI CHAT ERROR: $details");

      await _showFailure(details);
    } catch (e) {
      final details = e.toString();
      debugPrint("AI CHAT ERROR: $details");

      await _showFailure(details);
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _showFailure(String details) async {
    _lastErrorDetails = details;

    // رسالة مختصرة للمستخدم + زر نسخ التفاصيل يظهر كرسالة ثانية
    final short = _Message(
      text: "Sorry, the service failed to process your request.",
      sender: _Sender.bot,
    );

    final more = _Message(
      text: "**Debug details**:\n$details\n\n(You can copy this from the info button.)",
      sender: _Sender.bot,
    );

    if (!mounted) return;
    setState(() {
      messages = [...messages, short, more];
    });
    _scrollToBottom();
  }

  MediaType _mediaTypeFromMime(String mime) {
    final parts = mime.split('/');
    if (parts.length == 2) return MediaType(parts[0], parts[1]);
    return MediaType("audio", "wav");
  }

  Map<String, dynamic>? _safeJson(String body) {
    try {
      final v = jsonDecode(body);
      if (v is Map<String, dynamic>) return v;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> handleTextSend() async {
    if (inputCtrl.text.trim().isNotEmpty) {
      await processQuery(textInput: inputCtrl.text);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
  }

  List<TextSpan> _renderBoldSpans(String text, TextStyle baseStyle) {
    final re = RegExp(r'\*\*(.*?)\*\*');
    final spans = <TextSpan>[];

    int last = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(
          text: text.substring(last, m.start),
          style: baseStyle,
        ));
      }
      final boldText = m.group(1) ?? "";
      spans.add(TextSpan(
        text: boldText,
        style: baseStyle.copyWith(fontWeight: FontWeight.w900),
      ));
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last), style: baseStyle));
    }
    if (spans.isEmpty) spans.add(TextSpan(text: text, style: baseStyle));
    return spans;
  }

  Widget _messageBubble(_Message msg) {
    final isUser = msg.sender == _Sender.user;

    final bg = isUser ? const Color(0xFF3B7CE5) : const Color(0xFFF3F4F6);
    final fg = isUser ? Colors.white : const Color(0xFF111827);

    final lines = msg.text.split('\n');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < lines.length; i++)
              Padding(
                padding:
                    EdgeInsets.only(bottom: i == lines.length - 1 ? 0 : 6),
                child: RichText(
                  text: TextSpan(
                    children: _renderBoldSpans(
                      lines[i],
                      TextStyle(
                        color: fg,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(),
            SizedBox(width: 4),
            _Dot(delayMs: 120),
            SizedBox(width: 4),
            _Dot(delayMs: 240),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _recorder.dispose();
    inputCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || isRecording;

    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 420;

    const double sideMargin = 16;

    final double w = isSmall
        ? (size.width - (sideMargin * 2)).clamp(260, 340)
        : 320;

    final double h = isSmall ? (size.height * 0.52).clamp(340, 480) : 460;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                offset: Offset(0, 12),
                color: Color(0x22000000),
              ),
            ],
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B7CE5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "🤖 ${widget.title}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                        ),
                      ),
                    ),

                    // ✅ Copy debug details (if any)
                    if (_lastErrorDetails != null)
                      InkWell(
                        onTap: () async {
                          final txt = _lastErrorDetails!;
                          await Clipboard.setData(ClipboardData(text: txt));
                          _snack("Copied debug details");
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.info_outline,
                              color: Colors.white, size: 18),
                        ),
                      ),

                    InkWell(
                      onTap: widget.onClose,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(
                          "×",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isLoading && index == messages.length) {
                      return _typingIndicator();
                    }
                    return _messageBubble(messages[index]);
                  },
                ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    if (voicePlayback)
                      _iconBtn(
                        onTap:
                            isLoading ? null : () async => handleStopSpeaking(),
                        bg: const Color(0xFFFFE4E6),
                        icon: Icons.stop_rounded,
                        iconColor: const Color(0xFFEF4444),
                        label: "Stop Speaking",
                      )
                    else
                      _iconBtn(
                        onTap: isLoading
                            ? null
                            : () async =>
                                (isRecording ? stopRecording() : startRecording()),
                        bg: isRecording
                            ? const Color(0xFFFFE4E6)
                            : const Color(0xFFF3F4F6),
                        icon: Icons.mic_rounded,
                        iconColor: isRecording
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF111827),
                        label: isRecording ? "Stop Recording" : "Start Recording",
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: inputCtrl,
                        enabled: !disabled,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) async => handleTextSend(),
                        decoration: InputDecoration(
                          hintText: isRecording
                              ? "🔴 RECORDING... Click mic to stop."
                              : isLoading
                                  ? "AI is typing..."
                                  : "Type your message...",
                          hintStyle: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w700,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _sendBtn(
                      onTap: (inputCtrl.text.trim().isEmpty || disabled)
                          ? null
                          : () async => handleTextSend(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn({
    required Future<void> Function()? onTap,
    required Color bg,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    final enabled = onTap != null;

    return Semantics(
      label: label,
      button: true,
      enabled: enabled,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? () => onTap() : null,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled ? bg : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? iconColor : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _sendBtn({required Future<void> Function()? onTap}) {
    final enabled = onTap != null;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? () => onTap() : null,
      child: Container(
        width: 44,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF3B7CE5) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.send_rounded,
          color: enabled ? Colors.white : const Color(0xFF9CA3AF),
          size: 18,
        ),
      ),
    );
  }
}

// =========================
// Typing dots
// =========================

class _Dot extends StatefulWidget {
  const _Dot({this.delayMs = 0});
  final int delayMs;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: const CircleAvatar(
        radius: 3.0,
        backgroundColor: Color(0xFF6B7280),
      ),
    );
  }
}

// =========================
// Models
// =========================

enum _Sender { user, bot }

class _Message {
  _Message({required this.text, required this.sender});
  final String text;
  final _Sender sender;
}
