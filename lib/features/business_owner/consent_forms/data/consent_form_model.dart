class ConsentFormTemplate {
  final int id;
  final int? shopId;
  final String title;
  final String content;
  final bool isDefault;

  ConsentFormTemplate({
    required this.id,
    this.shopId,
    required this.title,
    required this.content,
    required this.isDefault,
  });

  factory ConsentFormTemplate.fromJson(Map<String, dynamic> json) {
    return ConsentFormTemplate(
      id: json['id'] as int,
      shopId: json['shop'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (shopId != null) 'shop': shopId,
      'title': title,
      'content': content,
      'is_default': isDefault,
    };
  }
}

class SignedConsentForm {
  final int id;
  final int templateId;
  final int? bookingId;
  final User user;
  final String signatureUrl;
  final DateTime signedAt;

  SignedConsentForm({
    required this.id,
    required this.templateId,
    this.bookingId,
    required this.user,
    required this.signatureUrl,
    required this.signedAt,
  });

  factory SignedConsentForm.fromJson(Map<String, dynamic> json) {
    return SignedConsentForm(
      id: json['id'] as int,
      templateId: json['template'] as int,
      bookingId: json['booking'] as int?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      signatureUrl: json['signature_image'] as String,
      signedAt: DateTime.parse(json['signed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template': templateId,
      if (bookingId != null) 'booking': bookingId,
      'user': user.toJson(),
      'signature_image': signatureUrl,
      'signed_at': signedAt.toIso8601String(),
    };
  }
}

// Reusing User model from design_request_model.dart
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
