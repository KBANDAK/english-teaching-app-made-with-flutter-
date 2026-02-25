import 'package:flutter/material.dart';
import 'smart_tests_screen.dart';

class KasselNavbar extends StatefulWidget {
  const KasselNavbar({
    super.key,
    required this.isLoggedIn,

    // ✅ callbacks
    required this.onGoHome,
    required this.onGoIelts,
    required this.onGoGames,
    required this.onGoPlans,
    required this.onGoAccount,

    required this.onLogin,
    required this.onFreeTrial,

    // ✅ optional routeNames
    this.homeRouteName,
    this.ieltsRouteName,
    this.gamesRouteName,
    this.plansRouteName,

    // ✅ optional profile route
    this.profileRouteName,

    // ✅ navigation behavior
    this.replaceOnHome = true,

    this.desktopLogoAsset = "assets/images/kassel_logo.png",
    this.mobileLogoAsset = "assets/images/kassel_logo.png",

    // ✅ hide nav links when logged out
    this.hideNavWhenLoggedOut = true,

    // ✅ show plans when logged in
    this.showPlansWhenLoggedIn = true,
  });

  final bool isLoggedIn;

  final VoidCallback onGoHome;
  final VoidCallback onGoIelts;
  final VoidCallback onGoGames;
  final VoidCallback onGoPlans;
  final VoidCallback onGoAccount;

  final VoidCallback onLogin;
  final VoidCallback onFreeTrial;

  final String? homeRouteName;
  final String? ieltsRouteName;
  final String? gamesRouteName;
  final String? plansRouteName;

  final String? profileRouteName;

  final bool replaceOnHome;

  final String desktopLogoAsset;
  final String mobileLogoAsset;

  final bool hideNavWhenLoggedOut;
  final bool showPlansWhenLoggedIn;

  @override
  State<KasselNavbar> createState() => _KasselNavbarState();
}

class _KasselNavbarState extends State<KasselNavbar> {
  bool _open = false;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _entry;

  bool _rebuildingOverlay = false;

  void _toggle() => _open ? _close() : _openMenu();

  void _close() {
    if (!_open && _entry == null) return;
    setState(() => _open = false);
    _removeEntry();
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }

