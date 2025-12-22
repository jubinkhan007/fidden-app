import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import '../../controller/massage_client_profile_controller.dart';
import '../../data/massage_models.dart';

/// Form screen for creating/editing massage client profiles
class MassageClientProfileFormScreen extends StatefulWidget {
  final MassageClientProfile? existingProfile;
  const MassageClientProfileFormScreen({super.key, this.existingProfile});

  @override
  State<MassageClientProfileFormScreen> createState() =>
      _MassageClientProfileFormScreenState();
}

class _MassageClientProfileFormScreenState
    extends State<MassageClientProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  int? _selectedClientId;
  String? _selectedClientName;

  String _pressurePreference = 'medium';
  final _areasOfConcernController = TextEditingController();
  final _areasToAvoidController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _currentMedicationsController = TextEditingController();
  final _injuriesHistoryController = TextEditingController();
  final _notesController = TextEditingController();

  bool get _isEditing => widget.existingProfile != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.existingProfile!;
      _selectedClientId = p.clientId;
      _selectedClientName = p.clientName;
      _pressurePreference = p.pressurePreference;
      _areasOfConcernController.text = p.areasOfConcern ?? '';
      _areasToAvoidController.text = p.areasToAvoid ?? '';
      _medicalConditionsController.text = p.medicalConditions ?? '';
      _currentMedicationsController.text = p.currentMedications ?? '';
      _injuriesHistoryController.text = p.injuriesHistory ?? '';
      _notesController.text = p.notes ?? '';
    }
  }

  @override
  void dispose() {
    _areasOfConcernController.dispose();
    _areasToAvoidController.dispose();
    _medicalConditionsController.dispose();
    _currentMedicationsController.dispose();
    _injuriesHistoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'New Client Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _saveProfile,
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
                _buildSectionTitle('Select Client'),
                _buildClientSelector(),
                const SizedBox(height: 24),
              ],

              _buildSectionTitle('Pressure Preference'),
              _buildPressureDropdown(),
              const SizedBox(height: 24),

              _buildSectionTitle('Areas of Focus/Concern'),
              _buildTextField(
                controller: _areasOfConcernController,
                label: 'Areas of Concern',
                hint: 'Lower back, shoulders, neck...',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _areasToAvoidController,
                label: 'Areas to Avoid',
                hint: 'Injuries, sensitive areas...',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Medical Information'),
              _buildTextField(
                controller: _medicalConditionsController,
                label: 'Medical Conditions',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _currentMedicationsController,
                label: 'Current Medications',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _injuriesHistoryController,
                label: 'Injuries History',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Notes'),
              _buildTextField(
                controller: _notesController,
                label: 'Additional Notes',
                maxLines: 3,
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

  Widget _buildClientSelector() {
    return InkWell(
      onTap: _showClientPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.indigo[100],
              child: _selectedClientName != null
                  ? Text(
                      _selectedClientName![0].toUpperCase(),
                      style: TextStyle(color: Colors.indigo[800]),
                    )
                  : Icon(Icons.person_add, color: Colors.indigo[800], size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedClientName ?? 'Select a client',
                style: TextStyle(
                  color: _selectedClientName != null
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showClientPicker() {
    final boController = Get.find<BusinessOwnerController>();
    final bookings = boController.allBusinessOwnerBookingOne.value.results;

    final clientsMap = <int, Map<String, String>>{};
    for (final b in bookings) {
      if (!clientsMap.containsKey(b.user)) {
        clientsMap[b.user] = {
          'name': b.userName ?? 'Unknown',
          'email': b.userEmail,
        };
      }
    }

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
              'Select Client',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (clientsMap.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No clients with bookings')),
              )
            else
              ...clientsMap.entries
                  .take(10)
                  .map(
                    (entry) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo[100],
                        child: Text(
                          entry.value['name']![0].toUpperCase(),
                          style: TextStyle(color: Colors.indigo[800]),
                        ),
                      ),
                      title: Text(entry.value['name']!),
                      subtitle: Text(entry.value['email']!),
                      onTap: () {
                        setState(() {
                          _selectedClientId = entry.key;
                          _selectedClientName = entry.value['name'];
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

  Widget _buildPressureDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _pressurePreference,
        decoration: const InputDecoration(border: InputBorder.none),
        items: PressurePreference.values
            .map(
              (t) => DropdownMenuItem(value: t.value, child: Text(t.display)),
            )
            .toList(),
        onChanged: (v) => setState(() => _pressurePreference = v ?? 'medium'),
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

  Future<void> _saveProfile() async {
    if (!_isEditing && _selectedClientId == null) {
      Get.snackbar('Error', 'Please select a client');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = Get.find<MassageClientProfileController>();
      final data = {
        'client': _selectedClientId ?? widget.existingProfile!.clientId,
        'pressure_preference': _pressurePreference,
        'areas_of_concern': _areasOfConcernController.text.trim(),
        'areas_to_avoid': _areasToAvoidController.text.trim(),
        'medical_conditions': _medicalConditionsController.text.trim(),
        'current_medications': _currentMedicationsController.text.trim(),
        'injuries_history': _injuriesHistoryController.text.trim(),
        'notes': _notesController.text.trim(),
      };

      final isEditing = _isEditing;
      if (isEditing) {
        await controller.updateProfile(widget.existingProfile!.id, data);
      } else {
        await controller.createProfile(data);
      }

      // Navigate back first, then show snackbar on the list screen
      Get.back();

      // Show snackbar after a short delay to ensure it shows on the previous screen
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar(
          'Success',
          isEditing
              ? 'Profile updated successfully'
              : 'Profile created successfully',
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
