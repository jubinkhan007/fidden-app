import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'ai_api.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() =>
      _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final AiApi _api = AiApi();

  WeeklySummary? _summary;
  bool _loading = true;
  String? _error;
  String? _subscriptionErrorMsg;

  GeneratedCaptionResult? _generated;
  bool _generating = false;
  bool _isCancelling = false;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _subscriptionErrorMsg = null;
    });

    try {
      final s = await _api.fetchLatest();
      setState(() {
        _summary = s;
        _loading = false;
      });
    } on AiApiException catch (e) {
      if (e.statusCode == 403) {
        setState(() {
          _subscriptionErrorMsg = e.message;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Error: ${e.message}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Exception: $e';
        _loading = false;
      });
    }
  }

  Future<void> _handleCta({
    required String action,
  }) async {
    final s = _summary;
    if (s == null) return;

    setState(() => _loading = true);
    final ok =
    await _api.triggerAction(summaryId: s.id, action: action);
    setState(() => _loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Action sent: $action'
              : 'Failed to send action: $action',
        ),
      ),
    );
  }

  Future<void> _generateCaption({
    bool previewOnly = false,
  }) async {
    final s = _summary;
    if (s == null || _generating) return;

    setState(() => _generating = true);
    try {
      final res =
      await _api.generateMarketingCaptionWithResult(
        s.id,
        previewOnly: previewOnly,
      );
      if (!mounted) return;
      setState(() => _generated = res);

      if (res.caption.trim().isNotEmpty) {
        _showCaptionSheet(res);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No caption returned')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  void _showCaptionSheet(GeneratedCaptionResult res) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_fix_high),
                  const SizedBox(width: 8),
                  Text(
                    'Generated Caption',
                    style: Theme.of(ctx)
                        .textTheme
                        .titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                  BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: SelectableText(
                  res.caption,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(
                              text: res.caption));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content:
                          Text('Caption copied'),
                        ),
                      );
                    },
                    icon: const Icon(
                        Icons.copy_rounded),
                    label: const Text('Copy'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () =>
                        Share.share(res.caption),
                    icon: const Icon(
                        Icons.ios_share_rounded),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cancelAi() async {
    if (_isCancelling) return;

    final bool? didConfirm =
    await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel AI Assistant?'),
        content: const Text(
          'Are you sure you want to cancel your AI add-on subscription?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Get.back(result: false),
            child: const Text('Nevermind'),
          ),
          FilledButton(
            onPressed: () =>
                Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (didConfirm != true) return;

    setState(() => _isCancelling = true);
    try {
      await _api.cancelAiAddon();
      AppSnackBar.showSuccess(
          'AI Add-on successfully cancelled.');
      await _load();
    } on AiApiException catch (e) {
      AppSnackBar.showError(e.message);
    } catch (_) {
      AppSnackBar.showError(
          'An unexpected error occurred.');
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  Future<void> _purchaseAi() async {
    if (_isPurchasing) return;

    setState(() => _isPurchasing = true);
    try {
      final resp = await NetworkCaller()
          .postRequest(AppUrls.checkoutAiAddon, body: {});
      if (resp.isSuccess &&
          resp.responseData['url'] != null) {
        final url =
        Uri.parse(resp.responseData['url']);
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } else {
          AppSnackBar.showError(
              'Could not open checkout page.');
        }
      } else {
        AppSnackBar.showError(
          resp.errorMessage ??
              'Could not create checkout session.',
        );
      }
    } catch (e) {
      AppSnackBar.showError(
          'An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
        await _load();
      }
    }
  }

  Widget _buildSubscriptionError(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: Colors.white,
        surfaceTintColor:
        Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Feature Locked',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _subscriptionErrorMsg ??
                    'This feature requires an active AI Assistant subscription.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              _isPurchasing
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                onPressed: _purchaseAi,
                icon: const Icon(Icons
                    .workspace_premium_outlined),
                label: const Text(
                    'Upgrade to AI Assistant'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets
                      .symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Assistant'),
          backgroundColor: Colors.white,
          surfaceTintColor:
          Colors.transparent,
        ),
        body:
        const Center(child: CircularProgressIndicator()),
      );
    }

    if (_subscriptionErrorMsg != null) {
      return _buildSubscriptionError(context);
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Assistant'),
          backgroundColor: Colors.white,
          surfaceTintColor:
          Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(16),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Text(
                  'Failed to load summary',
                  style: theme.textTheme
                      .titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(
                    color: theme
                        .colorScheme
                        .error,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _load,
                  icon: const Icon(
                      Icons.refresh),
                  label:
                  const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final s = _summary!;
    final canPurchaseAi = s.canPurchaseAi;
    final canCancelAi = s.canCancelAi;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: Colors.white,
        surfaceTintColor:
        Colors.transparent,
        actions: [
          if (canCancelAi)
            _isCancelling
                ? const Padding(
              padding:
              EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
                : TextButton(
              onPressed:
              _cancelAi,
              child: const Text(
                'Cancel AI',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding:
          const EdgeInsets.all(16),
          children: [
            _headerCard(s, context),
            const SizedBox(height: 12),
            _kpisGrid(s, context),
            const SizedBox(height: 12),
            if (s.topService != null)
              _topServiceCard(s, context),
            const SizedBox(height: 12),
            _motivationCard(s, context),
            const SizedBox(height: 12),
            _forecastCard(s, context),
            const SizedBox(height: 12),
            _recommendationCards(
                s, context),
            const SizedBox(height: 20),

            // Footer action (logic-only change, same visuals)
            if (canCancelAi)
              (_isCancelling
                  ? const Center(
                child:
                CircularProgressIndicator(),
              )
                  : FilledButton.icon(
                onPressed:
                _cancelAi,
                icon: const Icon(
                    Icons
                        .cancel_outlined),
                label: const Text(
                    'Cancel AI Assistant'),
                style: FilledButton
                    .styleFrom(
                  backgroundColor:
                  Colors
                      .redAccent,
                  padding: const EdgeInsets
                      .symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle:
                  const TextStyle(
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ))
            else if (canPurchaseAi)
              (_isPurchasing
                  ? const Center(
                child:
                CircularProgressIndicator(),
              )
                  : FilledButton.icon(
                onPressed:
                _purchaseAi,
                icon: const Icon(
                    Icons
                        .workspace_premium_outlined),
                label:
                const Text(
                  'Upgrade to AI Assistant',
                ),
                style: FilledButton
                    .styleFrom(
                  padding: const EdgeInsets
                      .symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle:
                  const TextStyle(
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              )),

            if (kDebugMode)
              _channelsChips(s),
          ],
        ),
      ),
    );
  }

  // --- Helper widgets (unchanged visually) ---

  Widget _headerCard(
      WeeklySummary s,
      BuildContext context) {
    final dt = DateFormat('MMM d, h:mm a')
        .format(s.createdAt.toLocal());
    final range = _fmtRange(
        s.weekStartDate, s.weekEndDate);
    return _card(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Your Weekly Business Snapshot ✨',
            style: Theme.of(context)
                .textTheme
                .titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            range,
            style: TextStyle(
              color:
              Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Generated: $dt',
            style: TextStyle(
              color:
              Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpisGrid(
      WeeklySummary s,
      BuildContext context) {
    final kpis = <_Kpi>[
      _Kpi('Revenue',
          bdMoney(s.revenueGenerated),
          Icons.attach_money),
      _Kpi('Appointments',
          '${s.totalAppointments}',
          Icons.people_alt_outlined),
      _Kpi('Rebooking',
          '${s.rebookingRate.toStringAsFixed(0)}%',
          Icons.repeat),
      _Kpi(
        'Growth',
        signedPct(s.growthRate),
        s.growthRate >= 0
            ? Icons.trending_up
            : Icons.trending_down,
        valueColor: s.growthRate >= 0
            ? Colors.green
            : Colors.red,
      ),
      _Kpi('No-shows filled',
          '${s.noShowsFilled}',
          Icons.event_available),
      _Kpi('Open slots next wk',
          '${s.openSlotsNextWeek}',
          Icons.today),
      _Kpi('Forecast',
          bdMoney(s
              .forecastEstimatedRevenue),
          Icons.query_stats),
    ];

    return _card(
      child: GridView.builder(
        physics:
        const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: kpis.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 84,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (_, i) {
          final k = kpis[i];
          return Container(
            padding:
            const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                color:
                Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                  Colors.grey.shade200,
                  child: Icon(
                    k.icon,
                    size: 18,
                    color: k.valueColor ??
                        Colors.black87,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        k.title,
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style: TextStyle(
                          color: Colors
                              .grey.shade600,
                        ),
                      ),
                      const SizedBox(
                          height: 2),
                      Text(
                        k.value,
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style: Theme.of(
                            context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color: k
                              .valueColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topServiceCard(
      WeeklySummary s,
      BuildContext context) {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.star,
              color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Top Service: ${s.topService} '
                  '(${s.topServiceCount ?? 0} bookings)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _motivationCard(
      WeeklySummary s,
      BuildContext context) {
    return _card(
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.favorite_outline,
            color: Colors.pink,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              s.aiMotivation,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _forecastCard(
      WeeklySummary s,
      BuildContext context) {
    final f = s.recommendations.forecast;
    if (f == null) return const SizedBox.shrink();
    return _card(
      child: Row(
        children: [
          const Icon(Icons.query_stats,
              color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Next week: ${f.openSlotsNextWeek} open slots '
                  '• Forecast ${bdMoney(f.forecastEstimatedRevenue)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendationCards(
      WeeklySummary s,
      BuildContext context) {
    final recs = <RecCard>[
      if (s.recommendations
          .revenueBooster !=
          null)
        s.recommendations
            .revenueBooster!,
      if (s.recommendations
          .retentionPlay !=
          null)
        s.recommendations
            .retentionPlay!,
    ];
    if (recs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: recs
          .map(
            (r) => Padding(
          padding:
          const EdgeInsets.only(
              bottom: 12),
          child: _card(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  r.headline,
                  style: Theme.of(
                      context)
                      .textTheme
                      .titleMedium,
                ),
                const SizedBox(
                    height: 6),
                Text(r.text),
                const SizedBox(
                    height: 12),
                Align(
                  alignment:
                  Alignment
                      .centerRight,
                  child: FilledButton(
                    onPressed: () {
                      final isGenerateCaption =
                          r.ctaAction ==
                              'generate_marketing_caption';
                      if (isGenerateCaption) {
                        _generateCaption(
                            previewOnly:
                            false);
                      } else {
                        _handleCta(
                          action: r
                              .ctaAction,
                        );
                      }
                    },
                    child: Text(
                      r.ctaAction ==
                          'generate_marketing_caption'
                          ? 'Generate Caption'
                          : r.ctaLabel,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _channelsChips(
      WeeklySummary s) {
    if (s.deliveredChannels.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: s.deliveredChannels
          .map(
            (c) => Chip(
          label: Text(c),
          visualDensity:
          VisualDensity.compact,
          backgroundColor:
          Colors.grey.shade100,
          side: BorderSide(
            color:
            Colors.grey.shade300,
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color:
          Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),
            offset:
            const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  String _fmtRange(DateTime a, DateTime b) {
    final fmt = DateFormat('MMM d');
    return '${fmt.format(a.toLocal())} — '
        '${fmt.format(b.toLocal())}';
  }
}

class _Kpi {
  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  _Kpi(this.title, this.value, this.icon,
      {this.valueColor});
}
