import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Widget Timeline Refresh Support

  /// Called when the app will enter the foreground
  ///
  /// This is triggered when the user unlocks their device and the app becomes active.
  /// We use this opportunity to reload the widget timeline, which effectively
  /// provides a refresh-on-unlock behavior.
  ///
  /// Part of WIDGET-004: Timeline refresh on device unlock events
  override func applicationWillEnterForeground(_ application: UIApplication) {
    super.applicationWillEnterForeground(application)

    // Reload all widget timelines when app enters foreground
    // This ensures widgets show fresh content when user unlocks device
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }

  /// Called when the app did become active
  ///
  /// Additional hook to ensure widget refresh on app activation.
  /// Works in conjunction with applicationWillEnterForeground for maximum coverage.
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)

    // Additional timeline reload to catch edge cases
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }

  // MARK: - Background App Refresh Support

  /// Handle background fetch for widget updates
  ///
  /// This allows the widget to be updated even when the app is not in foreground.
  /// Requires "Background fetch" capability in Xcode project settings.
  ///
  /// Part of WIDGET-004: Background widget refresh capability
  override func application(
    _ application: UIApplication,
    performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    // Reload widget timelines in background
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
      completionHandler(.newData)
    } else {
      completionHandler(.noData)
    }
  }
}
