// This class will parse the response from `/subscriptions/details/`
class CurrentSubscription {
  final SubscriptionPlan plan;
  final String status;
  final DateTime? renewsOn;
  final String commissionRate;

  CurrentSubscription({
    required this.plan,
    required this.status,
    this.renewsOn,
    required this.commissionRate,
  });

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    return CurrentSubscription(
      plan: SubscriptionPlan.fromJson(json['plan']),
      status: json['status'],
      renewsOn: json['renews_on'] != null ? DateTime.parse(json['renews_on']) : null,
      commissionRate: json['commission_rate'],
    );
  }
}

// This class is used for both the current plan and the list of all plans
class SubscriptionPlan {
  final int id;
  final String name;
  final String monthlyPrice;
  final String commissionRate;
  final String depositCustomization;
  final bool priorityMarketplaceRanking;
  final bool advancedCalendarTools;
  final bool autoFollowups;
  final String aiAssistant;
  final String performanceAnalytics;
  final bool ghostClientReEngagement;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.commissionRate,
    required this.depositCustomization,
    required this.priorityMarketplaceRanking,
    required this.advancedCalendarTools,
    required this.autoFollowups,
    required this.aiAssistant,
    required this.performanceAnalytics,
    required this.ghostClientReEngagement,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      monthlyPrice: json['monthly_price'],
      commissionRate: json['commission_rate'],
      depositCustomization: json['deposit_customization'],
      priorityMarketplaceRanking: json['priority_marketplace_ranking'],
      advancedCalendarTools: json['advanced_calendar_tools'],
      autoFollowups: json['auto_followups'],
      aiAssistant: json['ai_assistant'],
      performanceAnalytics: json['performance_analytics'],
      ghostClientReEngagement: json['ghost_client_reengagement'] ?? false,
    );
  }
}