import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/style_request_controller.dart';
import '../../data/style_request_model.dart';
import '../../../../user/design_requests/data/client_design_request_model.dart';

class StyleRequestsScreen extends StatelessWidget {
  const StyleRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StyleRequestController());

    return Scaffold(
      appBar: AppBar(title: const Text('Style Requests')),
      body: Obx(() {
        final hasStyleRequests = controller.styleRequests.isNotEmpty;
        final hasDesignRequests = controller.allNailDesignRequests.isNotEmpty;
        final isLoading = controller.isLoading.value;

        if (isLoading && !hasStyleRequests && !hasDesignRequests) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty &&
            !hasStyleRequests &&
            !hasDesignRequests) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.fetchStyleRequests();
                    controller.fetchDesignRequests();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!hasStyleRequests && !hasDesignRequests) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.brush, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'No style requests yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Client style ideas will appear here',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.fetchStyleRequests(),
              controller.fetchDesignRequests(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Design Requests Section (from booking - show ALL, not just pending)
              if (controller.allNailDesignRequests.isNotEmpty) ...[
                const Text(
                  'Design Requests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...controller.allNailDesignRequests.map(
                  (request) => _DesignRequestCard(request: request),
                ),
                const SizedBox(height: 24),
              ],
              // Style Requests Section
              if (controller.styleRequests.isNotEmpty) ...[
                const Text(
                  'Style Requests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...controller.styleRequests.map(
                  (request) => _StyleRequestCard(
                    request: request,
                    onApprove: () => controller.approveRequest(request.id),
                    onDecline: () => controller.declineRequest(request.id),
                    onComplete: () => controller.completeRequest(request.id),
                    isBusy: controller.isBusy(request.id),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

// NEW: Design Request Card for booking-linked design requests
class _DesignRequestCard extends StatelessWidget {
  final ClientDesignRequest request;

  const _DesignRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image gallery
          if (request.images.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: request.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 4,
                      right: index == request.images.length - 1 ? 0 : 4,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(index == 0 ? 16 : 0),
                        topRight: Radius.circular(
                          index == request.images.length - 1 ? 16 : 0,
                        ),
                      ),
                      child: Image.network(
                        request.images[index].imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE4EC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: Color(0xFFE91E8C),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, yyyy').format(request.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDesignStatusBadge(request.status),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  request.description,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Details chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (request.placement.isNotEmpty)
                      _buildChip(Icons.location_on, request.placement),
                    if (request.sizeApprox.isNotEmpty)
                      _buildChip(Icons.straighten, request.sizeApprox),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildDesignStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFF57C00);
        label = 'Pending';
        break;
      case 'approved':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = 'Approved';
        break;
      case 'rejected':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        label = 'Rejected';
        break;
      default:
        bgColor = const Color(0xFFFCE4EC);
        textColor = const Color(0xFFE91E8C);
        label = 'Design';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _StyleRequestCard extends StatelessWidget {
  final StyleRequest request;
  final VoidCallback onApprove;
  final VoidCallback onDecline;
  final VoidCallback onComplete;
  final bool isBusy;

  const _StyleRequestCard({
    required this.request,
    required this.onApprove,
    required this.onDecline,
    required this.onComplete,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image gallery
          if (request.images.isNotEmpty)
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: request.images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                        _showFullImage(context, request.images[index].imageUrl),
                    child: Container(
                      width: 180,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 4,
                        right: index == request.images.length - 1 ? 0 : 4,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(index == 0 ? 16 : 0),
                          topRight: Radius.circular(
                            index == request.images.length - 1 ? 16 : 0,
                          ),
                        ),
                        child: Image.network(
                          request.images[index].imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(Icons.brush, size: 48, color: Color(0xFFE91E8C)),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.userName ?? 'Client',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('MMM d, yyyy').format(request.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(request.status),
                  ],
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  request.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  request.description,
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(height: 12),

                // Details
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (request.nailStyleTypeDisplay != null)
                      _buildChip(Icons.style, request.nailStyleTypeDisplay!),
                    if (request.nailShapeDisplay != null)
                      _buildChip(
                        Icons.panorama_fish_eye,
                        request.nailShapeDisplay!,
                      ),
                    if (request.colorPreference != null)
                      _buildChip(Icons.palette, request.colorPreference!),
                  ],
                ),

                // Actions
                if (request.status == StyleRequestStatus.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isBusy ? null : onDecline,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: isBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isBusy ? null : onApprove,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E8C),
                          ),
                          child: isBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],

                if (request.status == StyleRequestStatus.approved) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF52B788),
                      ),
                      child: isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Mark as Completed'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(StyleRequestStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case StyleRequestStatus.pending:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFF57C00);
        label = 'Pending';
        break;
      case StyleRequestStatus.approved:
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        label = 'Approved';
        break;
      case StyleRequestStatus.declined:
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        label = 'Declined';
        break;
      case StyleRequestStatus.completed:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey[200],
              child: const Icon(Icons.error, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
