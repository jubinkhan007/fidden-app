import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/retail_products_controller.dart';
import '../../data/esthetician_models.dart';

/// Form screen for creating/editing retail products
class RetailProductFormScreen extends StatefulWidget {
  final RetailProduct? existingProduct;

  const RetailProductFormScreen({super.key, this.existingProduct});

  @override
  State<RetailProductFormScreen> createState() =>
      _RetailProductFormScreenState();
}

class _RetailProductFormScreenState extends State<RetailProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form fields
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  String _category = 'serum';
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _purchaseLinkController = TextEditingController();
  bool _inStock = true;
  bool _isActive = true;

  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.existingProduct!;
      _nameController.text = p.name;
      _brandController.text = p.brand ?? '';
      _category = p.category;
      _priceController.text = p.price?.toStringAsFixed(2) ?? '';
      _descriptionController.text = p.description ?? '';
      _imageUrlController.text = p.imageUrl ?? '';
      _purchaseLinkController.text = p.purchaseLink ?? '';
      _inStock = p.inStock;
      _isActive = p.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _purchaseLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'New Product'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _saveProduct,
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
              // Basic info
              _buildSectionTitle('Product Information'),
              _buildTextField(
                controller: _nameController,
                label: 'Product Name *',
                hint: 'e.g., Vitamin C Serum',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _brandController,
                label: 'Brand',
                hint: 'e.g., The Ordinary',
              ),
              const SizedBox(height: 24),

              // Category
              _buildSectionTitle('Category'),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),

              // Price
              _buildSectionTitle('Price'),
              _buildTextField(
                controller: _priceController,
                label: 'Price',
                hint: '0.00',
                keyboardType: TextInputType.number,
                prefixText: '\$ ',
              ),
              const SizedBox(height: 24),

              // Description
              _buildSectionTitle('Description'),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // URLs
              _buildSectionTitle('Links'),
              _buildTextField(
                controller: _imageUrlController,
                label: 'Image URL',
                hint: 'https://...',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _purchaseLinkController,
                label: 'Purchase Link',
                hint: 'https://...',
              ),
              const SizedBox(height: 24),

              // Status toggles
              _buildSectionTitle('Status'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('In Stock'),
                      value: _inStock,
                      onChanged: (v) => setState(() => _inStock = v),
                      activeColor: Colors.green,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Active (Visible)'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
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

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _category,
        decoration: const InputDecoration(border: InputBorder.none),
        items: RetailCategory.values
            .map(
              (c) => DropdownMenuItem(value: c.value, child: Text(c.display)),
            )
            .toList(),
        onChanged: (v) => setState(() => _category = v ?? 'serum'),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final controller = Get.find<RetailProductsController>();
      final data = {
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'category': _category,
        'price': _priceController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image_url': _imageUrlController.text.trim(),
        'purchase_link': _purchaseLinkController.text.trim(),
        'in_stock': _inStock,
        'is_active': _isActive,
      };

      if (_isEditing) {
        await controller.updateProduct(widget.existingProduct!.id, data);
        Get.snackbar('Success', 'Product updated');
      } else {
        await controller.createProduct(data);
        Get.snackbar('Success', 'Product created');
      }

      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
