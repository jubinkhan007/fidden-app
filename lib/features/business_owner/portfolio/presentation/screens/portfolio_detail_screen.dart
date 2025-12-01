import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/portfolio_item_model.dart';
import '../../controller/portfolio_controller.dart';

class PortfolioDetailScreen extends StatefulWidget {
  final PortfolioItem item;

  const PortfolioDetailScreen({super.key, required this.item});

  @override
  State<PortfolioDetailScreen> createState() => _PortfolioDetailScreenState();
}

class _PortfolioDetailScreenState extends State<PortfolioDetailScreen> {
  late TextEditingController _descriptionController;
  late List<String> _tags;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.item.description);
    _tags = List.from(widget.item.tags);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final controller = Get.find<PortfolioController>();
    controller.updatePortfolioItem(
      id: widget.item.id,
      description: _descriptionController.text.trim(),
      tags: _tags,
    );
    setState(() => _isEditing = false);
  }

  void _deleteItem() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Portfolio Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              final controller = Get.find<PortfolioController>();
              controller.deletePortfolioItem(widget.item.id);
              Get.back(); // Close detail screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Detail'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteItem,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Image.network(
              widget.item.imageUrl,
              height: 400,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 400,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 64),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _isEditing
                      ? TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter description...',
                          ),
                        )
                      : Text(
                          widget.item.description.isEmpty 
                              ? 'No description' 
                              : widget.item.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                  
                  const SizedBox(height: 24),
                  
                  // Tags
                  const Text(
                    'Tags',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.isEmpty
                        ? [const Text('No tags', style: TextStyle(color: Colors.grey))]
                        : _tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              deleteIcon: _isEditing ? const Icon(Icons.close, size: 18) : null,
                              onDeleted: _isEditing
                                  ? () => setState(() => _tags.remove(tag))
                                  : null,
                            );
                          }).toList(),
                  ),
                  
                  if (_isEditing) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _descriptionController.text = widget.item.description;
                                _tags = List.from(widget.item.tags);
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Metadata
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Added on: ${widget.item.createdAt.toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'ID: ${widget.item.id}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
