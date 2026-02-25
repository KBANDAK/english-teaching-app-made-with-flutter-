import 'package:flutter/material.dart';
import 'core/app_services.dart';
import 'core/models/credit_cost.dart';
import 'core/models/plan.dart';
import 'core/models/subscription.dart';

class PlanDetailsScreen extends StatefulWidget {
  const PlanDetailsScreen({super.key});

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  bool _loading = true;
  String? _error;

  Subscription _subscription = Subscription.empty;
  List<Plan> _plans = const [];
  List<CreditCost> _creditCosts = const [];

  static const List<_PlanColor> _colors = [
    _PlanColor(bg: Color(0xFFEFF6FF), border: Color(0xFF155DFC), text: Color(0xFF155DFC)),
    _PlanColor(bg: Color(0xFFFAF5FF), border: Color(0xFFB558FF), text: Color(0xFFB558FF)),
    _PlanColor(bg: Color(0xFFFFF7ED), border: Color(0xFFF64A00), text: Color(0xFFF64A00)),
    _PlanColor(bg: Color(0xFFFEF2F2), border: Color(0xFFEC340B), text: Color(0xFFEC340B)),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = AppServices.plans;
      final sub = await repo.fetchSubscription();
      final plans = await repo.fetchPlans();
      final costs = await repo.fetchCreditCosts();
      if (!mounted) return;
      setState(() {
        _subscription = sub;
        _plans = plans;
        _creditCosts = costs;
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

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _startFreeTrial() async {
    try {
      await AppServices.plans.startFreeTrial();
      await _load();
      _toast("Free trial activated");
    } catch (_) {
      _toast("Failed to start free trial");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = _subscription;

    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Failed to load plans.",
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Plans Details"),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== Header =====
              Text(
                "Kassel Academy",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Credit System Plans",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 14),

              // ===== Active Plan / Lock Section =====
              _LockedBanner(subscription: sub),
              const SizedBox(height: 18),

              // ===== What You'll Get =====
              Text(
                "✨ What You'll Get with a Plan",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 900;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _PerkCard(
                        width: isWide ? (c.maxWidth - 24) / 3 : c.maxWidth,
                        icon: Icons.auto_awesome,
                        title: "AI-Powered Practice",
                        subtitle: "Get instant feedback on speaking and writing",
                      ),
                      _PerkCard(
                        width: isWide ? (c.maxWidth - 24) / 3 : c.maxWidth,
                        icon: Icons.my_location,
                        title: "Smart Test System",
                        subtitle: "Take full IELTS practice tests with detailed scoring",
                      ),
                      _PerkCard(
                        width: isWide ? (c.maxWidth - 24) / 3 : c.maxWidth,
                        icon: Icons.trending_up,
                        title: "Progress Tracking",
                        subtitle: "Monitor your improvement with analytics dashboard",
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 22),

              // ===== Quick Plan Overview =====
              Text(
                "Quick Plan Overview",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 900;
                  final crossAxisCount = isWide ? 4 : 2;

                  // ✅ ارتفاع ثابت يمنع overflow
                  final cardHeight = isWide ? 260.0 : 280.0;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _plans.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: cardHeight,
                    ),
                    itemBuilder: (context, i) {
                      final color = _colors[i % _colors.length];
                      return _PlanCard(plan: _plans[i], color: color);
                    },
                  );
                },
              ),

              const SizedBox(height: 12),

              Center(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: navigate to full pricing
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("See Full Pricing Details →"),
                ),
              ),

              const SizedBox(height: 22),

              // ===== Free Trial =====
              _FreeTrialCard(
                onStart: _startFreeTrial,
              ),

              const SizedBox(height: 18),

              // ===== Credit Cost Table =====
              Text(
                "📊 Credit Cost per Feature",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Understand how credits are consumed",
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 10),

              _CreditCostTable(items: _creditCosts),

              const SizedBox(height: 12),

              _InfoAlert(
                text: "💡 Credits are used only when you practice",
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= Widgets =======================

class _LockedBanner extends StatelessWidget {
  const _LockedBanner({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    final isActive = subscription.hasActiveSubscription;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isActive
              ? [const Color(0xFF111827), const Color(0xFF334155)]
              : [const Color(0xFF0B1220), const Color(0xFF111827)],
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 8),
            color: Color(0x22000000),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: const Icon(Icons.lock, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isActive
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.message ?? "Active subscription",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Plan: ${subscription.planName ?? "-"}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.message ?? "You don't have an active plan",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Choose a plan to unlock AI-powered IELTS preparation, track your progress, and reach your target score faster.",
                        style: TextStyle(color: Colors.white70, height: 1.35),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: navigate to /plans
                          },
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text("View Pricing Plans"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PerkCard extends StatelessWidget {
  const _PerkCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final double width;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9E9EE)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, 6),
              color: Color(0x11000000),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.35,
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
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.color});

  final Plan plan;
  final _PlanColor color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final creditsText = plan.credits != 0
        ? "${plan.credits}"
        : (plan.isUnlimited ? "Unlimited" : "Unknown");

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title row (dot + name)
          Row(
            children: [
              Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  color: color.text,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(blurRadius: 8, offset: Offset(0, 4), color: Color(0x22000000)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Credits
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Credits",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$creditsText / month",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Details list
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: plan.details.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 18, color: color.text),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        plan.details[i],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeTrialCard extends StatelessWidget {
  const _FreeTrialCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🟢 Try Free Trial First",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Not sure yet? Start with our free trial to explore all features with 15 credits.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Start Free Trial"),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditCostTable extends StatelessWidget {
  const _CreditCostTable({required this.items});

  final List<CreditCost> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9E9EE)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 6),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.black.withOpacity(0.06)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Feature",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  "Credit Cost",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Rows
          ...items.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black.withOpacity(0.06)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.star, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            e.feature,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x332563EB)),
                    ),
                    child: Text(
                      "${e.creditsRequired} Credits",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InfoAlert extends StatelessWidget {
  const _InfoAlert({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF1D4ED8),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ======================= Models =======================

class _PlanColor {
  final Color bg;
  final Color border;
  final Color text;

  const _PlanColor({
    required this.bg,
    required this.border,
    required this.text,
  });
}
