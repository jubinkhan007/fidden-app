enum DashboardTileType {
  // Shared
  dailyRevenue,
  todaysAppointments,
  notifications,
  
  // Tattoo Artist
  portfolio,
  designRequests,
  consentForms,
  idVerification,
  consultationCalendar,
  depositManagement,
  reviews,
  
  // Barber (Future)
  // ...
}

class TileRegistry {
  static const String _tattooArtist = 'tattoo_artist'; // Matches API value
  // Add other niche strings as needed

  static List<DashboardTileType> getSharedTiles() {
    return [
      DashboardTileType.dailyRevenue,
      DashboardTileType.todaysAppointments,
      DashboardTileType.notifications,
    ];
  }

  static List<DashboardTileType> getTilesForNiche(String niche) {
    // Normalize string just in case (e.g. handle "Tattoo Artist" vs "tattoo_artist")
    final normalized = niche.toLowerCase().replaceAll(' ', '_');
    
    switch (normalized) {
      case _tattooArtist:
        return [
          DashboardTileType.consultationCalendar, // Top Section
          DashboardTileType.idVerification,       // Top Section
          DashboardTileType.todaysAppointments,   // Top Section (Shared, but prioritized here if needed)
          
          // Core Tabs
          DashboardTileType.portfolio,
          DashboardTileType.designRequests,
          DashboardTileType.consentForms,
          DashboardTileType.depositManagement,
          DashboardTileType.reviews,
        ];
      default:
        return [];
    }
  }

  static bool isTileForNiche(DashboardTileType tile, String niche) {
    return getTilesForNiche(niche).contains(tile);
  }

  static bool isShared(DashboardTileType tile) {
    return getSharedTiles().contains(tile);
  }
}
