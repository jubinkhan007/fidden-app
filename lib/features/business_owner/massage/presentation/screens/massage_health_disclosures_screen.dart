import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/massage_health_disclosure_controller.dart';
import '../../data/massage_models.dart';

/// Screen displaying massage health disclosures
class MassageHealthDisclosuresScreen extends StatelessWidget {
  const MassageHealthDisclosuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MassageHealthDisclosureController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Health Disclosures'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value)
          return const Center(child: CircularProgressIndicator());
        if (controller.errorMessage.isNotEmpty)
          return Center(child: Text(controller.errorMessage.value));

        final disclosures = controller.disclosures;
        if (disclosures.isEmpty)
          return const Center(child: Text('No health disclosures found'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: disclosures.length,
          itemBuilder: (context, index) =>
              _DisclosureCard(disclosure: disclosures[index]),
        );
      }),
    );
  }
}

class _DisclosureCard extends StatelessWidget {
  final MassageHealthDisclosure disclosure;
  const _DisclosureCard({required this.disclosure});

  @override
  Widget build(BuildContext context) {
    final hasAlert =
        disclosure.hasMedicalConditions || disclosure.pregnantOrNursing;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasAlert
            ? BorderSide(color: Colors.red[200]!, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showDetailSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: hasAlert
                        ? Colors.red[50]
                        : Colors.indigo[50],
                    child: Icon(
                      hasAlert ? Icons.warning : Icons.check_circle,
                      color: hasAlert ? Colors.red : Colors.indigo,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          disclosure.clientName ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Booking #${disclosure.bookingId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (disclosure.acknowledged)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Acknowledged',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                ],
              ),
              if (hasAlert) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (disclosure.hasMedicalConditions)
                      _buildTag('Has Conditions', Colors.orange),
                    if (disclosure.pregnantOrNursing)
                      _buildTag('Pregnant/Nursing', Colors.pink),
                    if (disclosure.allergies != null &&
                        disclosure.allergies!.isNotEmpty)
                      _buildTag('Allergies', Colors.red),
                    if (disclosure.areasToAvoid != null &&
                        disclosure.areasToAvoid!.isNotEmpty)
                      _buildTag('Areas to Avoid', Colors.purple),
                  ],
                ),
              ],
              if (disclosure.pressurePreference.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.tune, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Pressure: ${disclosure.pressureDisplay ?? disclosure.pressurePreference}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                disclosure.clientName ?? 'Health Disclosure',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _detailRow(
                'Has Medical Conditions',
                disclosure.hasMedicalConditions ? 'Yes' : 'No',
              ),
              if (disclosure.conditionsDetail != null)
                _detailRow('Conditions', disclosure.conditionsDetail!),
              _detailRow('Current Medications', disclosure.currentMedications),
              _detailRow('Allergies', disclosure.allergies),
              _detailRow(
                'Pregnant/Nursing',
                disclosure.pregnantOrNursing ? 'Yes' : 'No',
              ),
              _detailRow('Recent Surgeries', disclosure.recentSurgeries),
              _detailRow('Pressure Preference', disclosure.pressureDisplay),
              _detailRow('Areas to Avoid', disclosure.areasToAvoid),
              _detailRow('Areas to Focus', disclosure.areasToFocus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
