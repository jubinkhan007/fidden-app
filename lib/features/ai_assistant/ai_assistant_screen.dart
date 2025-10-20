import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ai_api.dart';


class _AiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AiAppBar({required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      centerTitle: true,
    );
  }
}


class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _api = AiApi();

  bool _loading = true;
  bool _aiActive = false;
  AiReport? _report;
  String _selectedPartner = 'Amara';
  bool _refreshing = false;

  static const _partners = ['Amara', 'Zuri', 'Malik', 'Dre'];
  static final _currency = NumberFormat.simpleCurrency();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  String _prettyDateTime(DateTime dt) {
    return DateFormat('MMM d, y h:mm:ss a').format(dt.toLocal());
  }


  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    final active = await _api.getIsAiActive();
    AiReport? rep;
    if (active) {
      try {
        rep = await _api.getWeeklyReport();
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _aiActive = active;
      _report = rep;
      if (rep != null) _selectedPartner = rep.aiPartnerName;
      _loading = false;
    });
  }

  Future<void> _openCheckout() async {
    final url = await _api.createAiAddonCheckoutSession();
    if (url == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start checkout.')),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open checkout URL.')),
      );
    }
  }

  Future<void> _refreshAfterPurchase() async {
    setState(() => _refreshing = true);
    final active = await _api.getIsAiActive();
    if (active) {
      final rep = await _api.getWeeklyReport();
      if (!mounted) return;
      setState(() {
        _aiActive = true;
        _report = rep;
        _selectedPartner = rep.aiPartnerName;
      });
    }
    if (!mounted) return;
    setState(() => _refreshing = false);
  }

  Future<void> _changePartner(String partner) async {
    if (_selectedPartner == partner) return;
    setState(() => _selectedPartner = partner);
    try {
      await _api.setPartner(partner);
      if (!mounted) return;
      if (_report != null) {
        setState(() {
          _report = AiReport(
            totalAppointments: _report!.totalAppointments,
            totalRevenue: _report!.totalRevenue,
            noShowsFilled: _report!.noShowsFilled,
            topSellingService: _report!.topSellingService,
            forecastSummary: _report!.forecastSummary,
            motivationalNudge: _report!.motivationalNudge,
            updatedAt: _report!.updatedAt,
            aiPartnerName: partner,
          );
        });
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Partner set to $partner')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update partner.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Top app bar that visually matches a modern sheet
    final appBar = AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,

      elevation: 0,
      centerTitle: true,
      title: const Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.w700)),
    );

    if (_loading) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: Colors.white,
        body: const _CenteredProgress(),
      );

    }

    // ...inside _AiAssistantScreenState.build()
    if (!_aiActive) {
      return Scaffold(
        appBar: const _AiAppBar(title: 'AI Assistant'),
        body: _Paywall(
          onBuy: _openCheckout,
          onRefresh: _refreshAfterPurchase,
          refreshing: _refreshing,
        ),
      );
    }

// Active → show report
    final r = _report!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('AI Assistant'),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _GradientHeader(
              partner: _selectedPartner,
              onPartnerChanged: _changePartner,
              planState: 'included', // optional: set to 'included' | 'addon'
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _MetricsWrap(
                totalAppointments: r.totalAppointments,
                totalRevenue: r.totalRevenue,
                noShowsFilled: r.noShowsFilled,
                topService: r.topSellingService,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(child: _ForecastPill(text: r.forecastSummary)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(child: _NudgeCard(text: r.motivationalNudge)),
          ),
        ],
      ),
    );

  }
}

/* ------------------------------ Reusable bits ------------------------------ */

