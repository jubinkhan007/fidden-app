class IdVerificationModel {
  final int id;
  final String clientName;
  final String status; // 'pending', 'verified', 'rejected'
  final String documentUrl;
  final DateTime createdAt;

  IdVerificationModel({
    required this.id,
    required this.clientName,
    required this.status,
    required this.documentUrl,
    required this.createdAt,
  });

  factory IdVerificationModel.fromJson(Map<String, dynamic> json) {
    return IdVerificationModel(
      id: json['id'] ?? 0,
      clientName: json['client_name'] ?? 'Unknown',
      status: json['status'] ?? 'pending',
      documentUrl: json['document_url'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
