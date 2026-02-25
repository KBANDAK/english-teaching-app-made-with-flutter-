import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'core/app_services.dart';
import 'core/models/progress_stats.dart';
import 'core/models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onLogout});

  static const routeName = "/profile";
  final VoidCallback? onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  ProgressStats? _progress;
  bool _loading = true;
  String? _error;

  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final TextEditingController _passCtrl = TextEditingController();

  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF475569);
  static const Color _blue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  UserProfile get _p => _profile ?? UserProfile.empty;
  ProgressStats get _s => _progress ?? ProgressStats.empty;

  Future<void> _load() async {
    try {
      final repo = AppServices.profile;
      final profile = await repo.fetchProfile();
      final progress = await repo.fetchProgress();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _progress = progress;
        _loading = false;
        _error = null;
        _emailCtrl.text = profile.email;
        _phoneCtrl.text = profile.phone;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _saveProfile() async {
    try {
      final email = _emailCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      await AppServices.profile.updateProfile(email: email, phone: phone);
      _toast("Saved");
    } catch (_) {
      _toast("Failed to save changes");
    }
  }

  void _changePassword() {
    if (_passCtrl.text.trim().length < 6) {
      _toast("Password must be at least 6 characters");
      return;
    }
    final next = _passCtrl.text.trim();
    AppServices.profile.changePassword(newPassword: next).then((_) {
      _toast("Password changed");
      _passCtrl.clear();
    }).catchError((_) {
      _toast("Failed to change password");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Failed to load profile.",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    _load();
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, c) {
              final maxContentWidth = c.maxWidth >= 1100 ? 1040.0 : double.infinity;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row icons (like your screenshot)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.auto_awesome, color: _blue),
                                      tooltip: "Logo",
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0x22000000)),
                                      ),
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.menu_rounded, color: _ink),
                                        tooltip: "Menu",
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Profile",
                                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: _ink),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Manage your account and learning preferences",
                                  style: TextStyle(color: _muted, fontSize: 14),
                                ),
                                const SizedBox(height: 16),

                                // Segmented Tabs (pill)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: const Color(0x22000000)),
                                  ),
                                  child: TabBar(
                                    indicator: BoxDecoration(
                                      color: _ink,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    dividerColor: Colors.transparent,
                                    labelColor: Colors.white,
                                    unselectedLabelColor: _ink,
                                    labelStyle: const TextStyle(fontWeight: FontWeight.w900),
                                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
                                    tabs: const [
                                      Tab(icon: Icon(Icons.person_rounded, size: 18), text: "Overview"),
                                      Tab(icon: Icon(Icons.insights_rounded, size: 18), text: "Progress"),
                                      Tab(icon: Icon(Icons.settings_rounded, size: 18), text: "Settings"),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },

                    // IMPORTANT: each tab body scrollable to avoid overflow
                    body: TabBarView(
                      children: [
                        _OverviewTabBody(
                          personalInfoCard: _personalInfoCard(),
                          learningProgressCard: _learningProgressCard(
                            onGoProgress: () => DefaultTabController.of(context).animateTo(1),
                            onGoSettings: () => DefaultTabController.of(context).animateTo(2),
                          ),
                        ),
                        _ProgressTabBody(
                          child: _progressView(),
                        ),
                        _SettingsTabBody(
                          child: _settingsView(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================
  // Overview Cards
  // =========================
  Widget _personalInfoCard() {
    final profile = _p;
    return _bigCard(
      title: "Personal Information",
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0EA5E9), width: 5),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded, size: 40, color: _blue),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _ink),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${profile.levelCode} : ${profile.levelLabel}",
                      style: const TextStyle(color: _muted, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 18),

          // Wrap instead of Row => avoids overflow on small screens
          LayoutBuilder(
            builder: (context, c) {
              final itemWidth = c.maxWidth >= 520 ? (c.maxWidth - 16) / 2 : c.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 14,
                children: [
                  SizedBox(width: itemWidth, child: _kv("Name", profile.username)),
                  SizedBox(width: itemWidth, child: _kv("Email", profile.email)),
                  SizedBox(width: itemWidth, child: _kv("Phone", profile.phone)),
                  SizedBox(width: itemWidth, child: _kv("Level", profile.levelCode)),
                ],
              );
            },
          ),

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onLogout,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.w900, color: _ink),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _learningProgressCard({required VoidCallback onGoProgress, required VoidCallback onGoSettings}) {
    final profile = _p;
    return _bigCard(
      title: "Learning Progress",
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(
            profile.levelCode,
            style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: _blue),
          ),
          const SizedBox(height: 6),
          Text(
            "${profile.levelLabel} Level",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGoProgress,
              icon: const Icon(Icons.insights_rounded),
              label: const Text("View Progress"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onGoSettings,
              icon: const Icon(Icons.settings_rounded),
              label: const Text("Open Settings"),
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                side: const BorderSide(color: Color(0x22000000)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Progress tab
  // =========================
  Widget _progressView() {
    final stats = _s;
    return _bigCard(
      title: "Your Progress",
      child: ProgressDashboard(
        subtitle: "Track your learning journey and achievements",
        accuracy: stats.accuracy,
        totalCorrect: stats.totalCorrect,
        levelScores: stats.levelScores,
      ),
    );
  }

  // =========================
  // Settings tab
  // =========================
  Widget _settingsView() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        children: [
          _bigCard(
            title: "Update Email & Phone",
            child: Column(
              children: [
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      elevation: 0,
                    ),
                    child: const Text("Save"),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          _bigCard(
            title: "Change Password",
            child: Column(
              children: [
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "New Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _changePassword,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _ink,
                      side: const BorderSide(color: Color(0x22000000)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: const Text("Update Password"),
                  ),
                ),
              ],
            ),
          ),
          if (widget.onLogout != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
                label: const Text("Log out"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // Helpers
  // =========================
  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(color: _ink, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(
          v,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _muted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _bigCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22000000)),
        boxShadow: const [
          BoxShadow(blurRadius: 18, offset: Offset(0, 10), color: Color(0x08000000)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _ink)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ======================================================
// Tab bodies (Scrollable) => fixes bottom overflow
// ======================================================

class _OverviewTabBody extends StatelessWidget {
  const _OverviewTabBody({
    required this.personalInfoCard,
    required this.learningProgressCard,
  });

  final Widget personalInfoCard;
  final Widget learningProgressCard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 860;

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          children: [
            if (!isWide) ...[
              personalInfoCard,
              const SizedBox(height: 14),
              learningProgressCard,
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: personalInfoCard),
                  const SizedBox(width: 18),
                  Expanded(flex: 2, child: learningProgressCard),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ProgressTabBody extends StatelessWidget {
  const _ProgressTabBody({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      children: [child],
    );
  }
}

class _SettingsTabBody extends StatelessWidget {
  const _SettingsTabBody({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      children: [child],
    );
  }
}

// ===================================================================
// Progress Dashboard (Bar + Rings) - Responsive heights
// ===================================================================

class ProgressDashboard extends StatelessWidget {
  const ProgressDashboard({
    super.key,
    required this.subtitle,
    required this.accuracy,
    required this.totalCorrect,
    required this.levelScores,
  });

  final String subtitle;
  final double accuracy; // 0..1
  final int totalCorrect;
  final Map<String, double> levelScores;

  static const Color _blue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle, style: const TextStyle(color: Color(0xFF475569), height: 1.35)),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 900;
            final left = _BarProgressChart(levelScores: levelScores);
            final right = _PerformancePanel(accuracy: accuracy, totalCorrect: totalCorrect);

            if (!isWide) {
              return Column(
                children: [
                  left,
                  const SizedBox(height: 12),
                  right,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: left),
                const SizedBox(width: 14),
                Expanded(flex: 2, child: right),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BarProgressChart extends StatelessWidget {
  const _BarProgressChart({required this.levelScores});
  final Map<String, double> levelScores;

  @override
  Widget build(BuildContext context) {
    const levels = ["A1", "A2", "B1", "B1+", "B2", "B2+", "C1"];
    final data = levels.map((k) => (k, (levelScores[k] ?? 0))).toList();

    return LayoutBuilder(
      builder: (context, c) {
        final h = (c.maxWidth * 0.62).clamp(260.0, 380.0);

        return Container(
          height: h,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x22000000)),
          ),
          child: BarChart(
            BarChartData(
              maxY: 100,
              minY: 0,
              gridData: FlGridData(show: true, horizontalInterval: 25, drawVerticalLine: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text("Score", style: TextStyle(color: Colors.black54)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 38,
                    getTitlesWidget: (v, _) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text("Level", style: TextStyle(color: Colors.black54)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= data.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(data[i].$1, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (int i = 0; i < data.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].$2.clamp(0, 100),
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                        color: ProgressDashboard._blue,
                      ),
                    ],
                  ),
              ],
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Color(0x33000000)),
                  bottom: BorderSide(color: Color(0x33000000)),
                  right: BorderSide(color: Color(0x11000000)),
                  top: BorderSide(color: Color(0x11000000)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PerformancePanel extends StatelessWidget {
  const _PerformancePanel({required this.accuracy, required this.totalCorrect});

  final double accuracy;
  final int totalCorrect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = (c.maxWidth * 0.72).clamp(260.0, 380.0);

        return Container(
          height: h,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x22000000)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Performance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _RingMetric(
                        title: "Accuracy",
                        valueText: "${(accuracy * 100).toStringAsFixed(2)}%",
                        progress: accuracy.clamp(0.0, 1.0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RingMetric(
                        title: "Total Correct",
                        valueText: "${totalCorrect}Q",
                        progress: (totalCorrect / 100.0).clamp(0.0, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingMetric extends StatelessWidget {
  const _RingMetric({
    required this.title,
    required this.valueText,
    required this.progress,
  });

  final String title;
  final String valueText;
  final double progress;

  static const Color _blue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = c.maxWidth.clamp(120.0, 170.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      centerSpaceRadius: size * 0.34,
                      sectionsSpace: 0,
                      sections: [
                        PieChartSectionData(value: 100, radius: size * 0.10, color: const Color(0xFFEFEFEF), showTitle: false),
                        PieChartSectionData(
                          value: (progress * 100).clamp(0, 100),
                          radius: size * 0.10,
                          color: _blue,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Text(valueText, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
