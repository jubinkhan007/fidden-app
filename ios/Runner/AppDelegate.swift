import UIKit
import Flutter
import GoogleMaps
import Firebase // ✅ Import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GMSServices.provideAPIKey("AIzaSyC8Rj8qqv9kn2FGTtALwhwpe_GPmhJfP8s")
    FirebaseApp.configure() // ✅ Add this line

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}