import 'package:get/get.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'tile_registry.dart';

class DashboardController extends GetxController {
  final ProfileController _profileController = Get.find<ProfileController>();

  // Selected chip (e.g., "All", "Barber", "Tattoo Artist")
  final RxString selectedChip = 'All'.obs;
  
  // Reactive list of available chips - this will trigger UI updates
  final RxList<String> availableChips = <String>['All'].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize chips from current profile
    _updateChipsFromProfile();
    
    // Listen to shopNiches changes and update chips reactively
    ever(_profileController.shopNiches, (_) {
      _updateChipsFromProfile();
    });
  }

  void _updateChipsFromProfile() {
    final niches = _profileController.shopNiches;
    if (niches.isEmpty) {
      availableChips.value = ['All'];
    } else {
      availableChips.value = ['All', ...niches.map((e) => e.trim())];
    }
  }
  
  /// Call this to force refresh chips (e.g., after updating niches)
  void refreshChips() {
    _updateChipsFromProfile();
  }

  // Get ordered list of tile types based on selection
  List<DashboardTileType> get visibleTiles {
    final primary = _profileController.shopNiche.value; // Primary niche
    final allNiches = _profileController.shopNiches;
    final selection = selectedChip.value;

    // 1. Get all relevant tiles
    final Set<DashboardTileType> tiles = {};

    // Always include shared tiles
    tiles.addAll(TileRegistry.getSharedTiles());

    // Add tiles for all user's niches
    for (final niche in allNiches) {
      tiles.addAll(TileRegistry.getTilesForNiche(niche));
    }

    // 2. Sort/Prioritize
    final List<DashboardTileType> sorted = tiles.toList();

    if (selection == 'All') {
      // "All" View: Primary Niche -> Shared -> Other Niches
      sorted.sort((a, b) {
        final aIsPrimary = TileRegistry.isTileForNiche(a, primary);
        final bIsPrimary = TileRegistry.isTileForNiche(b, primary);
        final aIsShared = TileRegistry.isShared(a);
        final bIsShared = TileRegistry.isShared(b);

        if (aIsPrimary && !bIsPrimary) return -1;
        if (!aIsPrimary && bIsPrimary) return 1;
        if (aIsShared && !bIsShared) return -1;
        if (!aIsShared && bIsShared) return 1;
        return 0;
      });
    } else {
      // Specific Niche View: Selected Niche -> Shared -> Others
      sorted.sort((a, b) {
        final aIsSelected = TileRegistry.isTileForNiche(a, selection);
        final bIsSelected = TileRegistry.isTileForNiche(b, selection);
        final aIsShared = TileRegistry.isShared(a);
        final bIsShared = TileRegistry.isShared(b);

        if (aIsSelected && !bIsSelected) return -1;
        if (!aIsSelected && bIsSelected) return 1;
        if (aIsShared && !bIsShared) return -1;
        if (!aIsShared && bIsShared) return 1;
        return 0;
      });
    }

    return sorted;
  }

  void selectChip(String chip) {
    selectedChip.value = chip;
  }
}

