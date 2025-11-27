import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/business_owner_controller.dart';
import 'niche_layout_strategy.dart';
import 'default_layout.dart';
import '../../nav_bar/controllers/user_nav_bar_controller.dart';
import '../../../../core/utils/constants/app_sizes.dart';

class TattooArtistLayout implements NicheLayoutStrategy {
  // We can reuse the DefaultLayout instance to avoid code duplication for common sections
  final DefaultLayout _defaultLayout = DefaultLayout();

  @override
  List<Widget> buildContent(BuildContext context, BusinessOwnerController controller) {
    // 1. Get common sections
    // We'll rebuild them here to insert the tattoo section in the middle
    // Ideally, we'd have granular methods, but for now let's reconstruct the list
    
    return [
      // --- Common: Services ---
      _defaultLayout.buildContent(context, controller)[0], // Services Section
      
      const SizedBox(height: 24),
      
      // --- Common: Dashboard Link ---
      _defaultLayout.buildContent(context, controller)[2], // Dashboard Title
      const SizedBox(height: 16),
      
      // --- Common: Stats Cards ---
      _defaultLayout.buildContent(context, controller)[4], // Stats Row
      
      const SizedBox(height: 24),
      
      // --- Common: Revenue Chart ---
      _defaultLayout.buildContent(context, controller)[6], // Revenue Title
      const SizedBox(height: 16),
      _defaultLayout.buildContent(context, controller)[8], // Revenue Chart
      
      SizedBox(height: getHeight(24)),
      
      // --- Common: Booking Stats ---
      _defaultLayout.buildContent(context, controller)[10], // Booking Stats Title
      const SizedBox(height: 16),
      _defaultLayout.buildContent(context, controller)[12], // Booking Stats Widget
      
      const SizedBox(height: 24),
      
      // --- Common: Growth Suggestions ---
      _defaultLayout.buildContent(context, controller)[14], // Growth Suggestions
      
      // --- NICHE SPECIFIC: Tattoo Tools ---
      const SizedBox(height: 24),
      _buildSectionTitle("Tattoo Artist Tools"),
      const SizedBox(height: 16),
      _buildTattooQuickActions(),
      
      const SizedBox(height: 24),
      
      // --- Common: Recent Bookings ---
      _defaultLayout.buildContent(context, controller)[16], // Recent Bookings Title
      const SizedBox(height: 16),
      _defaultLayout.buildContent(context, controller)[18], // Recent Bookings List
    ];
  }
  
  // Helper to match DefaultLayout's title style
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// Quick action cards for tattoo artists
  Widget _buildTattooQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.photo_library,
            label: 'Portfolio',
            onTap: () {
              // Navigate to portfolio tab
              Get.find<BusinessOwnerNavBarController>().changeIndex(3); // Assuming Portfolio is index 3 or similar
              // Or if it's a sub-screen:
              // Get.to(() => const PortfolioScreen());
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.design_services,
            label: 'Design Requests',
            onTap: () {
               // Navigate to design requests
               // For now, just snackbar or navigate if route exists
               Get.snackbar('Design Requests', 'Feature coming soon');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
