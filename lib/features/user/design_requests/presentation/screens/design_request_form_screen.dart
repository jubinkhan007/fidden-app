import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/client_design_request_model.dart';
import '../../controller/client_design_request_controller.dart';

/// Form screen for submitting a new design request
class DesignRequestFormScreen extends StatefulWidget {
  final int shopId;
  final String? shopName;
  final String serviceNiche; // 'tattoo_artist' or 'nail_tech'
  final int? bookingId;
  final String? initialDescription;
  final bool returnDataOnly;
  final String? initialPlacement;
  final String? initialSize;

  const DesignRequestFormScreen({
    super.key,
    required this.shopId,
    this.shopName,
    this.serviceNiche =
        'tattoo_artist', // Default to tattoo for backwards compatibility
    this.bookingId,
    this.initialDescription,
    this.returnDataOnly = false,
    this.initialPlacement,
    this.initialSize,
  });

  @override
  State<DesignRequestFormScreen> createState() =>
      _DesignRequestFormScreenState();
}

class _DesignRequestFormScreenState extends State<DesignRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _selectedPlacement;
  String? _selectedSize;
  bool _isSubmitting = false;

  File? _imageFile;

  // Dynamic text based on niche
  bool get _isNail => widget.serviceNiche == 'nail_tech';
  String get _nicheLabel => _isNail ? 'Nail Design' : 'Tattoo';
  String get _artistLabel => _isNail ? 'Nail Technician' : 'Tattoo Artist';
  List<String> get _placementOptions =>
      _isNail ? NailPlacement.options : TattooPlacement.options;
  List<String> get _sizeOptions =>
      _isNail ? NailSize.options : TattooSize.options;
  String get _placementLabel => _isNail ? 'Nail Selection' : 'Body Placement';
  String get _sizeLabel => _isNail ? 'Style & Shape' : 'Approximate Size';

  @override
  void initState() {
    super.initState();
    // Ensure controller is registered if not just returning data
    if (!widget.returnDataOnly &&
        !Get.isRegistered<ClientDesignRequestController>()) {
      Get.put(ClientDesignRequestController());
    }

    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
    _selectedPlacement = widget.initialPlacement;
    _selectedSize = widget.initialSize;
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // embedded mode: return data to caller
    if (widget.returnDataOnly) {
      Get.back(
        result: {
          'description': _descriptionController.text.trim(),
          'placement': _selectedPlacement,
          'size': _selectedSize,
          'image': _imageFile,
          'serviceNiche': widget.serviceNiche, // Include niche for filtering
        },
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = Get.find<ClientDesignRequestController>();
      final request = await controller.submitRequest(
        shopId: widget.shopId,
        description: _descriptionController.text.trim(),
        bookingId: widget.bookingId,
        placement: _selectedPlacement,
        sizeApprox: _selectedSize,
        image: _imageFile,
      );

      if (request != null) {
        Get.back();
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.snackbar(
            'Request Submitted!',
            'Your design request has been sent to the artist.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        });
      } else {
        Get.snackbar(
          'Error',
          controller.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Request a Design'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop info card
              if (widget.shopName != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.brush, color: Colors.purple),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.shopName!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _artistLabel,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Description field
              Text(
                'Describe Your $_nicheLabel Idea *',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: _isNail
                      ? 'Describe your nail design idea in detail...\n\nInclude style preferences, colors, patterns, and any special requests.'
                      : 'Describe your tattoo idea in detail...\n\nInclude style preferences, colors, references, and any special requests.',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your $_nicheLabel idea';
                  }
                  if (value.trim().length < 20) {
                    return 'Please provide more detail (at least 20 characters)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Reference Image
              const Text(
                'Reference Image (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_imageFile != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imageFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setState(() => _imageFile = null),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate, size: 32),
                    label: const Text('Upload Reference Image'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              Text(
                _placementLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPlacement,
                decoration: InputDecoration(
                  hintText: 'Select ${_placementLabel.toLowerCase()}',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                items: _placementOptions.map((placement) {
                  return DropdownMenuItem(
                    value: placement,
                    child: Text(placement),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPlacement = value);
                },
              ),

              const SizedBox(height: 24),

              // Size dropdown
              Text(
                _sizeLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSize,
                decoration: InputDecoration(
                  hintText: 'Select ${_sizeLabel.toLowerCase()}',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                items: _sizeOptions.map((size) {
                  return DropdownMenuItem(value: size, child: Text(size));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSize = value);
                },
              ),

              const SizedBox(height: 16),

              // Booking link info
              if (widget.bookingId != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This request will be linked to your booking #${widget.bookingId}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC143C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Info text
              Text(
                'The artist will review your request and respond. You can track the status in your profile under "My Design Requests".',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