class _CenteredProgress extends StatelessWidget {
  const _CenteredProgress();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights, size: 42, color: cs.primary),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _Paywall extends StatelessWidget {
  final VoidCallback onBuy;
  final VoidCallback onRefresh;
  final bool refreshing;
  const _Paywall({required this.onBuy, required this.onRefresh, required this.refreshing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Meet your Next-Gen AI Business Partner',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Unlock weekly insights: appointments, revenue, auto-filled no-shows, best-selling services, and a forecast to fill next week’s open slots.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onBuy,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Buy AI Add-on'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: refreshing ? null : onRefresh,
              icon: refreshing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_circle_outlined),
              label: const Text('I’ve completed purchase — Refresh'),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  final String partner;
  final ValueChanged<String> onPartnerChanged;

  // Scoped list so this widget doesn't depend on the State's private field
  static const List<String> _partners = ['Amara', 'Zuri', 'Malik', 'Dre'];

  const _AssistantHeader({
    required this.partner,
    required this.onPartnerChanged,
  });
  String _prettyDateTime(DateTime dt) {
    // localized but short—replace with intl if you prefer
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2,'0')}-${local.day.toString().padLeft(2,'0')} '
        '${DateFormat('h:mm a').format(local).toString().padLeft(2,'0')}:${local.minute.toString().padLeft(2,'0')}:${local.second.toString().padLeft(2,'0')} '
        '${local.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _assetFor(String name) {
    switch (name) {
      case 'Zuri':
        return 'assets/ai/zuri.png';
      case 'Malik':
        return 'assets/ai/malik.png';
      case 'Dre':
        return 'assets/ai/dre.png';
      case 'Amara':
      default:
        return 'assets/ai/amara.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            _assetFor(partner),
            width: 84,
            height: 84,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            cacheWidth: 240,
            cacheHeight: 240,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _partners.map((p) {
              final selected = p == partner;
              return ChoiceChip(
                label: Text(p),
                selected: selected,
                onSelected: (_) => onPartnerChanged(p),
                pressElevation: 0,
                labelStyle: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                selectedColor: cs.primaryContainer,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cs.outlineVariant),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}


class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _MetricTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.bodySmall;
    final valueStyle = Theme.of(context).textTheme.titleLarge;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ← don’t try to fill all height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 8),
          // Scale down long numbers/labels so they never overflow vertically
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: valueStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


class _MetricsGrid extends StatelessWidget {
  final int totalAppointments;
  final double totalRevenue;
  final int noShowsFilled;
  final String topService;

  const _MetricsGrid({
    required this.totalAppointments,
    required this.totalRevenue,
    required this.noShowsFilled,
    required this.topService,
  });

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    // Slightly taller cards on compact screens → fewer overflows.
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 360;

    return GridView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Wider (shorter) on big screens, taller on compact ones
        childAspectRatio: isCompact ? 1.25 : 1.6,
      ),
      children: [
        _MetricTile(
          title: 'Appointments',
          value: '$totalAppointments',
          icon: Icons.event_available,
        ),
        _MetricTile(
          title: 'Revenue',
          value: _money(totalRevenue),
          icon: Icons.attach_money,
        ),
        _MetricTile(
          title: 'No-shows filled',
          value: '$noShowsFilled',
          icon: Icons.auto_awesome, // sparkle-ish
        ),
        _MetricTile(
          title: 'Top service',
          value: topService,
          icon: Icons.local_offer_outlined,
        ),
      ],
    );
  }
}


