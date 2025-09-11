// lib/features/business_owner/profile/data/stripe_models.dart

class StripeOnboardingLink {
  final String url;
  StripeOnboardingLink({required this.url});
  factory StripeOnboardingLink.fromJson(Map<String, dynamic> j) =>
      StripeOnboardingLink(url: j['url'] ?? '');
}

class StripeVerifyResponse {
  final String accountId;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final List<String> requirements;
  final bool onboarded;

  StripeVerifyResponse({
    required this.accountId,
    required this.chargesEnabled,
    required this.payoutsEnabled,
    required this.requirements,
    required this.onboarded,
  });

  factory StripeVerifyResponse.fromJson(Map<String, dynamic> j) {
    return StripeVerifyResponse(
      accountId: j['account_id'] ?? '',
      chargesEnabled: j['charges_enabled'] ?? false,
      payoutsEnabled: j['payouts_enabled'] ?? false,
      requirements:
          (j['requirements'] as List?)?.map((e) => e.toString()).toList() ?? [],
      onboarded: j['onboarded'] ?? false,
    );
  }
}
