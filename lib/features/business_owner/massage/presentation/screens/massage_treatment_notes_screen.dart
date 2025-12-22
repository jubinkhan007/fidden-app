import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/massage_treatment_notes_controller.dart';
import '../../data/massage_models.dart';
import 'massage_treatment_note_form_screen.dart';

/// Screen displaying massage treatment notes
class MassageTreatmentNotesScreen extends StatelessWidget {
  const MassageTreatmentNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MassageTreatmentNotesController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Treatment Notes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value)
          return const Center(child: CircularProgressIndicator());
        if (controller.errorMessage.isNotEmpty)
          return Center(child: Text(controller.errorMessage.value));

        final notes = controller.notes;
        if (notes.isEmpty)
          return const Center(child: Text('No treatment notes found'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index) => _NoteCard(note: notes[index]),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const MassageTreatmentNoteFormScreen());
          controller.fetchNotes();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final MassageTreatmentNote note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.clientName ?? 'Client',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          note.serviceTitle ??
                              note.treatmentTypeDisplay ??
                              note.treatmentType,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          note.treatmentTypeDisplay ?? note.treatmentType,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          note.pressureUsed.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.indigo[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (note.areasWorked != null && note.areasWorked!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.spa, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Areas: ${note.areasWorked}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    note.bookingDate != null
                        ? dateFormat.format(note.bookingDate!)
                        : dateFormat.format(note.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
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
              const Text(
                'Treatment Note',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _detailRow('Client', note.clientName),
              _detailRow('Service', note.serviceTitle),
              _detailRow('Treatment Type', note.treatmentTypeDisplay),
              _detailRow('Pressure Used', note.pressureUsed),
              _detailRow('Areas Worked', note.areasWorked),
              _detailRow('Observations', note.observations),
              _detailRow('Recommendations', note.recommendations),
              _detailRow('Next Appointment Notes', note.nextAppointmentNotes),
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
