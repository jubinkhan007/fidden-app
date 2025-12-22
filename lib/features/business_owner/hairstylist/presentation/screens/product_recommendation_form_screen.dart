import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/hairstylist/controller/product_recommendation_controller.dart';
import 'package:fidden/features/business_owner/hairstylist/data/hairstylist_models.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';

/// Form screen for creating a product recommendation
class ProductRecommendationFormScreen extends StatefulWidget {
  const ProductRecommendationFormScreen({super.key});

  @override
  State<ProductRecommendationFormScreen> createState() =>
      _ProductRecommendationFormScreenState();
}

class _ProductRecommendationFormScreenState
    extends State<ProductRecommendationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<ProductRecommendationController>();

  // Client selection
  int? _selectedClientId;
  String? _selectedClientName;

  // Form fields
  final _productNameController = TextEditingController();
  final _brandController = TextEditingController();
  String? _category;
  final _notesController = TextEditingController();
  final _purchaseLinkController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _productNameController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    _purchaseLinkController.dispose();
    super.dispose();
  }

  Future<void> _saveRecommendation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      Get.snackbar('Error', 'Please select a client');
      return;
    }
    if (_productNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Product name is required');
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'client': _selectedClientId,
      'product_name': _productNameController.text.trim(),
      'brand': _brandController.text.trim(),
      'category': _category ?? 'other',
      'notes': _notesController.text.trim(),
      'purchase_link': _purchaseLinkController.text.trim(),
    };

    try {
      await _controller.createRecommendation(data);
      Get.back();
      Get.snackbar('Success', 'Recommendation added');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        title: const Text('Add Product Recommendation'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRecommendation,
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
            // Client selection
            _buildSectionTitle('Client'),
            const SizedBox(height: 8),
            _buildClientSelector(),

            const SizedBox(height: 24),

            // Product info
            _buildSectionTitle('Product Details'),
            const SizedBox(height: 8),
            _buildCard([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: TextFormField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: HairProductCategory.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.value,
                          child: Text(e.display),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v),
                ),
              ),
            ]),

            const SizedBox(height: 16),

            // Notes & Link
            _buildSectionTitle('Additional Info'),
            const SizedBox(height: 8),
            _buildCard([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Instructions',
                    border: OutlineInputBorder(),
                    hintText: 'How to use, when to apply, etc.',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: TextFormField(
                  controller: _purchaseLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Purchase Link (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                ),
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
                  ? Text(
                      _selectedClientName ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
}
