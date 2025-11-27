class ConsentFormModel {
  final int id;
  final String title;
  final String status; // 'pending', 'signed'
  final String clientName;
  final DateTime createdAt;
  final String? pdfUrl;

  ConsentFormModel({
    required this.id,
    required this.title,
    required this.status,
    required this.clientName,
    required this.createdAt,
    this.pdfUrl,
  });

  factory ConsentFormModel.fromJson(Map<String, dynamic> json) {
    return ConsentFormModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? 'pending',
      clientName: json['client_name'] ?? 'Unknown',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      pdfUrl: json['pdf_url'],
    );
  }
}
