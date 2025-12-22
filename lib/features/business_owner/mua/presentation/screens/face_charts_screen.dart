import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/face_chart_controller.dart';
import '../../data/mua_models.dart';

/// Face Charts screen for MUA - displays client face charts/lookbook
class FaceChartsScreen extends StatelessWidget {
  const FaceChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FaceChartController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Face Charts'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${controller.count} charts',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(controller),
          
          // Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.faceCharts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty && controller.faceCharts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(controller.errorMessage.value),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.fetchFaceCharts(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.faceCharts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.palette_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'No face charts yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add face charts to showcase your work',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchFaceCharts(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: controller.faceCharts.length,
                  itemBuilder: (context, index) {
                    final chart = controller.faceCharts[index];
                    return _FaceChartCard(
                      chart: chart,
                      onTap: () => _showChartDetail(context, chart),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(FaceChartController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          final selected = controller.selectedLookType.value;
          return Row(
            children: [
              _buildChip('All', selected.isEmpty, () => controller.filterByLookType(null)),
              ...LookType.values.map((type) => _buildChip(
                type.display,
                selected == type.value,
                () => controller.filterByLookType(type.value),
              )),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey.shade100,
        selectedColor: const Color(0xFFB8192E).withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFFB8192E) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showChartDetail(BuildContext context, FaceChart chart) {
    Get.to(() => _FaceChartDetailScreen(chart: chart));
  }
}

class _FaceChartCard extends StatelessWidget {
  final FaceChart chart;
  final VoidCallback onTap;

  const _FaceChartCard({required this.chart, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                chart.thumbnailUrl ?? chart.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.palette, size: 48, color: Colors.grey),
                  ),
                ),
              ),
              // Caption overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (chart.caption != null && chart.caption!.isNotEmpty)
                        Text(
                          chart.caption!,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (chart.lookTypeEnum != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8192E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            chart.lookTypeEnum!.display,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
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

class _FaceChartDetailScreen extends StatelessWidget {
  final FaceChart chart;

  const _FaceChartDetailScreen({required this.chart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          chart.caption ?? 'Face Chart',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Full image
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: Image.network(
                  chart.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          
          // Info panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (chart.clientName != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.person_outline, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(chart.clientName!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (chart.lookTypeEnum != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8192E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(chart.lookTypeEnum!.display, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (chart.description != null && chart.description!.isNotEmpty)
                  Text(chart.description!, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                if (chart.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: chart.tags.map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.grey[800],
                      labelStyle: const TextStyle(color: Colors.white70),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
