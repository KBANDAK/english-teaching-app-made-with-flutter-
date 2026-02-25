import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'kassel_bottom_nav.dart';
import 'core/app_services.dart';
import 'core/models/smart_test.dart';

const Map<String, String> _smartTestFilters = {
  "all": "All",
  "not-started": "Not started",
  "in-progress": "In progress",
  "completed": "Completed",
};

class SmartTestsScreen extends StatefulWidget {
  const SmartTestsScreen({
    super.key,
    this.showBottomNav = true,
    this.bottomNavIndex = 1,
  });

  static const routeName = "/smart-tests";

  /// Show the app bottom tabs on this screen.
  ///
  /// Note: SmartTestsScreen is currently pushed as a separate route (outside AppShell),
  /// so without this the BottomNavigationBar will not be visible.
  final bool showBottomNav;

  /// Which tab should be highlighted when showing bottom navigation.
  /// 0=Home, 1=IELTS, 2=Learn, 3=Account
  final int bottomNavIndex;

  @override
  State<SmartTestsScreen> createState() => _SmartTestsScreenState();
}

class _SmartTestsScreenState extends State<SmartTestsScreen> {
  List<SmartTest> _tests = const [];
  bool _loading = true;
  String? _error;

  String _filter = "all";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = AppServices.tests;
      final tests = await repo.fetchSmartTests();
      if (!mounted) return;
      setState(() {
        _tests = tests;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<SmartTest> get _filteredTests {
    return _tests.where((test) {
      final progress = test.progress;
      switch (_filter) {
        case "not-started":
          return progress == 0;
        case "in-progress":
          return progress > 0 && progress < 100;
        case "completed":
          return progress >= 100;
        default:
          return true;
      }
    }).toList();
  }

  void _openTest(SmartTest test) {
    // ✅ Opens the Test Overview screen (dynamic path)
    Navigator.of(context).pushNamed("/ielts/test/${test.id}");
  }

  void _onBottomNavTap(int i) {
  Navigator.of(context).pushReplacementNamed(
    AppShell.routeName,
    arguments: {'tabIndex': i},
  );
}

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Failed to load tests.",
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

    final filtered = _filteredTests;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: widget.showBottomNav
          ? KasselBottomNav(
              currentIndex: widget.bottomNavIndex,
              onTap: _onBottomNavTap,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 20 : 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderRow(
                    isMobile: isMobile,
                    filter: _filter,
                    onFilterChanged: (value) =>
                        setState(() => _filter = value),
                  ),
                  const SizedBox(height: 18),
                  if (filtered.isEmpty)
                    const _EmptyState()
                  else
                    LayoutBuilder(
                      builder: (context, c) {
                        final w = c.maxWidth;
                        final gap = w >= 768 ? 20.0 : 16.0;
                        int columns = 1;
                        if (w >= 992) {
                          columns = 3;
                        } else if (w >= 576) {
                          columns = 2;
                        }
                        final itemWidth =
                            (w - gap * (columns - 1)) / columns;

                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: filtered.map((test) {
                            return SizedBox(
                              width: itemWidth,
                              child: _SmartTestCard(
                                test: test,
                                onOpen: () => _openTest(test),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.isMobile,
    required this.filter,
    required this.onFilterChanged,
  });

  final bool isMobile;
  final String filter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final Widget dropdown = SizedBox(
      width: isMobile ? double.infinity : 220,
      child: DropdownButtonHideUnderline(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButton<String>(
            value: filter,
            isExpanded: true,
            icon: const Icon(Icons.expand_more),
            onChanged: (value) {
              if (value != null) onFilterChanged(value);
            },
            items: _smartTestFilters.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(
                      e.value,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Smart Tests",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Text(
            "Filter:",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          dropdown,
        ],
      );
    }

    return Row(
      children: [
        const Expanded(
          child: Text(
            "Smart Tests",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Filter:",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            dropdown,
          ],
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Text(
          "No tests available for this filter.",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      ),
    );
  }
}

class _SmartTestCard extends StatelessWidget {
  const _SmartTestCard({
    required this.test,
    required this.onOpen,
  });

  final SmartTest test;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final safeProgress = test.progress.clamp(0, 100).toInt();
    final hours = test.durationMin ~/ 60;
    final minutes = test.durationMin % 60;

    final btnLabel = safeProgress >= 100
        ? "Review Test"
        : safeProgress > 0
            ? "Continue Test"
            : "Start Test";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            test.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            test.subtitle,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetaItem(
                icon: Icons.access_time,
                label: "${hours}h ${minutes}m",
              ),
              const _InstantBadge(),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "Progress",
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: safeProgress / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "$safeProgress%",
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onOpen,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(btnLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF111827)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF111827)),
        ),
      ],
    );
  }
}

class _InstantBadge extends StatelessWidget {
  const _InstantBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.description, size: 14, color: Color(0xFF1D4ED8)),
          SizedBox(width: 6),
          Text(
            "Instant Feedback",
            style: TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
