import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'nav.dart';
import 'site_widgets.dart';

const siteAppUrl = '/app/';
const siteLandingUrl = '/mobile/';
const siteApiUrl = 'https://myfitwellness-api.vercel.app/healthz';
const siteGithubUrl = 'https://github.com/Dera-prog/MyFitWellness';

/// Every marketing page is addressable. Paths are relative to the site's
/// base href (/site/), so the live URLs are /site/features, /site/plans, etc.
enum SitePage {
  home('/', 'Home'),
  features('/features', 'Features'),
  howItWorks('/how-it-works', 'How it works'),
  plans('/plans', 'Plans'),
  faq('/faq', 'FAQ');

  const SitePage(this.path, this.label);

  final String path;
  final String label;

  static SitePage fromPath(String? path) {
    var normalized = (path == null || path.isEmpty) ? '/' : path;
    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    for (final page in values) {
      if (page.path == normalized) return page;
    }
    return home;
  }

  static List<SitePage> get mainNav =>
      values.where((page) => page != SitePage.home).toList();
}

/// Lets any widget inside a page move to another page or open the app
/// without threading callbacks through every section.
class SiteNavScope extends InheritedWidget {
  const SiteNavScope({
    super.key,
    required this.open,
    required this.openApp,
    required super.child,
  });

  final void Function(SitePage) open;
  final VoidCallback openApp;

  static SiteNavScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SiteNavScope>();
    assert(scope != null, 'SiteNavScope is only available inside SiteShell');
    return scope!;
  }

  @override
  bool updateShouldNotify(SiteNavScope oldWidget) => false;
}

class SiteShell extends StatefulWidget {
  const SiteShell({super.key, required this.page, required this.child});

  final SitePage page;
  final Widget child;

  @override
  State<SiteShell> createState() => _SiteShellState();
}

class _SiteShellState extends State<SiteShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scroll = ScrollController();
  bool _elevated = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final elevated = _scroll.offset > 6;
    if (elevated != _elevated) setState(() => _elevated = elevated);
  }

  void _open(SitePage page) {
    if (page == widget.page) {
      _goTop();
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      page.path,
      (route) => route.isFirst,
    );
  }

  void _goTop() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openApp() => openInternal(siteLandingUrl);

  @override
  Widget build(BuildContext context) {
    return SiteNavScope(
      open: _open,
      openApp: _openApp,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.bg,
        endDrawer: _SiteDrawer(
          page: widget.page,
          onNavigate: (page) {
            Navigator.of(context).pop();
            _open(page);
          },
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _SiteHeader(
                page: widget.page,
                elevated: _elevated,
                onMenu: () => _scaffoldKey.currentState?.openEndDrawer(),
                onApp: _openApp,
                onNavigate: _open,
                onTop: () => _open(SitePage.home),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  child: Column(
                    children: [
                      widget.child,
                      const SiteFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- header

class _SiteHeader extends StatelessWidget {
  const _SiteHeader({
    required this.page,
    required this.elevated,
    required this.onMenu,
    required this.onApp,
    required this.onNavigate,
    required this.onTop,
  });

  final SitePage page;
  final bool elevated;
  final VoidCallback onMenu;
  final VoidCallback onApp;
  final void Function(SitePage) onNavigate;
  final VoidCallback onTop;

  @override
  Widget build(BuildContext context) {
    final tablet = Site.tablet(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg.withValues(alpha: 0.94),
        border: Border(
          bottom: BorderSide(
            color: elevated ? AppColors.line : Colors.transparent,
          ),
        ),
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: Color(0x0A0D1B16),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: SiteWrap(
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              InkWell(
                onTap: onTop,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      BrandMark(size: 32),
                      SizedBox(width: 10),
                      BrandWordmark(fontSize: 13, letterSpacing: 1.2),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (tablet)
                for (final item in SitePage.mainNav) ...[
                  _NavLink(
                    label: item.label,
                    active: item == page,
                    onTap: () => onNavigate(item),
                  ),
                  const SizedBox(width: 18),
                ],
              if (tablet)
                SiteButton(
                  label: 'Open the app',
                  onTap: onApp,
                  compact: true,
                )
              else ...[
                InkWell(
                  onTap: onApp,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Text(
                      'Open app',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenDeep,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _MenuButton(onTap: onMenu),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: active ? AppColors.ink : AppColors.inkSoft,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: active ? 16 : 0,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.menu_rounded,
            size: 20,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _SiteDrawer extends StatelessWidget {
  const _SiteDrawer({
    required this.page,
    required this.onNavigate,
  });

  final SitePage page;
  final void Function(SitePage) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => onNavigate(SitePage.home),
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        BrandMark(size: 30),
                        SizedBox(width: 9),
                        BrandWordmark(fontSize: 13, letterSpacing: 1.2),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.inkSoft,
                    tooltip: 'Close menu',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            for (final item in SitePage.values)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                selected: item == page,
                selectedColor: AppColors.greenDeep,
                selectedTileColor: AppColors.green.withValues(alpha: 0.06),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight:
                        item == page ? FontWeight.w600 : FontWeight.w500,
                    color: item == page ? AppColors.greenDeep : AppColors.ink,
                  ),
                ),
                trailing: Icon(
                  item == page
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  size: item == page ? 17 : 15,
                  color: item == page ? AppColors.greenDeep : AppColors.muted,
                ),
                onTap: () => onNavigate(item),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- footer

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = Site.wide(context);
    final nav = SiteNavScope.of(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: EdgeInsets.symmetric(vertical: wide ? 44 : 34),
      child: SiteWrap(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: _FootBrand()),
                  _FootLinks(nav: nav),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FootBrand(),
                  const SizedBox(height: 24),
                  _FootLinks(nav: nav),
                ],
              ),
            const SizedBox(height: 26),
            const Text(
              '© 2026 MyFitWellness. Built with Flutter, Hono and PostgreSQL.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FootBrand extends StatelessWidget {
  const _FootBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            BrandMark(size: 30),
            SizedBox(width: 9),
            BrandWordmark(fontSize: 13, letterSpacing: 1.2),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Daily fitness for real gym members.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _FootLinks extends StatelessWidget {
  const _FootLinks({required this.nav});

  final SiteNavScope nav;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 22,
      runSpacing: 10,
      children: [
        for (final page in SitePage.mainNav)
          _FootLink(label: page.label, onTap: () => nav.open(page)),
        _FootLink(
          label: 'Web app',
          onTap: () => openInternal(siteAppUrl),
        ),
        _FootLink(
          label: 'API status',
          onTap: () => openExternal(siteApiUrl),
        ),
        _FootLink(
          label: 'GitHub',
          onTap: () => openExternal(siteGithubUrl),
        ),
      ],
    );
  }
}

class _FootLink extends StatelessWidget {
  const _FootLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}