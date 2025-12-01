import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/service_management_controller.dart';

class ServiceCreateScreen extends StatefulWidget {
  const ServiceCreateScreen({super.key});

  @override
  State<ServiceCreateScreen> createState() => _ServiceCreateScreenState();
}

class _ServiceCreateScreenState extends State<ServiceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  int _duration = 30;
  int _category = 1; // Default category

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<ServiceManagementController>();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    controller.createService(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      duration: _duration,
      category: _category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceManagementController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Service'),
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Service Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cut),
                  hintText: 'e.g., Premium Haircut',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter service name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Describe the service details',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '45.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Duration Dropdown
              DropdownButtonFormField<int>(
                value: _duration,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                items: [15, 30, 45, 60, 75, 90, 120].map((minutes) {
                  return DropdownMenuItem(
                    value: minutes,
                    child: Text('$minutes minutes'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _duration = value);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<int>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Haircut')),
                  DropdownMenuItem(value: 2, child: Text('Shaving')),
                  DropdownMenuItem(value: 3, child: Text('Hair Styling')),
                  DropdownMenuItem(value: 4, child: Text('Beard Trim')),
                  DropdownMenuItem(value: 5, child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: controller.isLoading.value ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Service', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
