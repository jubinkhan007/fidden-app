import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/hairstylist/controller/client_hair_profile_controller.dart';
import 'package:fidden/features/business_owner/hairstylist/data/hairstylist_models.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';

/// Form screen for creating or editing a client hair profile
class HairProfileFormScreen extends StatefulWidget {
  final ClientHairProfile? existingProfile;

  const HairProfileFormScreen({super.key, this.existingProfile});

  @override
  State<HairProfileFormScreen> createState() => _HairProfileFormScreenState();
}

class _HairProfileFormScreenState extends State<HairProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<ClientHairProfileController>();

  // Client selection
  int? _selectedClientId;
  String? _selectedClientName;
  String? _selectedClientEmail;

  // Hair profile fields
  String? _hairType;
  String? _hairTexture;
  String? _hairPorosity;
  String? _naturalColor;
  String? _currentColor;
  final _colorHistoryController = TextEditingController();
  final _chemicalHistoryController = TextEditingController();
  final _scalpConditionController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _preferencesController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditing => widget.existingProfile != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.existingProfile!;
      _selectedClientId = p.clientId;
      _selectedClientName = p.clientName;
      _selectedClientEmail = p.clientEmail;
      _hairType = p.hairType;
      _hairTexture = p.hairTexture;
      _hairPorosity = p.hairPorosity;
      _naturalColor = p.naturalColor;
      _currentColor = p.currentColor;
      _colorHistoryController.text = p.colorHistory ?? '';
      _chemicalHistoryController.text = p.chemicalHistory ?? '';
      _scalpConditionController.text = p.scalpCondition ?? '';
      _allergiesController.text = p.allergies ?? '';
      _preferencesController.text = p.preferences ?? '';
    }
  }

  @override
  void dispose() {
    _colorHistoryController.dispose();
    _chemicalHistoryController.dispose();
    _scalpConditionController.dispose();
    _allergiesController.dispose();
    _preferencesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null && !_isEditing) {
      Get.snackbar('Error', 'Please select a client');
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      if (!_isEditing) 'client': _selectedClientId,
      'hair_type': _hairType,
      'hair_texture': _hairTexture,
      'hair_porosity': _hairPorosity,
      'natural_color': _naturalColor,
      'current_color': _currentColor,
      'color_history': _colorHistoryController.text.trim(),
      'chemical_history': _chemicalHistoryController.text.trim(),
      'scalp_condition': _scalpConditionController.text.trim(),
      'allergies': _allergiesController.text.trim(),
      'preferences': _preferencesController.text.trim(),
    };

    try {
      if (_isEditing) {
        await _controller.updateProfile(widget.existingProfile!.id, data);
        Get.back();
        Get.snackbar('Success', 'Profile updated');
      } else {
        await _controller.createProfile(data);
        Get.back();
        Get.snackbar('Success', 'Profile created');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showClientPicker() {
    final boController = Get.find<BusinessOwnerController>();
    final bookings = boController.allBusinessOwnerBookingOne.value.results;

    // Extract unique clients from bookings
    final clientsMap = <int, Map<String, String>>{};
    for (final b in bookings) {
      if (!clientsMap.containsKey(b.user)) {
        clientsMap[b.user] = {
          'name': b.userName ?? 'Unknown',
          'email': b.userEmail,
        };
      }
    }

    if (clientsMap.isEmpty) {
      Get.snackbar('No Clients', 'No clients have booked with you yet');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Client',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: clientsMap.length,
                itemBuilder: (context, index) {
                  final clientId = clientsMap.keys.elementAt(index);
                  final clientInfo = clientsMap[clientId]!;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown[100],
                      child: Text(
                        (clientInfo['name'] ?? 'C')[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.brown[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(clientInfo['name'] ?? 'Unknown'),
                    subtitle: Text(clientInfo['email'] ?? ''),
                    onTap: () {
                      setState(() {
                        _selectedClientId = clientId;
                        _selectedClientName = clientInfo['name'];
                        _selectedClientEmail = clientInfo['email'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Hair Profile' : 'New Hair Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Client selection (only for new profiles)
            if (!_isEditing) ...[
              _buildSectionTitle('Client'),
              const SizedBox(height: 8),
              _buildClientSelector(),
              const SizedBox(height: 24),
            ],

            // Hair Type
            _buildSectionTitle('Hair Type'),
            const SizedBox(height: 8),
            _buildCard([
              _buildDropdownField(
                label: 'Hair Type (Pattern)',
                value: _hairType,
                items: HairType.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.display),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _hairType = v),
              ),
              _buildDropdownField(
                label: 'Hair Texture',
                value: _hairTexture,
                items: HairTexture.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.display),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _hairTexture = v),
              ),
              _buildDropdownField(
                label: 'Hair Porosity',
                value: _hairPorosity,
                items: HairPorosity.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.display),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _hairPorosity = v),
              ),
            ]),

            const SizedBox(height: 16),

            // Color Info
            _buildSectionTitle('Color Information'),
            const SizedBox(height: 8),
            _buildCard([
              _buildTextField(
                label: 'Natural Color',
                initialValue: _naturalColor,
                onChanged: (v) => _naturalColor = v,
              ),
              _buildTextField(
                label: 'Current Color',
                initialValue: _currentColor,
                onChanged: (v) => _currentColor = v,
              ),
              _buildTextField(
                label: 'Color History',
                controller: _colorHistoryController,
                maxLines: 2,
              ),
            ]),

            const SizedBox(height: 16),

            // Treatment History
            _buildSectionTitle('Treatment History'),
            const SizedBox(height: 8),
            _buildCard([
              _buildTextField(
                label: 'Chemical History (relaxers, perms, etc.)',
                controller: _chemicalHistoryController,
                maxLines: 2,
              ),
              _buildTextField(
                label: 'Scalp Condition',
                controller: _scalpConditionController,
              ),
            ]),

            const SizedBox(height: 16),

            // Notes
            _buildSectionTitle('Allergies & Preferences'),
            const SizedBox(height: 8),
            _buildCard([
              _buildTextField(
                label: 'Allergies',
                controller: _allergiesController,
                maxLines: 2,
              ),
              _buildTextField(
                label: 'Preferences',
                controller: _preferencesController,
                maxLines: 2,
              ),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildClientSelector() {
    return GestureDetector(
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
              backgroundColor: _selectedClientId != null
                  ? Colors.brown[100]
                  : Colors.grey[200],
              child: Icon(
                Icons.person,
                color: _selectedClientId != null
                    ? Colors.brown[800]
                    : Colors.grey[400],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _selectedClientId != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedClientName ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (_selectedClientEmail != null)
                          Text(
                            _selectedClientEmail!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    )
                  : Text(
                      'Select a client',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