  void _pushNamed(String route, {bool replaceAll = false}) {
    if (replaceAll) {
      Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }

  void _goToHome() {
    _close();
    final route = widget.homeRouteName;
    if (route != null && route.isNotEmpty) {
      _pushNamed(route, replaceAll: widget.replaceOnHome);
      return;
    }
    widget.onGoHome();
  }

  void _goTo(String? routeName, VoidCallback fallback) {
    _close();
    if (routeName != null && routeName.isNotEmpty) {
      _pushNamed(routeName);
      return;
    }
    fallback();
  }

  // ✅ FIX: My Account يفتح سواء عبر route أو callback
  void _goToAccount() {
    _close();

    final route = widget.profileRouteName;
    if (route != null && route.isNotEmpty) {
      _pushNamed(route);
      return;
    }

    widget.onGoAccount();
  }

  void _goToSmartTest() {
    _close();
    _pushNamed(SmartTestsScreen.routeName);
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final mq = MediaQuery.of(context);

        return Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
              child: Stack(
                children: [
                  Container(color: Colors.black.withOpacity(0.25)),
                  CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    targetAnchor: Alignment.bottomRight,
                    followerAnchor: Alignment.topRight,
                    offset: const Offset(0, 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: mq.size.width - 24),
                      child: _MobileMenuCard(
                        isLoggedIn: widget.isLoggedIn,
                        hideNavWhenLoggedOut: widget.hideNavWhenLoggedOut,
                        showPlansWhenLoggedIn: widget.showPlansWhenLoggedIn,
                        onGoHome: _goToHome,
                        onGoIelts: () => _goTo(widget.ieltsRouteName, widget.onGoIelts),
                        onGoGames: () => _goTo(widget.gamesRouteName, widget.onGoGames),
                        onGoPlans: () => _goTo(widget.plansRouteName, widget.onGoPlans),
                        onGoSmartTest: _goToSmartTest,
                        onGoAccount: _goToAccount,
                        onLogin: () {
                          _close();
                          widget.onLogin();
                        },
                        onFreeTrial: () {
                          _close();
                          widget.onFreeTrial();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openMenu() {
    if (_open && _entry != null) return;

    setState(() => _open = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_open) return;

      _removeEntry();
      _entry = _buildOverlayEntry();
      Overlay.of(context, rootOverlay: true).insert(_entry!);
    });
  }

  void _refreshOverlayIfOpen() {
    if (!_open) return;
    if (_rebuildingOverlay) return;

    _rebuildingOverlay = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rebuildingOverlay = false;
      if (!mounted || !_open) return;

      _removeEntry();
      _entry = _buildOverlayEntry();
      Overlay.of(context, rootOverlay: true).insert(_entry!);
    });
  }

  @override
  void didUpdateWidget(covariant KasselNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final changed =
        oldWidget.isLoggedIn != widget.isLoggedIn ||
        oldWidget.hideNavWhenLoggedOut != widget.hideNavWhenLoggedOut ||
        oldWidget.showPlansWhenLoggedIn != widget.showPlansWhenLoggedIn;

    if (changed) _refreshOverlayIfOpen();
  }

  @override
  void dispose() {
    _removeEntry();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isDesktop = w >= 992;
        final isTabletUp = w >= 768;

        final hideNav = (!widget.isLoggedIn && widget.hideNavWhenLoggedOut == true);

        return Material(
          elevation: 2,
          color: Colors.white,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
              child: Row(
                children: [
                  InkWell(
                    onTap: _goToHome,
                    child: Image.asset(
                      isDesktop ? widget.desktopLogoAsset : widget.mobileLogoAsset,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),

                  if (isDesktop && !hideNav) ...[
                    _NavBtn(label: "Home", onTap: _goToHome),
                    _NavBtn(label: "IELTS Prep", onTap: () => _goTo(widget.ieltsRouteName, widget.onGoIelts)),
                    _NavBtn(label: "Learn & Play", onTap: () => _goTo(widget.gamesRouteName, widget.onGoGames)),
                    if (widget.showPlansWhenLoggedIn)
                      _NavBtn(label: "Plans", onTap: () => _goTo(widget.plansRouteName, widget.onGoPlans)),
                    if (widget.isLoggedIn)
                      _NavBtn(label: "My Account", onTap: _goToAccount),
                    const SizedBox(width: 10),
                  ],

                  if (isTabletUp) ...[
                    if (widget.isLoggedIn) ...[
                      _GradientPillButton(text: "Smart Test", onTap: _goToSmartTest),
                    ] else ...[
                      _PillOutlinedButton(text: "Log in", onTap: widget.onLogin),
                      const SizedBox(width: 10),
                      _GradientPillButton(text: "Free Trial", onTap: widget.onFreeTrial),
                    ],
                    const SizedBox(width: 10),
                  ],

                  if (!isDesktop)
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: _IconSquareButton(
                        icon: _open ? Icons.close : Icons.menu,
                        onTap: _toggle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ===================== Mobile Menu Card ===================== */

class _MobileMenuCard extends StatelessWidget {
  const _MobileMenuCard({
    required this.isLoggedIn,
    required this.hideNavWhenLoggedOut,
    required this.showPlansWhenLoggedIn,
    required this.onGoHome,
    required this.onGoIelts,
    required this.onGoGames,
    required this.onGoPlans,
    required this.onGoAccount,
    required this.onGoSmartTest,
    required this.onLogin,
    required this.onFreeTrial,
  });

  final bool isLoggedIn;
  final bool hideNavWhenLoggedOut;
  final bool showPlansWhenLoggedIn;

  final VoidCallback onGoHome;
  final VoidCallback onGoIelts;
  final VoidCallback onGoGames;
  final VoidCallback onGoPlans;
  final VoidCallback onGoAccount;
  final VoidCallback onGoSmartTest;

  final VoidCallback onLogin;
  final VoidCallback onFreeTrial;

  @override
  Widget build(BuildContext context) {
    final hideNav = (!isLoggedIn && hideNavWhenLoggedOut == true);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 10),
              color: Color(0x22000000),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hideNav) ...[
              _MobileLink(text: "Home", onTap: onGoHome),
              _MobileLink(text: "IELTS Prep", onTap: onGoIelts),
              _MobileLink(text: "Learn & Play", onTap: onGoGames),
              const SizedBox(height: 8),

              if (showPlansWhenLoggedIn) ...[
                _PillOutlinedButton(text: "Plans", onTap: onGoPlans, fullWidth: true),
                const SizedBox(height: 10),
              ],

              if (isLoggedIn) ...[
                _MobileLink(text: "My Account", onTap: onGoAccount),
                const SizedBox(height: 10),
              ],
            ],

            const SizedBox(height: 6),

            if (isLoggedIn) ...[
              _GradientPillButton(text: "Smart Test", onTap: onGoSmartTest, fullWidth: true),
            ] else ...[
              _PillOutlinedButton(text: "Log in", onTap: onLogin, fullWidth: true),
              const SizedBox(height: 10),
              _GradientPillButton(text: "Free Trial", onTap: onFreeTrial, fullWidth: true),
            ],
          ],
        ),
      ),
    );
  }
}

/* ===================== UI Pieces ===================== */

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF3B4B6B),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class _MobileLink extends StatelessWidget {
  const _MobileLink({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF6B7AA6),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        child: Text(text),
      ),
    );
  }
}

class _PillOutlinedButton extends StatelessWidget {
  const _PillOutlinedButton({
    required this.text,
    required this.onTap,
    this.fullWidth = false,
  });

  final String text;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4B5563),
        side: const BorderSide(color: Color(0xFF9CA3AF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class _GradientPillButton extends StatelessWidget {
  const _GradientPillButton({
    required this.text,
    required this.onTap,
    this.fullWidth = false,
  });

  final String text;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class _IconSquareButton extends StatelessWidget {
  const _IconSquareButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon),
      ),
    );
  }
}
