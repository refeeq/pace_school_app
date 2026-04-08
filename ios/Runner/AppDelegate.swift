import UIKit
import Flutter
import Firebase
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // Initialize Google Maps SDK with static key (from Info.plist / config)
    GMSServices.provideAPIKey("AIzaSyB6Ds4XCDBH00WGcEkw8aQPIkK9l4bpz7U")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}


