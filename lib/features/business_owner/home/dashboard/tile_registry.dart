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
  
  // Barber (Future)
  // ...
}

class TileRegistry {
  static const String _tattooArtist = 'Tattoo Artist';
  // Add other niche strings as needed

  static List<DashboardTileType> getSharedTiles() {
    return [
      DashboardTileType.dailyRevenue,
      DashboardTileType.todaysAppointments,
      DashboardTileType.notifications,
    ];
  }

  static List<DashboardTileType> getTilesForNiche(String niche) {
    switch (niche) {
      case _tattooArtist:
        return [
          DashboardTileType.portfolio,
          DashboardTileType.designRequests,
          DashboardTileType.consentForms,
          DashboardTileType.idVerification,
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