class _ForecastCard extends StatelessWidget {
  final String text;
  const _ForecastCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: cs.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Motivation extends StatelessWidget {
  final String text;
  const _Motivation({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}


class _GradientHeader extends StatelessWidget {
  const _GradientHeader({
    super.key,
    required this.partner,
    required this.onPartnerChanged,
    required this.planState,
  });

  final String partner;
  final ValueChanged<String> onPartnerChanged;
  final String planState;

  static const _partners = ['Amara', 'Zuri', 'Malik', 'Dre'];

  String _assetFor(String n) {
    switch (n) {
      case 'Zuri':  return 'assets/ai/zuri.png';
      case 'Malik': return 'assets/ai/malik.png';
      case 'Dre':   return 'assets/ai/dre.png';
      default:      return 'assets/ai/amara.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      // white-first header; only a whisper of tint at the bottom
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cs.surface, cs.surfaceVariant.withOpacity(.05)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with subtle border to sit on white
          Semantics(
            label: 'AI assistant: $partner',
            image: true,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  _assetFor(partner),
                  width: 76, height: 76, fit: BoxFit.cover,
                  cacheWidth: 220, cacheHeight: 220,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _partners.map((p) {
                    final selected = p == partner;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: selected
                          ? _FilledChip(label: p, icon: Icons.check, key: ValueKey('f-$p'))
                          : _OutlineChip(label: p, onTap: () => onPartnerChanged(p), key: ValueKey('o-$p')),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _PlanBadge(
            text: planState == 'included' ? 'Included' : 'Add-on',
            tone: _PlanTone.info, // neutral outline, no fill
          ),
        ],
      ),
    );
  }
}


class _OutlineChip extends StatelessWidget {
  const _OutlineChip({super.key, required this.label, this.onTap});
  final String label; final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: .2)),
      ),
    );
  }
}

class _FilledChip extends StatelessWidget {
  const _FilledChip({super.key, required this.label, this.icon});
  final String label; final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.18), // faint grey, not brand color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant), // subtle ring
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 18, color: cs.onSurface.withOpacity(.7)), const SizedBox(width: 6)],
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: .2)),
      ]),
    );
  }
}


enum _PlanTone { success, info }

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({super.key, required this.text, this.tone = _PlanTone.info});
  final String text; final _PlanTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface, // white
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: cs.onSurface.withOpacity(.7),
          fontWeight: FontWeight.w600,
          letterSpacing: .2,
        ),
      ),
    );
  }
}


class _MetricsWrap extends StatelessWidget {
  const _MetricsWrap({
    super.key,
    required this.totalAppointments,
    required this.totalRevenue,
    required this.noShowsFilled,
    required this.topService,
  });

  final int totalAppointments;
  final double totalRevenue;
  final int noShowsFilled;
  final String topService;

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 360;
    final tile = (Widget w) => Expanded(child: w);

    return Column(
      children: [
        Row(
          children: [
            tile(_GlassTile(
              icon: Icons.event_available,
              title: 'Appointments',
              value: '$totalAppointments',
            )),
            const SizedBox(width: 12),
            // inside _MetricsWrap build()
            tile(_GlassTile(
              icon: Icons.attach_money,
              title: 'Revenue',
              value: _money(totalRevenue),
              // removed leadingBadge to avoid duplicate "$"
              caption: 'Revenue',
            )),

          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            tile(_GlassTile(
              icon: Icons.auto_awesome,
              title: 'No-shows filled',
              value: '$noShowsFilled',
            )),
            const SizedBox(width: 12),
            tile(_GlassTile(
              icon: Icons.local_offer_outlined,
              title: 'Top service',
              value: topService,
            )),
          ],
        ),
      ],
    );
  }
}

class _GlassTile extends StatelessWidget {
  const _GlassTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.caption,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseTitle = Theme.of(context).textTheme.titleLarge;
    final bumped = baseTitle?.copyWith(
      fontSize: (baseTitle.fontSize ?? 22) + 1,
      fontWeight: FontWeight.w700,
      letterSpacing: .2,
      color: cs.onSurface,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        color: cs.surface,                            // pure white
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant), // hairline
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.onSurface.withOpacity(.65)),
          Semantics(
            value: value,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, maxLines: 1, style: bumped),
            ),
          ),
          Text(
            caption ?? title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(.60), // lower contrast
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}




class _ForecastPill extends StatelessWidget {
  const _ForecastPill({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface, // white
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left accent bar
          Container(
            width: 4,
            height: 48,
            margin: const EdgeInsets.only(left: 12, right: 12, top: 14, bottom: 14),
            decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, color: cs.onSurface.withOpacity(.70)),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.25,
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



class _NudgeCard extends StatelessWidget {
  const _NudgeCard({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.35),
      ),
    );
  }
}

