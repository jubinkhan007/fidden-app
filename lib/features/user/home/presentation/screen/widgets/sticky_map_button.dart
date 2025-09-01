import 'package:fidden/features/user/home/presentation/screen/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StickyShowMapButton extends StatefulWidget {
  const StickyShowMapButton({required this.r, required this.onTap});
  final R r;
  final VoidCallback onTap;

  // Adjust this if bottom nav bar has a different height
  static const double _bottomNavHeight = 0;
  @override
  State<StickyShowMapButton> createState() => _StickyShowMapButtonState();
}

class _StickyShowMapButtonState extends State<StickyShowMapButton> {
  // px
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          // left/right gutters + lift above bottom nav bar
          padding: EdgeInsets.fromLTRB(
            widget.r.w(20),
            widget.r.w(20),
            widget.r.w(20),
            widget.r.h(6) + StickyShowMapButton._bottomNavHeight,
          ),
          child: SizedBox(
            width: widget.r.w(125),
            child: ElevatedButton.icon(
              onPressed: widget.onTap,
              icon: const Icon(Icons.map_rounded),
              label: Text(
                'Show Map',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: widget.r.sp(16),
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: widget.r.h(14)),
                elevation: 8,
                backgroundColor: const Color(0xFF6B2A3B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: widget.r.r(16)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
