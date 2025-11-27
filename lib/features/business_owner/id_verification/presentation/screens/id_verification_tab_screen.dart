// Simplified placeholder for ID Verification - Full implementation can be added later
import 'package:flutter/material.dart';

class IDVerificationTabScreen extends StatelessWidget {
  const IDVerificationTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('ID Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Feature coming soon', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
