import 'package:flutter/material.dart';
import '../../design_requests/data/design_request_model.dart';

/// Compact design request card for dashboard
class DashboardDesignRequestCard extends StatelessWidget {
  final DesignRequest request;
  final VoidCallback? onTap;

  const DashboardDesignRequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  Color _getStatusColor() {
    if (request.isPending) return const Color(0xFFFB8500);
    if (request.isApproved) return const Color(0xFF52B788);
    return const Color(0xFFE63946);
  }

  String _getStatusText() {
    if (request.isPending) return 'Pending';
    if (request.isApproved) return 'Approved';
    return 'Rejected';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: request.designImages.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  request.designImages.first,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              )
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.design_services, color: Colors.grey),
              ),
        title: Text(
          request.designDescription.length > 40
              ? '${request.designDescription.substring(0, 40)}...'
              : request.designDescription,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'By ${request.customerName}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical:6),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ),
      ),
    );
  }
}
