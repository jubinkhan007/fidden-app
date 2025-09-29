// lib/features/business_owner/coupons/screens/add_edit_coupon_screen.dart
import 'package:fidden/core/commom/widgets/custom_app_bar.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/features/business_owner/coupons/controller/coupon_controller.dart';
import 'package:fidden/features/business_owner/coupons/data/coupon_model.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:fidden/features/business_owner/home/model/get_my_service_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddEditCouponScreen extends StatefulWidget {
  const AddEditCouponScreen({super.key});

  @override
  State<AddEditCouponScreen> createState() => _AddEditCouponScreenState();
}

class _AddEditCouponScreenState extends State<AddEditCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _maxUsageCtrl = TextEditingController();
  late final BusinessOwnerController _bo;
  Worker? _svcWorker, _shopWorker; // to stop listening on dispose

  // UI state
  bool _inPercentage = true;
  bool _isActive = true;
  DateTime? _validityDate;
  final Set<int> _selectedServiceIds = <int>{};

  // display-only (edit mode)
  String? _code;
  DateTime? _createdAt;
  DateTime? _updatedAt;

  // service options to choose from
  List<_ServiceOption> _serviceOptions = [];

  bool get _isEdit => Get.arguments is Coupon;
  int? _shopId; // required for create

  final _dateFmt = DateFormat('yMMMd');

@override
void initState() {
  super.initState();

  _bo = Get.isRegistered<BusinessOwnerController>()
      ? Get.find<BusinessOwnerController>()
      : Get.put(BusinessOwnerController());

  // services -> options
  _svcWorker = ever<List<GetMyServiceModel>>(
    _bo.allServiceList, (_) => _syncServiceOptionsFromController(),
  );

  // set shop id immediately if we have it
  _shopId ??= myShopId.value;

  // if shop id arrives later, capture it (Add mode)
  _shopWorker = ever<int?>(myShopId, (id) {
    if (!_isEdit && ( _shopId == null || _shopId == 0) && id != null && id > 0) {
      setState(() => _shopId = id);
    }
  });

  if (_bo.allServiceList.isEmpty) _bo.fetchAllMyService(); else _syncServiceOptionsFromController();
  _prefillIfEditing();
}


  void _loadServiceOptionsAndShop() {
    // Expecting navigation like:
    // Get.toNamed('/add-coupon', arguments: {'shopId': 7, 'serviceOptions': [{'id': 9, 'name': '...'}, ...]})
    if (Get.arguments is Map) {
      final a = Get.arguments as Map;
      _shopId = a['shopId'] as int?;
      final argList = (a['serviceOptions'] as List?) ?? const [];
      if (argList.isNotEmpty) {
        _serviceOptions = argList
            .map((e) => _ServiceOption(id: e['id'] as int, name: '${e['name']}'))
            .toList();
      }
    }

    // fallback demo options if none provided (remove when wiring real API)
    final noServices = _serviceOptions.isEmpty;
  }

  void _prefillIfEditing() {
    if (_isEdit) {
      final c = Get.arguments as Coupon;
      _descriptionCtrl.text = c.description;
      _amountCtrl.text = c.inPercentage ? c.amount.toString() : c.amount.toStringAsFixed(2);
      _maxUsageCtrl.text = c.maxUsagePerUser.toString();
      _inPercentage = c.inPercentage;
      _isActive = c.isActive;
      _validityDate = c.validityDate;
      _selectedServiceIds.addAll(c.services);
      _code = c.code;
      _createdAt = c.createdAt;
      _updatedAt = c.updatedAt;
      _shopId ??= c.shop; // make sure we have shop id in edit too
    } else {
      _isActive = true;
      _inPercentage = true;
      _maxUsageCtrl.text = '1';
    }
  }

