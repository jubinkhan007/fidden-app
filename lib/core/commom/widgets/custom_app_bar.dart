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

  // Row heights
  static const double _toolbarH = 34;
  static const double _sublineH = 22;
  static const double _bottomPad = 8;

  bool get _hasSubline => secondText.isNotEmpty;

  // ✅ preferredSize must match the actual content height (excluding status bar).
  @override
  Size get preferredSize =>
      Size.fromHeight(_toolbarH + (_hasSubline ? _sublineH : 0) + _bottomPad);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    // ✅ Real container height includes status bar + rows + bottom padding.
    final contentHeight =
        _toolbarH + (_hasSubline ? _sublineH : 0) + _bottomPad;

    return Material(
  color: Colors.white,
  elevation: 0,
  child: Padding(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top,
      left: 12,
      right: 12,
      bottom: _bottomPad,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min, // <-- lets it shrink/expand naturally
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
                    firstText,
                    textAlign: TextAlign.center,
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
            if (_hasSubline)
              const SizedBox(height: 2), // small buffer to feel balanced
            if (_hasSubline)
              Padding(
                padding: const EdgeInsets.only(left: 44), // align under title
                child: Text(
                  secondText,
                  softWrap: true,
                  // maxLines: 1,
                  overflow: TextOverflow.visible,
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
