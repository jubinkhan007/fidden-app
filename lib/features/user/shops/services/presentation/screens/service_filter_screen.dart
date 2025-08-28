// lib/features/user/shops/services/presentation/screens/service_filter_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';

class ServiceFilterScreen extends StatefulWidget {
  const ServiceFilterScreen({
    super.key,
    this.initialCategoryId,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialDuration,
    this.initialDistance,
    this.initialRating,
    this.sliderMin = 0,
    this.sliderMax = 500,
  });

  // 🟢 Initial values coming from your controller
  final int? initialCategoryId;
  final int? initialMinPrice; // slider lower bound
  final int? initialMaxPrice; // slider upper bound
  final int? initialDuration; // 30|60|90|999
  final int? initialDistance; // 30|60|90|999
  final double? initialRating; // 4.5|4.0|3.5

  // Optional slider bounds
  final double sliderMin;
  final double sliderMax;

  @override
  State<ServiceFilterScreen> createState() => _ServiceFilterScreenState();
}

class _ServiceFilterScreenState extends State<ServiceFilterScreen> {
  // --- State ---
  int? selectedCategoryId;
  List<Map<String, dynamic>> categories = [];
  bool loadingCategories = true;

  late RangeValues priceRange;
  int? selectedDuration; // minutes bucket
  int? selectedDistance; // km bucket
  double? selectedRating;

  @override
  void initState() {
    super.initState();

    // 1) Seed state from initial values
    final min = (widget.initialMinPrice ?? widget.sliderMin).toDouble();
    final max = (widget.initialMaxPrice ?? widget.sliderMax).toDouble();

    priceRange = RangeValues(
      min.clamp(widget.sliderMin, widget.sliderMax),
      max.clamp(widget.sliderMin, widget.sliderMax),
    );

    selectedCategoryId = widget.initialCategoryId;
    selectedDuration = widget.initialDuration;
    selectedDistance = widget.initialDistance;
    selectedRating = widget.initialRating;

    // 2) Load categories
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final res = await NetworkCaller().getRequest(
        AppUrls.getCategories,
        token: AuthService.accessToken,
      );
      if (mounted && res.isSuccess && res.responseData is List) {
        final data = res.responseData as List;
        setState(() {
          categories = data
              .map(
                (e) => {
                  "id": e["id"],
                  "name": (e["name"] as String).capitalizeFirst,
                },
              )
              .toList();
        });
      }
    } catch (_) {
      // ignore error silently
    } finally {
      if (mounted) setState(() => loadingCategories = false);
    }
  }

  void _applyFilters() {
    // Build query params to send back
    final filters = <String, dynamic>{
      "category": selectedCategoryId,
      "min_price": priceRange.start.toInt(),
      "max_price": priceRange.end.toInt(),
      "duration": selectedDuration,
      "distance": selectedDistance,
      "rating": selectedRating,
    };

    Navigator.pop(context, filters);
  }

  void _reset() {
    setState(() {
      selectedCategoryId = null;
      priceRange = RangeValues(widget.sliderMin, widget.sliderMax);
      selectedDuration = null;
      selectedDistance = null;
      selectedRating = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter Services"),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        actions: [TextButton(onPressed: _reset, child: const Text("Reset"))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Category ---
          CustomText(
            text: "Category",
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 10),
          if (loadingCategories)
            const Center(child: CircularProgressIndicator())
          else if (categories.isEmpty)
            const Text("No categories found")
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((c) {
                final isSelected = selectedCategoryId == c["id"];
                return ChoiceChip(
                  label: Text(c["name"]),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedCategoryId = isSelected ? null : c["id"] as int?;
                    });
                  },
                );
              }).toList(),
            ),

          const SizedBox(height: 24),

          // --- Price Range ---
          CustomText(
            text:
                "Price Range (\$${priceRange.start.toInt()} - \$${priceRange.end.toInt()})",
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          RangeSlider(
            values: priceRange,
            min: widget.sliderMin,
            max: widget.sliderMax,
            divisions: (widget.sliderMax - widget.sliderMin).toInt(),
            labels: RangeLabels(
              "\$${priceRange.start.toInt()}",
              "\$${priceRange.end.toInt()}",
            ),
            onChanged: (val) => setState(() => priceRange = val),
          ),

          const SizedBox(height: 24),

          // --- Duration ---
          CustomText(
            text: "Duration",
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _durationChip("≤30 min", 30),
              _durationChip("30–60 min", 60),
              _durationChip("60–90 min", 90),
              _durationChip("90+ min", 999),
            ],
          ),

          const SizedBox(height: 24),

          // --- Distance ---
          CustomText(
            text: "Distance",
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _distanceChip("≤30 km", 30),
              _distanceChip("30–60 km", 60),
              _distanceChip("60–90 km", 90),
              _distanceChip("90+ km", 999),
            ],
          ),

          const SizedBox(height: 24),

          // --- Rating ---
          CustomText(text: "Rating", fontSize: 16, fontWeight: FontWeight.w700),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _ratingChip("4.5+", 4.5),
              _ratingChip("4.0+", 4.0),
              _ratingChip("3.5+", 3.5),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _applyFilters,
            child: const Text(
              "Apply Filters",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _durationChip(String label, int value) {
    final isSelected = selectedDuration == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) =>
          setState(() => selectedDuration = isSelected ? null : value),
    );
  }

  Widget _distanceChip(String label, int value) {
    final isSelected = selectedDistance == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) =>
          setState(() => selectedDistance = isSelected ? null : value),
    );
  }

  Widget _ratingChip(String label, double value) {
    final isSelected = selectedRating == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) =>
          setState(() => selectedRating = isSelected ? null : value),
    );
  }
}
