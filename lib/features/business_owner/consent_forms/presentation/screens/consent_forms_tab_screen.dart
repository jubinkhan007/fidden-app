// Simplified placeholder for Consent Forms - Full implementation can be added later
import 'package:flutter/material.dart';

class ConsentFormsTabScreen extends StatelessWidget {
  const ConsentFormsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Consent Forms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Feature coming soon', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
