import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FullScreenShimmerLoader extends StatelessWidget {
  const FullScreenShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    double getWidth(double w) => MediaQuery.of(context).size.width * (w / 375);
    double getHeight(double h) => MediaQuery.of(context).size.height * (h / 812);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Profile row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 24, backgroundColor: Colors.white),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, width: 100, color: Colors.white),
                        SizedBox(height: 8),
                        Container(height: 12, width: 140, color: Colors.white),
                      ],
                    ),
                  ],
                ),
                Container(height: 25, width: 25, color: Colors.white),
              ],
            ),

            SizedBox(height: 24),

            // Special Offer text
            Container(height: 18, width: 120, color: Colors.white),
            SizedBox(height: 16),

            // Slider placeholder
            Container(
              height: getHeight(200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            SizedBox(height: 24),

            // My Services header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 18, width: 120, color: Colors.white),
                Container(height: 16, width: 60, color: Colors.white),
              ],
            ),

            SizedBox(height: 12),

            // Horizontal Services List
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      CircleAvatar(radius: 30, backgroundColor: Colors.white),
                      SizedBox(height: 5),
                      Container(height: 10, width: 40, color: Colors.white),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // Booking List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 18, width: 120, color: Colors.white),
                Container(height: 16, width: 60, color: Colors.white),
              ],
            ),

            SizedBox(height: 24),

            // Booking items
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => SizedBox(height: 20),
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 33, backgroundColor: Colors.white),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 14, width: 120, color: Colors.white),
                            SizedBox(height: 8),
                            Container(height: 12, width: 100, color: Colors.white),
                            SizedBox(height: 8),
                            Container(height: 12, width: 130, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          height: 28,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(height: 14, width: 60, color: Colors.white),
                      ],
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
