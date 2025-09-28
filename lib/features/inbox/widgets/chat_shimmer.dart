import 'package:flutter/material.dart';

class ChatShimmer extends StatelessWidget {
  const ChatShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: 8,
      itemBuilder: (_, i) {
        final alignRight = i.isEven;
        return Align(
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: MediaQuery.of(context).size.width * (alignRight ? 0.55 : 0.72),
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEFF2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
