import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/client_design_request_controller.dart';
import '../../data/client_design_request_model.dart';

/// Screen showing all design requests for the current user
class MyDesignRequestsScreen extends StatelessWidget {
  const MyDesignRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientDesignRequestController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Design Requests'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.requests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.requests.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchMyRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.requests.length,
            itemBuilder: (context, index) {
              final request = controller.requests[index];
              return _DesignRequestCard(
                request: request,
                onTap: () => _showRequestDetail(context, request, controller),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.brush_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No Design Requests Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you submit a design request to a tattoo artist, it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDetail(
    BuildContext context,
    ClientDesignRequest request,
    ClientDesignRequestController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header with status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Design Request',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _StatusBadge(status: request.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Submitted ${DateFormat('MMM d, yyyy').format(request.createdAt)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(request.description, style: const TextStyle(fontSize: 16)),

                if (request.placement.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Placement',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(request.placement, style: const TextStyle(fontSize: 16)),
                ],

                if (request.sizeApprox.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.sizeApprox,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],

                // Images if any
                if (request.images.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Reference Images',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: request.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              request.images[index].imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Delete button (only for pending)
                if (request.canDelete)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Delete Request?'),
                            content: const Text(
                              'Are you sure you want to delete this design request?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          Navigator.pop(context);
                          await controller.deleteRequest(request.id);
                          Get.snackbar(
                            'Deleted',
                            'Design request deleted',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Delete Request',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesignRequestCard extends StatelessWidget {
  final ClientDesignRequest request;
  final VoidCallback onTap;

  const _DesignRequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.shopName ?? 'Design Request',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusBadge(status: request.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (request.placement.isNotEmpty) ...[
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.placement,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(request.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'pending':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'Pending';
        break;
      case 'approved':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        text = 'Approved';
        break;
      case 'rejected':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        text = 'Rejected';
        break;
      case 'completed':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        text = 'Completed';
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
