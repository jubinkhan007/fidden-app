// lib/features/user/shops/services/presentation/widgets/provider_selector_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/service_details_controller.dart';

/// Horizontal scrollable provider selector with "Any Available" option
class ProviderSelectorWidget extends StatelessWidget {
  final String? tag; // NEW: optional tag to find controller

  const ProviderSelectorWidget({super.key, this.tag});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ServiceDetailsController>(tag: tag);

    return Obx(() {
      // Force dependency tracking by accessing value synchronously in the build phase
      final selectedId = c.selectedProviderId.value;

      // Hide if no providers or still loading
      if (c.isLoadingProviders.value) {
        return const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }

      if (c.providers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Select Provider',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount:
                  c.providers.length +
                  (c.allowAnyProviderBooking.value ? 1 : 0),
              itemBuilder: (context, index) {
                // Adjust index if "Any" is hidden
                final providerIndex = c.allowAnyProviderBooking.value
                    ? index - 1
                    : index;

                if (c.allowAnyProviderBooking.value && index == 0) {
                  // "Any Available" option
                  return _ProviderChip(
                    name: 'Any',
                    imageUrl: null,
                    isSelected: selectedId == null,
                    isAny: true,
                    onTap: () {
                      c.selectProvider(null);
                    },
                  );
                }

                final provider = c.providers[providerIndex];
                return _ProviderChip(
                  name: provider.name,
                  imageUrl: provider.profileImage,
                  isSelected: selectedId == provider.id,
                  isAny: false,
                  onTap: () {
                    c.selectProvider(provider.id);
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _ProviderChip extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isSelected;
  final bool isAny;
  final VoidCallback onTap;

  const _ProviderChip({
    required this.name,
    required this.imageUrl,
    required this.isSelected,
    required this.isAny,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  width: isSelected ? 3.0 : 1.0, // Thicker border for selected
                ),
              ),
              child: ClipOval(
                child: isAny
                    ? Container(
                        color: isSelected
                            ? primaryColor.withOpacity(0.1)
                            : Colors.grey.shade100,
                        child: Icon(
                          Icons.shuffle_rounded,
                          size: 24,
                          color: isSelected ? primaryColor : Colors.grey,
                        ),
                      )
                    : imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: isSelected
                            ? primaryColor.withOpacity(0.1)
                            : Colors.grey.shade100,
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            // Name
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? primaryColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
