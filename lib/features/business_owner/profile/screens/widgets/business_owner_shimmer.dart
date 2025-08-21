import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/constants/app_sizes.dart';

class BusinessOwnerProfileShimmer extends StatelessWidget {
  const BusinessOwnerProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getWidth(24), vertical: getHeight(24)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            SizedBox(height: getHeight(34)),
            // Profile image
            Container(
              width: getWidth(150),
              height: getHeight(150),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            SizedBox(height: getHeight(18)),
            Container(
              width: getWidth(180),
              height: 20,
              color: Colors.white,
            ),
            SizedBox(height: getHeight(8)),
            Container(
              width: getWidth(140),
              height: 16,
              color: Colors.white,
            ),
            SizedBox(height: getHeight(40)),

            // Profile buttons
            ...List.generate(6, (index) => _buildButtonShimmer()),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonShimmer() {
    return Padding(
      padding: EdgeInsets.only(bottom: getHeight(16)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: getWidth(20), height: getHeight(20), color: Colors.white),
                SizedBox(width: getWidth(18)),
                Container(width: getWidth(160), height: 16, color: Colors.white),
              ],
            ),
            Container(width: getWidth(26), height: getHeight(26), color: Colors.white),
          ],
        ),
      ),
    );
  }
}
