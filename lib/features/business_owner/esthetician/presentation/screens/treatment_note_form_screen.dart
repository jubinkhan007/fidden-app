import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import '../../controller/treatment_notes_controller.dart';
import '../../data/esthetician_models.dart';

/// Form screen for creating/editing treatment notes
class TreatmentNoteFormScreen extends StatefulWidget {
  final TreatmentNote? existingNote;

  const TreatmentNoteFormScreen({super.key, this.existingNote});

  @override
  State<TreatmentNoteFormScreen> createState() =>
      _TreatmentNoteFormScreenState();
}

class _TreatmentNoteFormScreenState extends State<TreatmentNoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Selection
  int? _selectedClientId;
  String? _selectedClientName;
  int? _selectedBookingId;

  // Form fields
  String _treatmentType = 'facial';
  final _productsUsedController = TextEditingController();
  final _observationsController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _nextNotesController = TextEditingController();
  final _beforePhotoController = TextEditingController();
  final _afterPhotoController = TextEditingController();

  bool get _isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final n = widget.existingNote!;
      _selectedClientId = n.clientId;
      _selectedClientName = n.clientName;
      _selectedBookingId = n.bookingId;
      _treatmentType = n.treatmentType;
      _productsUsedController.text = n.productsUsed ?? '';
      _observationsController.text = n.observations ?? '';
      _recommendationsController.text = n.recommendations ?? '';
      _nextNotesController.text = n.nextAppointmentNotes ?? '';
      _beforePhotoController.text = n.beforePhotoUrl ?? '';
      _afterPhotoController.text = n.afterPhotoUrl ?? '';
    }
  }

  @override
  void dispose() {
    _productsUsedController.dispose();
    _observationsController.dispose();
    _recommendationsController.dispose();
    _nextNotesController.dispose();
    _beforePhotoController.dispose();
    _afterPhotoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Treatment Note' : 'New Treatment Note'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _saveNote,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking selector
              if (!_isEditing) ...[
                _buildSectionTitle('Select Booking'),
                _buildBookingSelector(),
                const SizedBox(height: 24),
              ],

              // Treatment type
              _buildSectionTitle('Treatment Type'),
              _buildTreatmentTypeDropdown(),
              const SizedBox(height: 24),

              // Products used
              _buildSectionTitle('Products Used'),
              _buildTextField(
                controller: _productsUsedController,
                label: 'Products Used',
                hint: 'List products used during treatment',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Observations
              _buildSectionTitle('Observations'),
              _buildTextField(
                controller: _observationsController,
                label: 'Observations',
                hint: 'Skin condition, concerns noticed',
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Recommendations
              _buildSectionTitle('Recommendations'),
              _buildTextField(
                controller: _recommendationsController,
                label: 'Recommendations',
                hint: 'Homecare advice, products to use',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nextNotesController,
                label: 'Next Appointment Notes',
                hint: 'What to focus on next time',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Photo URLs
              _buildSectionTitle('Before/After Photos (URL)'),
              _buildTextField(
                controller: _beforePhotoController,
                label: 'Before Photo URL',
                hint: 'https://...',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _afterPhotoController,
                label: 'After Photo URL',
                hint: 'https://...',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildBookingSelector() {
    return InkWell(
      onTap: _showBookingPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedClientName ?? 'Select a booking',
                    style: TextStyle(
                      color: _selectedClientName != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                  if (_selectedBookingId != null)
                    Text(
                      'Booking #$_selectedBookingId',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showBookingPicker() {
    final boController = Get.find<BusinessOwnerController>();
    final bookings = boController.allBusinessOwnerBookingOne.value.results;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Booking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // List
            Expanded(
              child: bookings.isEmpty
                  ? const Center(child: Text('No bookings found'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final b = bookings[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              (b.userName?[0] ?? 'C').toUpperCase(),
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                          ),
                          title: Text(b.userName ?? b.userEmail),
                          subtitle: Text(b.serviceTitle),
                          onTap: () {
                            setState(() {
                              _selectedClientId = b.user;
                              _selectedClientName = b.userName ?? b.userEmail;
                              _selectedBookingId = b.id;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _treatmentType,
        decoration: const InputDecoration(border: InputBorder.none),
        items: TreatmentType.values
            .map(
              (t) => DropdownMenuItem(value: t.value, child: Text(t.display)),
            )
            .toList(),
        onChanged: (v) => setState(() => _treatmentType = v ?? 'facial'),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    if (!_isEditing && _selectedClientId == null) {
      Get.snackbar('Error', 'Please select a booking');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = Get.find<TreatmentNotesController>();
      final data = {
        'client': _selectedClientId ?? widget.existingNote!.clientId,
        'booking': _selectedBookingId ?? widget.existingNote!.bookingId,
        'treatment_type': _treatmentType,
        'products_used': _productsUsedController.text.trim(),
        'observations': _observationsController.text.trim(),
        'recommendations': _recommendationsController.text.trim(),
        'next_appointment_notes': _nextNotesController.text.trim(),
        'before_photo_url': _beforePhotoController.text.trim(),
        'after_photo_url': _afterPhotoController.text.trim(),
      };

      final isEditing = _isEditing;
      if (isEditing) {
        await controller.updateNote(widget.existingNote!.id, data);
      } else {
        await controller.createNote(data);
      }

      // Navigate back first, then show snackbar
      Get.back();

      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar(
          'Success',
          isEditing
              ? 'Treatment note updated successfully'
              : 'Treatment note created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
