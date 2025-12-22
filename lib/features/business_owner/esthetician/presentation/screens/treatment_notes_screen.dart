import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/treatment_notes_controller.dart';
import '../../data/esthetician_models.dart';
import 'treatment_note_form_screen.dart';

/// Screen displaying treatment notes
class TreatmentNotesScreen extends StatelessWidget {
  const TreatmentNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TreatmentNotesController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Treatment Notes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final notes = controller.notes;
        if (notes.isEmpty) {
          return const Center(child: Text('No treatment notes found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return _NoteCard(note: note);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const TreatmentNoteFormScreen());
          controller.fetchNotes();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final TreatmentNote note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final hasBeforePhoto =
        note.beforePhotoUrl != null && note.beforePhotoUrl!.isNotEmpty;
    final hasAfterPhoto =
        note.afterPhotoUrl != null && note.afterPhotoUrl!.isNotEmpty;
    final hasPhotos = hasBeforePhoto || hasAfterPhoto;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Before/After photos preview
            if (hasPhotos)
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    if (hasBeforePhoto)
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                          ),
                          child: Image.network(
                            note.beforePhotoUrl!,
                            fit: BoxFit.cover,
                            height: 100,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: Text('Before')),
                            ),
                          ),
                        ),
                      ),
                    if (hasAfterPhoto)
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: const Radius.circular(12),
                            topLeft: !hasBeforePhoto
                                ? const Radius.circular(12)
                                : Radius.zero,
                          ),
                          child: Image.network(
                            note.afterPhotoUrl!,
                            fit: BoxFit.cover,
                            height: 100,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: Text('After')),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Content
            Padding(
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
                    ],
                  ),

                  if (note.observations != null &&
                      note.observations!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      note.observations!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[500],
                      ),
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
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    final hasBeforePhoto =
        note.beforePhotoUrl != null && note.beforePhotoUrl!.isNotEmpty;
    final hasAfterPhoto =
        note.afterPhotoUrl != null && note.afterPhotoUrl!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
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

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Treatment Note',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Edit button
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context); // Close sheet
                      Get.to(
                        () => TreatmentNoteFormScreen(existingNote: note),
                      )?.then((_) {
                        Get.find<TreatmentNotesController>().fetchNotes();
                      });
                    },
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit',
                  ),
                  // Delete button
                  IconButton(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Before/After photos
              if (hasBeforePhoto || hasAfterPhoto) ...[
                Row(
                  children: [
                    if (hasBeforePhoto)
                      Expanded(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                note.beforePhotoUrl!,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Before',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    if (hasBeforePhoto && hasAfterPhoto)
                      const SizedBox(width: 12),
                    if (hasAfterPhoto)
                      Expanded(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                note.afterPhotoUrl!,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('After', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              _detailRow('Client', note.clientName),
              _detailRow('Service', note.serviceTitle),
              _detailRow('Treatment Type', note.treatmentTypeDisplay),
              _detailRow('Products Used', note.productsUsed),
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

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Treatment Note'),
        content: Text(
          'Are you sure you want to delete this treatment note for ${note.clientName ?? "this client"}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              Navigator.of(context).pop(); // Close bottom sheet

              try {
                final controller = Get.find<TreatmentNotesController>();
                await controller.deleteNote(note.id);

                Future.delayed(const Duration(milliseconds: 100), () {
                  Get.snackbar(
                    'Success',
                    'Treatment note deleted successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                });
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete treatment note',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
