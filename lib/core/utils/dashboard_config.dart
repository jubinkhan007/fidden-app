/// Dashboard configuration utility for niche-specific features
/// 
/// This utility provides a centralized way to determine which features
/// should be visible for each shop niche. This makes the code reusable
/// and optimizes performance by avoiding unnecessary widget renders.
/// 
/// Supported niches:
/// - tattoo_artist: Portfolio, Design Requests, Consent Forms, ID Verification
/// - barber, hairstylist, fitness_trainer, nail_tech, makeup_artist, 
///   esthetician, massage_therapist: Future implementations
class DashboardConfig {
  /// Niche constants for type safety
  static const String tattoArtist = 'tattoo_artist';
  static const String barber = 'barber';
  static const String hairstylist = 'hairstylist';
  static const String fitnessTrainer = 'fitness_trainer';
  static const String nailTech = 'nail_tech';
  static const String makeupArtist = 'makeup_artist';
  static const String esthetician = 'esthetician';
  static const String massageTherapist = 'massage_therapist';
  static const String other = 'other';

  /// Portfolio feature (currently tattoo artist only)
  static bool showPortfolioTab(String? niche) {
    if (niche == null) return false;
    return niche == tattoArtist;
  }

  /// Design Requests feature (currently tattoo artist only)
  static bool showDesignRequestsTab(String? niche) {
    if (niche == null) return false;
    return niche == tattoArtist;
  }

  /// Consent Forms feature (currently tattoo artist only)
  static bool showConsentFormsTab(String? niche) {
    if (niche == null) return false;
    return niche == tattoArtist;
  }

  /// ID Verification feature (currently tattoo artist only)
  static bool showIDVerificationTab(String? niche) {
    if (niche == null) return false;
    return niche == tattoArtist;
  }

  /// Get human-readable niche name
  static String getNicheName(String? niche) {
    switch (niche) {
      case tattoArtist:
        return 'Tattoo Artist';
      case barber:
        return 'Barber';
      case hairstylist:
        return 'Hairstylist';
      case fitnessTrainer:
        return 'Fitness Trainer';
      case nailTech:
        return 'Nail Technician';
      case makeupArtist:
        return 'Makeup Artist';
      case esthetician:
        return 'Esthetician';
      case massageTherapist:
        return 'Massage Therapist';
      default:
        return 'Service Provider';
    }
  }

  /// Future: Add more feature flags as other niches are implemented
  /// Example:
  /// static bool showWorkoutPlans(String? niche) => niche == fitnessTrainer;
  /// static bool showProductInventory(String? niche) => niche == nailTech;
}