@override
void dispose() {
  _svcWorker?.dispose();
  _shopWorker?.dispose();
  _descriptionCtrl.dispose();
  _amountCtrl.dispose();
  _maxUsageCtrl.dispose();
  super.dispose();
}

  void _syncServiceOptionsFromController() {
  final list = _bo.allServiceList; // RxList<GetMyServiceModel>
  final mapped = list
      .where((s) => s.id != null && (s.isActive ?? true))
      .map((s) => _ServiceOption(id: s.id!, name: s.title ?? 'Untitled'))
      .toList();

  setState(() => _serviceOptions = mapped);
}

  // ─── actions ─────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _validityDate ?? now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      helpText: 'Select validity date',
    );
    if (picked != null) setState(() => _validityDate = picked);
  }

    void _openServicesSheet() async {
    final temp = Set<int>.from(_selectedServiceIds);
    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        // Use StatefulBuilder for local state management within the sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter sheetSetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Make column height fit content
                  children: [
                    const Text('Apply to services',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    // Use Flexible and shrinkWrap to prevent layout errors
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _serviceOptions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final s = _serviceOptions[i];
                          final checked = temp.contains(s.id);
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(s.name,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            value: checked,
                            onChanged: (v) {
                              // Use the sheet's local setState
                              sheetSetState(() {
                                if (v == true) {
                                  temp.add(s.id);
                                } else {
                                  temp.remove(s.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Pass the result back when popping
                          Navigator.of(context).pop(temp);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Done',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Update the main screen's state only after the sheet is closed with a result
    if (result != null) {
      setState(() => _selectedServiceIds..clear()..addAll(result));
    }
  }

  Future<void> _save() async {
  final ctrl = Get.find<CouponController>();

  // if Add mode and shop still null, try again from global
  _shopId ??= myShopId.value;

  if (!_formKey.currentState!.validate()) return;
  if (_serviceOptions.isEmpty) {
    Get.snackbar('No services', 'Please create a service first.', snackPosition: SnackPosition.BOTTOM);
    return;
  }
  if (_selectedServiceIds.isEmpty) {
    Get.snackbar('Select services', 'Choose at least one service.', snackPosition: SnackPosition.BOTTOM);
    return;
  }
  if (_validityDate == null) {
    Get.snackbar('Pick a date', 'Please select a validity date.', snackPosition: SnackPosition.BOTTOM);
    return;
  }
  if (!_isEdit && (_shopId == null || _shopId == 0)) {
    Get.snackbar('Missing shop', 'Shop is required to create a coupon.', snackPosition: SnackPosition.BOTTOM);
    return;
  }

    final amountNum = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final draft = CouponDraft(
      description: _descriptionCtrl.text.trim(),
      amount: amountNum,
      inPercentage: _inPercentage,
      shop: _shopId ?? 0,
      services: _selectedServiceIds.toList(),
      validityDate: _validityDate!,
      maxUsagePerUser: int.tryParse(_maxUsageCtrl.text.trim()) ?? 1,
      isActive: _isEdit ? _isActive : null, // include only on update
    );

    bool ok = false;
    if (_isEdit) {
      final id = (Get.arguments as Coupon).id;
      ok = await ctrl.updateCoupon(id, draft);
    } else {
      ok = await ctrl.createCoupon(draft);
    }

    if (ok) Get.back(); // return to list
  }

  void _onMore(String v) async {
    switch (v) {
      case 'toggle':
        setState(() => _isActive = !_isActive);
        // also push immediately to server if you want:
        final c = Get.arguments as Coupon;
        await Get.find<CouponController>().setActive(c.id, _isActive);
        break;
      case 'delete':
        final c = Get.arguments as Coupon;
        final ok = await Get.find<CouponController>().deleteCoupon(c.id);
        if (ok) Get.back();
        break;
    }
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final saving = Get.find<CouponController>().isSaving;
    final noServices = _serviceOptions.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Coupon' : 'Add Coupon'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [?_isEdit
            ? PopupMenuButton<String>(
          onSelected: _onMore,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Text(_isActive ? 'Deactivate' : 'Activate'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          child: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.more_horiz_rounded),
          ),
        )
            : null,]
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              if (_isEdit) _HeaderCard(code: _code, isActive: _isActive, createdAt: _createdAt, updatedAt: _updatedAt),
          
              if (noServices) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'You don’t have any services yet. Create services first to attach this coupon.',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
          
              const SizedBox(height: 12),
              _FieldLabel('Description'),
              CustomTexFormField(
                controller: _descriptionCtrl,
                hintText: 'e.g., 20% off all services',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a description' : null,
              ),
          
              const SizedBox(height: 16),
              _FieldLabel('Discount'),
              LayoutBuilder(
  builder: (context, constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: constraints.maxWidth),
      child: Row(
        children: [
          Expanded(
            child: CustomTexFormField(
              controller: _amountCtrl,
              hintText: _inPercentage ? 'e.g., 20' : 'e.g., 20.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Text(
                  _inPercentage ? '%' : '\$',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter amount';
                final num? n = num.tryParse(v.trim());
                if (n == null) return 'Invalid number';
                if (_inPercentage && (n < 0 || n > 100)) return '0–100 only for %';
                if (!_inPercentage && n < 0) return 'Must be ≥ 0';
                return null;
              },
            ),
          ),
          const SizedBox(width: 10),
          // ← give the toggle a tight width so its inner Expanded()s can lay out
          SizedBox(
            width: 160, // 140–200 is fine
            child: _SegmentedToggle(
              value: _inPercentage,
              onChanged: (v) => setState(() => _inPercentage = v),
            ),
          ),
        ],
      ),
    );
  },
),
          
          
              const SizedBox(height: 16),
              _FieldLabel('Applicable Services'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedServiceIds.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                      child: const Text('No services selected', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
                    ),
                  ..._serviceOptions
                      .where((s) => _selectedServiceIds.contains(s.id))
                      .map((s) => InputChip(
                    label: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    onDeleted: () => setState(() => _selectedServiceIds.remove(s.id)),
                  )),
                  ActionChip(
                    label: const Text('Select services', style: TextStyle(fontWeight: FontWeight.w900)),
                    onPressed: noServices ? null : _openServicesSheet,
                  ),
                ],
              ),
          
              const SizedBox(height: 16),
              _FieldLabel('Validity Date'),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Color(0xFF6B7280)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _validityDate == null ? 'Select a date' : _dateFmt.format(_validityDate!),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _validityDate == null ? const Color(0xFF9CA3AF) : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.edit_calendar_rounded),
                    ],
                  ),
                ),
              ),
          
              const SizedBox(height: 16),
              _FieldLabel('Status'),
              Container(
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text('Active', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    _isActive ? 'Coupon is available to customers' : 'Coupon is disabled',
                    style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          
              const SizedBox(height: 16),
              _FieldLabel('Max Usage Per User'),
              LayoutBuilder(
  builder: (context, constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: constraints.maxWidth),
      child: Row(
        children: [
          _StepButton(icon: Icons.remove_rounded, onTap: () => _stepUsage(-1)),
          const SizedBox(width: 8),
          Expanded(
            child: CustomTexFormField(
              controller: _maxUsageCtrl,
              hintText: 'e.g., 3',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                if (n == null || n < 1) return 'Enter a positive integer';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          _StepButton(icon: Icons.add_rounded, onTap: () => _stepUsage(1)),
        ],
      ),
    );
  },
),
          
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
  final savingNow = saving.value;
  final disabled = savingNow || (_serviceOptions.isEmpty && !_isEdit);

  return SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      // Give the bottom bar a fixed, reasonable height
      constraints: const BoxConstraints.tightFor(height: 80),
      child: SizedBox.expand(
        child: CustomButton(
          onPressed: disabled ? null : _save,
          child: savingNow
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEdit ? 'Save Changes' : 'Create Coupon'),
        ),
      ),
    ),
  );
}),

    );
  }

  void _stepUsage(int delta) {
    final n = int.tryParse(_maxUsageCtrl.text.trim());
    final next = (n ?? 1) + delta;
    if (next < 1) return;
    setState(() => _maxUsageCtrl.text = next.toString());
  }
}

