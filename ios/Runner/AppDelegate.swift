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
    
    // Initialize Google Maps SDK
    GMSServices.provideAPIKey("AIzaSyDQwTk9sXiKrH2ksFk6uPyy16wdxQoL9vc")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
