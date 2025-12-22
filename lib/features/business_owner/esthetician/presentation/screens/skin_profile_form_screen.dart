import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import '../../controller/client_skin_profile_controller.dart';
import '../../data/esthetician_models.dart';

/// Form screen for creating/editing skin profiles
class SkinProfileFormScreen extends StatefulWidget {
  final ClientSkinProfile? existingProfile;

  const SkinProfileFormScreen({super.key, this.existingProfile});

  @override
  State<SkinProfileFormScreen> createState() => _SkinProfileFormScreenState();
}

class _SkinProfileFormScreenState extends State<SkinProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Client selection
  int? _selectedClientId;
  String? _selectedClientName;

  // Form fields
  String _skinType = 'normal';
  final List<String> _primaryConcerns = [];
  final _allergiesController = TextEditingController();
  final _sensitivitiesController = TextEditingController();
  final _currentProductsController = TextEditingController();
  final _regimenNotesController = TextEditingController();
  final _notesController = TextEditingController();

  bool get _isEditing => widget.existingProfile != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.existingProfile!;
      _selectedClientId = p.clientId;
      _selectedClientName = p.clientName;
      _skinType = p.skinType;
      _primaryConcerns.addAll(p.primaryConcerns);
      _allergiesController.text = p.allergies ?? '';
      _sensitivitiesController.text = p.sensitivities ?? '';
      _currentProductsController.text = p.currentProducts ?? '';
      _regimenNotesController.text = p.regimenNotes ?? '';
      _notesController.text = p.notes ?? '';
    }
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _sensitivitiesController.dispose();
    _currentProductsController.dispose();
    _regimenNotesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Skin Profile' : 'New Skin Profile'),
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
              // Client selector (only for new profiles)
              if (!_isEditing) ...[
                _buildSectionTitle('Select Client'),
                _buildClientSelector(),
                const SizedBox(height: 24),
              ],

              // Skin type
              _buildSectionTitle('Skin Type'),
              _buildSkinTypeDropdown(),
              const SizedBox(height: 24),

              // Primary concerns
              _buildSectionTitle('Primary Concerns'),
              _buildConcernsChips(),
              const SizedBox(height: 24),

              // Allergies & Sensitivities
              _buildSectionTitle('Allergies & Sensitivities'),
              _buildTextField(
                controller: _allergiesController,
                label: 'Allergies',
                hint: 'e.g., Salicylic acid, Retinol',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _sensitivitiesController,
                label: 'Sensitivities',
                hint: 'e.g., Fragrance, Essential oils',
              ),
              const SizedBox(height: 24),

              // Current products
              _buildSectionTitle('Current Products'),
              _buildTextField(
                controller: _currentProductsController,
                label: 'Products currently using',
                hint: 'e.g., CeraVe, The Ordinary Niacinamide',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Notes
              _buildSectionTitle('Notes'),
              _buildTextField(
                controller: _regimenNotesController,
                label: 'Regimen Notes',
                hint: 'Recommendations for skincare regimen',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
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
              backgroundColor: Colors.teal[100],
              child: _selectedClientName != null
                  ? Text(
                      _selectedClientName![0].toUpperCase(),
                      style: TextStyle(color: Colors.teal[800]),
                    )
                  : Icon(Icons.person_add, color: Colors.teal[800], size: 20),
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

    // Extract unique clients
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
                        backgroundColor: Colors.teal[100],
                        child: Text(
                          entry.value['name']![0].toUpperCase(),
                          style: TextStyle(color: Colors.teal[800]),
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

  Widget _buildSkinTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _skinType,
        decoration: const InputDecoration(border: InputBorder.none),
        items: SkinType.values
            .map(
              (t) => DropdownMenuItem(value: t.value, child: Text(t.display)),
            )
            .toList(),
        onChanged: (v) => setState(() => _skinType = v ?? 'normal'),
      ),
    );
  }

  Widget _buildConcernsChips() {
    final concerns = [
      'Acne',
      'Aging',
      'Pigmentation',
      'Dryness',
      'Oiliness',
      'Redness',
      'Sensitivity',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: concerns.map((concern) {
        final selected = _primaryConcerns.contains(concern.toLowerCase());
        return FilterChip(
          label: Text(concern),
          selected: selected,
          onSelected: (val) {
            setState(() {
              if (val) {
                _primaryConcerns.add(concern.toLowerCase());
              } else {
                _primaryConcerns.remove(concern.toLowerCase());
              }
            });
          },
          selectedColor: Colors.teal[100],
          checkmarkColor: Colors.teal[800],
        );
      }).toList(),
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
      final controller = Get.find<ClientSkinProfileController>();
      final data = {
        'client': _selectedClientId ?? widget.existingProfile!.clientId,
        'skin_type': _skinType,
        'primary_concerns': _primaryConcerns,
        'allergies': _allergiesController.text.trim(),
        'sensitivities': _sensitivitiesController.text.trim(),
        'current_products': _currentProductsController.text.trim(),
        'regimen_notes': _regimenNotesController.text.trim(),
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
