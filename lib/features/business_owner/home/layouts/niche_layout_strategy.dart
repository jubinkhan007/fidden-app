import 'package:flutter/material.dart';
import '../controller/business_owner_controller.dart';
import 'tattoo_artist_layout.dart';
import 'default_layout.dart';

/// Abstract strategy for building dashboard content
abstract class NicheLayoutStrategy {
  List<Widget> buildContent(BuildContext context, BusinessOwnerController controller);
}

/// Factory to get the correct layout strategy based on niche
class NicheLayoutFactory {
  static NicheLayoutStrategy getLayout(String niche) {
    switch (niche) {
      case 'tattoo_artist':
        return TattooArtistLayout();
      case 'barber':
        // return BarberLayout(); // To be implemented
        return DefaultLayout(); // Placeholder
      default:
        return DefaultLayout();
    }
  }
}
