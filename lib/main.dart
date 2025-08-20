import 'package:fidden/app.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Sign-In
  await GoogleSignIn.instance.initialize(
    // Get this from your Google Cloud Console for your project
    serverClientId:
        '910463978621-34r0n3pbn9rq81ort6fgcglef6hbnu3a.apps.googleusercontent.com',
  );

  await AuthService.init();
  runApp(const MyApp());
}
