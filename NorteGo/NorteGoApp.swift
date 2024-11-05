//
//  NorteGoApp.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 16/8/24.
//

import SwiftUI
import OneSignalFramework

@main
struct NorteGoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.light) 
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
       // Remove this method to stop OneSignal Debugging
       OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        
       // OneSignal initialization
       OneSignal.initialize("f914cff9-cb3d-4752-bfef-3e99ef113a3b", withLaunchOptions: launchOptions)

       // requestPermission will show the native iOS notification permission prompt.
       // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
       OneSignal.Notifications.requestPermission({ accepted in
         print("User accepted notifications: \(accepted)")
       }, fallbackToSettings: true)

       // Login your customer with externalId
       // OneSignal.login("EXTERNAL_ID")
            
       return true
    }
}
