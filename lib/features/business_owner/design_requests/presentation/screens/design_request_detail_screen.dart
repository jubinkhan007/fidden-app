import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/design_request_model.dart';
import '../../controller/design_request_controller.dart';
import '../../../../inbox/controller/inbox_controller.dart';
import '../../../../inbox/screens/chat_screen.dart';
import '../../../home/controller/business_owner_controller.dart';

class DesignRequestDetailScreen extends StatelessWidget {
  final DesignRequest request;

  const DesignRequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DesignRequestController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Design Requests'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === REFERENCE IMAGE ===
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: request.images.isNotEmpty
                    ? _buildImageGallery()
                    : _buildPlaceholderImage(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === CUSTOMER INFO ===
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.customerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Requested on ${DateFormat('MMM dd, yyyy').format(request.createdAt)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === REQUEST DETAILS ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Request Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildStatusBadge(request.status),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Details Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          label: 'Placement',
                          value: request.placement.isNotEmpty
                              ? request.placement
                              : 'Not specified',
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          label: 'Size (Approx.)',
                          value: request.sizeApprox.isNotEmpty
                              ? request.sizeApprox
                              : 'Not specified',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === CLIENT NOTES ===
                  const Text(
                    'Client Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF374151),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // === ACTION BUTTONS ===
                  if (request.isPending || request.isDiscussing) ...[
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => _showApproveDialog(context, controller),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE63946),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Approve',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Message Client Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _openChat(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Message Client',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Reject option for pending requests
                  if (request.isPending || request.isDiscussing) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _showRejectDialog(context, controller),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Reject Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (request.images.length == 1) {
      return Image.network(
        request.images.first.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
      );
    }

    // Multiple images - use PageView
    return PageView.builder(
      itemCount: request.images.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              request.images[index].imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
            ),
            // Page indicator
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  request.images.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No reference image',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'pending':
        bgColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        text = 'Pending';
        break;
      case 'discussing':
        bgColor = const Color(0xFFCCE5FF);
        textColor = const Color(0xFF004085);
        text = 'Discussing';
        break;
      case 'approved':
        bgColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF155724);
        text = 'Approved';
        break;
      case 'rejected':
        bgColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF721C24);
        text = 'Rejected';
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDetailItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _openChat(BuildContext context) async {
    // Find the shop details
    final shopId = request.shopId;

    // Get or initialize inbox controller to find existing thread
    final inboxController = Get.put(InboxController());

    // Check if threads are loaded
    if (inboxController.threads.isEmpty) {
      await inboxController.fetchConversations();
    }

    // Find existing thread with this user
    final existingThread = inboxController.threads.firstWhereOrNull(
      (thread) => thread.user == request.userId,
    );

    if (existingThread != null) {
      // Navigate to existing chat
      Get.to(
        () => ChatScreen(
          threadId: existingThread.id,
          shopId: shopId,
          shopName: existingThread.userName ?? request.customerName,
          shopAvatarUrl: existingThread.userImg ?? '',
          isOwner: true,
        ),
      );
    } else {
      // No existing thread - show coming soon or create one
      Get.snackbar(
        'Start Conversation',
        'Send a message to ${request.customerName} to start the conversation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      // Navigate to inbox with hint to start conversation
      // Future: implement direct thread creation
    }
  }

  void _showApproveDialog(
    BuildContext context,
    DesignRequestController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Approve Design Request'),
        content: const Text(
          'Are you sure you want to approve this design request?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.approveRequest(request.id);
              Get.back(); // Close detail screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    DesignRequestController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Design Request'),
        content: const Text(
          'Are you sure you want to reject this design request?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.rejectRequest(request.id);
              Get.back(); // Close detail screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
