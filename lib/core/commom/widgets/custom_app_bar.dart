// lib/core/commom/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.firstText,
    required this.secondText,
    this.trailing,
  });

  final String firstText;
  final String secondText;
  final Widget? trailing;

  // toolbar + subline
  static const double _toolbarH = 34;
  static const double _sublineH = 22;

  @override
  Size get preferredSize =>
      const Size.fromHeight(_toolbarH + _sublineH); // <-- real height

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top; // <-- status-bar height

    return Material(
      color: Colors.white,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.only(top: top, left: 12, right: 12, bottom: 8),
        // keep the height predictable for Scaffold
        height: top + _toolbarH + _sublineH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // row 1
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: Get.back,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    textAlign: TextAlign.center,
                    firstText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
            // row 2
            if (secondText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 44), // align under title
                child: Text(
                  secondText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF616161),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
