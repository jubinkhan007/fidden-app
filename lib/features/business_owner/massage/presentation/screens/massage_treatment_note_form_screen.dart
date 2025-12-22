import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import '../../controller/massage_treatment_notes_controller.dart';
import '../../data/massage_models.dart';

/// Form screen for creating/editing massage treatment notes
class MassageTreatmentNoteFormScreen extends StatefulWidget {
  final MassageTreatmentNote? existingNote;
  const MassageTreatmentNoteFormScreen({super.key, this.existingNote});

  @override
  State<MassageTreatmentNoteFormScreen> createState() =>
      _MassageTreatmentNoteFormScreenState();
}

class _MassageTreatmentNoteFormScreenState
    extends State<MassageTreatmentNoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  int? _selectedClientId;
  String? _selectedClientName;
  int? _selectedBookingId;

  String _treatmentType = 'swedish';
  String _pressureUsed = 'medium';
  final _areasWorkedController = TextEditingController();
  final _observationsController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _nextNotesController = TextEditingController();

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
      _pressureUsed = n.pressureUsed;
      _areasWorkedController.text = n.areasWorked ?? '';
      _observationsController.text = n.observations ?? '';
      _recommendationsController.text = n.recommendations ?? '';
      _nextNotesController.text = n.nextAppointmentNotes ?? '';
    }
  }

  @override
  void dispose() {
    _areasWorkedController.dispose();
    _observationsController.dispose();
    _recommendationsController.dispose();
    _nextNotesController.dispose();
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
              if (!_isEditing) ...[
                _buildSectionTitle('Select Booking'),
                _buildBookingSelector(),
                const SizedBox(height: 24),
              ],

              _buildSectionTitle('Treatment Type'),
              _buildTreatmentTypeDropdown(),
              const SizedBox(height: 24),

              _buildSectionTitle('Pressure Used'),
              _buildPressureDropdown(),
              const SizedBox(height: 24),

              _buildSectionTitle('Areas Worked'),
              _buildTextField(
                controller: _areasWorkedController,
                label: 'Areas Worked',
                hint: 'Back, shoulders, legs...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Observations'),
              _buildTextField(
                controller: _observationsController,
                label: 'Observations',
                hint: 'Client feedback, tension areas...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Recommendations'),
              _buildTextField(
                controller: _recommendationsController,
                label: 'Recommendations',
                hint: 'Stretches, follow-up care...',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nextNotesController,
                label: 'Next Appointment Notes',
                maxLines: 2,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Booking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (bookings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No bookings found')),
              )
            else
              ...bookings
                  .take(10)
                  .map(
                    (b) => ListTile(
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
        items: MassageTreatmentType.values
            .map(
              (t) => DropdownMenuItem(value: t.value, child: Text(t.display)),
            )
            .toList(),
        onChanged: (v) => setState(() => _treatmentType = v ?? 'swedish'),
      ),
    );
  }

  Widget _buildPressureDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _pressureUsed,
        decoration: const InputDecoration(border: InputBorder.none),
        items: PressurePreference.values
            .map(
              (t) => DropdownMenuItem(value: t.value, child: Text(t.display)),
            )
            .toList(),
        onChanged: (v) => setState(() => _pressureUsed = v ?? 'medium'),
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
      final controller = Get.find<MassageTreatmentNotesController>();
      final data = {
        'client': _selectedClientId ?? widget.existingNote!.clientId,
        'booking': _selectedBookingId ?? widget.existingNote!.bookingId,
        'treatment_type': _treatmentType,
        'pressure_used': _pressureUsed,
        'areas_worked': _areasWorkedController.text.trim(),
        'observations': _observationsController.text.trim(),
        'recommendations': _recommendationsController.text.trim(),
        'next_appointment_notes': _nextNotesController.text.trim(),
      };

      if (_isEditing) {
        await controller.updateNote(widget.existingNote!.id, data);
        Get.snackbar('Success', 'Treatment note updated');
      } else {
        await controller.createNote(data);
        Get.snackbar('Success', 'Treatment note created');
      }

      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