// sub-widgets

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.code,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? code;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yMMMd • h:mm a');
    final badgeBg = isActive ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6);
    final dot = isActive ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);
    final txt = isActive ? const Color(0xFF065F46) : const Color(0xFF4B5563);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const Icon(Icons.local_offer_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(code ?? 'New Coupon', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(isActive ? 'Active' : 'Inactive', style: TextStyle(color: txt, fontWeight: FontWeight.w800, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (createdAt != null || updatedAt != null)
                  Text(
                    [
                      if (createdAt != null) 'Created ${df.format(createdAt!)}',
                      if (updatedAt != null) 'Updated ${df.format(updatedAt!)}'
                    ].join('  •  '),
                    style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// lib/features/business_owner/coupons/screens/add_edit_coupon_screen.dart

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({required this.value, required this.onChanged});
  final bool value; // true = %, false = $
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // This implementation correctly creates the custom toggle appearance.
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          _seg('Percent', value, () => onChanged(true)),
          _seg('Fixed', !value, () => onChanged(false)),
        ],
      ),
    );
  }

  // Helper method for each segment of the toggle.
  Widget _seg(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: active ? Colors.black : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: Colors.black), // <- use provided icon
        ),
      ),
    );
  }
}


class _ServiceOption {
  final int id;
  final String name;
  const _ServiceOption({required this.id, required this.name});
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14));
}
