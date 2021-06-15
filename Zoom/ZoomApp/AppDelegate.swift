//
//  AppDelegate.swift
//  ZoomApp
//
//  Created by 2020 on 11.06.2021.
//
import MobileRTC
import MobileCoreServices
import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import CallKit
import SwiftyJSON

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var roomId = ""
    var pass = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        //        if #available(iOS 13.0, *) {
        //            let storyboard = UIStoryboard(name: "UsersList", bundle: nil)
        //                let vc = storyboard.instantiateViewController(identifier: "UsersListViewController") as UsersListViewController
        //            let navigationController = UINavigationController(rootViewController: vc)
        //            window?.rootViewController = navigationController
        //
        //            } else {
        //                let storyboard = UIStoryboard(name: "UsersList", bundle: nil)
        //                let vc = storyboard.instantiateViewController(withIdentifier: "UsersListViewController") as! UsersListViewController
        //                let navigationController = UINavigationController(rootViewController: vc)
        //                window?.rootViewController = navigationController
        //            }
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        let navigationController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationController
        
        let mainSDK = MobileRTCSDKInitContext()
        mainSDK.domain = "zoom.us"
        MobileRTC.shared().initialize(mainSDK)
        let authService = MobileRTC.shared().getAuthService()
        print(MobileRTC.shared().mobileRTCVersion)
        authService?.delegate = self
        authService?.clientKey = "tH5PAIqDfv7k15863A4e8FU6vyFsi7TVlL3K"
        authService?.clientSecret = "I6ubtX1V6fzrS9mrSsh05ZPsWYXcvQN2mkPj"
        authService?.sdkAuth()
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        return true
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        UserDefaults.standard.set(fcmToken, forKey: "deviceToken")
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
}

extension AppDelegate: MobileRTCAuthDelegate, MobileRTCMeetingServiceDelegate {
    
    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        if (returnValue != .success)
        {
            let msg = "SDK authentication failed, error code: \(returnValue)"
            print(msg)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Obtain the MobileRTCAuthService from the Zoom SDK, this service can log in a Zoom user, log out a Zoom user, authorize the Zoom SDK etc.
        if let authorizationService = MobileRTC.shared().getAuthService() {
            
            // Call logoutRTC() to log the user out.
            authorizationService.logoutRTC()
        }
    }
    
    func onMobileRTCLoginReturn(_ returnValue: Int) {
        switch returnValue {
        case 0:
            print("Successfully logged in")
            
            // This alerts the ViewController that the login was successful.
            NotificationCenter.default.post(name: Notification.Name("userLoggedIn"), object: nil)
        case 1002:
            print("Password incorrect")
        default:
            print("Could not log in. Error code: \(returnValue)")
        }
    }
    
    // 2. Listen for the user logout result. 0 represents a successful log out attempt.
    func onMobileRTCLogoutReturn(_ returnValue: Int) {
        switch returnValue {
        case 0:
            print("Successfully logged out")
        default:
            print("Could not log out. Error code: \(returnValue)")
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    @available(iOS 10.0, *)
       func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response:UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
       {
           print("Handle push from background or closed")
           print("\(response.notification.request.content.userInfo)")
       }

    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo["gcm.message_id"] {
        print("\n*** application - didReceiveRemoteNotification - fetchCompletionHandler - Message ID: \(messageID)")
        }
        print("\n*** application - didReceiveRemoteNotification - full message - fetchCompletionHandler, userInfo: \(userInfo)")
        let json = try JSON(userInfo)
        roomId = json["roomID"].string!
        pass = json["pass"].string!
        
        let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "ZoomApp"))
        provider.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "Bob")
        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken;
    }
}

extension AppDelegate: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        joinMeeting(meetingNumber: roomId, meetingPassword: pass )
        //action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
    
    func joinMeeting(meetingNumber: String, meetingPassword: String) {
        if let meetingService = MobileRTC.shared().getMeetingService() {
            meetingService.delegate = self
            let joinMeetingParameters = MobileRTCMeetingJoinParam()
            joinMeetingParameters.meetingNumber = meetingNumber
            joinMeetingParameters.password = meetingPassword
            meetingService.joinMeeting(with: joinMeetingParameters)
        }
    }
}
