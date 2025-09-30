import 'package:flutter/material.dart';

class CancellationPolicyCard extends StatelessWidget {
  final TextEditingController freeHController;
  final TextEditingController feePctController;
  final TextEditingController noRefHController;

  const CancellationPolicyCard({
    super.key,
    required this.freeHController,
    required this.feePctController,
    required this.noRefHController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cancellation Policy',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              '• Free cancellation until X hours before the appointment.\n'
              '• Between X and Y hours, a fee (%) is charged.\n'
              '• Within Y hours, no refund.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _numField(
                    label: 'Free cancel (hrs)',
                    controller: freeHController,
                    suffix: 'h',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numField(
                    label: 'Fee (%)',
                    controller: feePctController,
                    suffix: '%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _numField(
              label: 'No refund within (hrs)',
              controller: noRefHController,
              suffix: 'h',
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField({
    required String label,
    required TextEditingController controller,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            suffixText: suffix,
            isDense: true,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            final n = int.tryParse(v.trim());
            if (n == null) return 'Invalid number';
            if (label.contains('Fee') && (n < 0 || n > 100)) {
              return '0–100 only';
            }
            if (n < 0) return 'Must be ≥ 0';
            return null;
          },
        ),
      ],
    );
  }
}
