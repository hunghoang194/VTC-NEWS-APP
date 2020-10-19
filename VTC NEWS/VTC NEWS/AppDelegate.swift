//
//  AppDelegate.swift
//  VTC NEWS
//
//  Created by hưng hoàng on 10/5/20.
//  Copyright © 2020 hưng hoàng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        configApplePush(application)
        Messaging.messaging().delegate = self
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        let notificationOption = launchOptions?[.remoteNotification]
        if let notification = notificationOption as? [AnyHashable: Any]{
            guard let url = notification["url"] as? String else {
                return true
            }
            UserDefaults.standard.setValue(url, forKey: "WEB_MAIN")
            UserDefaults.standard.synchronize()
        }
        
        return true
    }
    func configApplePush(_ application: UIApplication) {
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
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("vao dayyyyyyy")
        //        if(DetailViewController != nil){
        //                NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.handleEvent), name: UIApplication.didBecomeActiveNotification, object: nil)
        //        }
        
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("vtcnow.vn") == .orderedSame{
            
            let value = URLComponents(url: url, resolvingAgainstBaseURL: false)?.host ?? ""
            if !value.isEmpty {
                //-- app dang chay
                if app.applicationState == .active {
                    NotificationCenter.default.post(name: NSNotification.Name("DEEP_LINK"), object: nil, userInfo: ["value": value])
                }else if app.applicationState == .inactive{//-- app tu fourcebackgroud
                    NotificationCenter.default.post(name: NSNotification.Name("DEEP_LINK"), object: nil, userInfo: ["value": value])
                }else{//-- app tư background
                    UserDefaults.standard.setValue(value, forKey: "DEEP_LINK")
                    UserDefaults.standard.synchronize()
                }
            }
        }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        handerPush(UIApplication.shared, userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handerPush(application, userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    fileprivate func handerPush(_ application: UIApplication, _ userInfo: [AnyHashable: Any]){
        
        NotificationCenter.default.post(name: NSNotification.Name("RELOAD_WEB_MAIN"), object: nil, userInfo: userInfo)
    }
    func getToken(){
        let urlString = "https://playback.tek4tv.vn/api/token"
        let param = ["AppID":"bc6da08b-3ad4-4452-8f29-d56bc69e33432",
                     "ApiKey":"5G2Zix5YcWLdatLFrr+81d7ldMV7Yt5CGftGF5VTqhM=1",
                     "AccountId": "103e5b3a-3971-4fcb-bf44-5b15c5bbb88e"]
        
        var myJsonString = ""
        do {
            let data =  try JSONSerialization.data(withJSONObject:param, options: .prettyPrinted)
            myJsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        } catch {
            print(error.localizedDescription)
        }
        let url = URL(string: urlString)!
        let jsonData = myJsonString.data(using: .utf8, allowLossyConversion: false)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        AF.request(request).responseJSON {
            (response) in
            print("Token: \(response)")
            let token = try? (response.value)
            UserDefaults.standard.set(token, forKey: "token")
        }
    }
    func reportPlayer() {
//        let strURL = "https://14.225.16.146:8093/report/api/v0/report"
//        let param = ReportClient.shared.teKReport.toDictionary()
//        let tokenKey = UserDefaults.standard.string(forKey: "token")
//        var myJsonString = ""
//        do {
//            let data =  try JSONSerialization.data(withJSONObject:param, options: JSONSerialization.WritingOptions.prettyPrinted)
//            myJsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
//        } catch {
//            print(error.localizedDescription)
//        }
//        let jsonData = myJsonString.data(using: .utf8, allowLossyConversion: false)!
//
//        let url = URL(string: strURL)!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST" //set http method as POST
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
//        } catch let error {
//            print(error.localizedDescription)
//        }
//        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue(tokenKey ?? "", forHTTPHeaderField: "Authorization")
//        request.httpBody = jsonData
//        AF.request(request).responseJSON {
//            (response) in
//        }
    }
}


extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Messaging.messaging().subscribe(toTopic: "iosHotNews")
        print("FCM: \(fcmToken)")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        handerPush(UIApplication.shared, remoteMessage.appData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handerPush(UIApplication.shared, userInfo)
        
        completionHandler()
    }
    
}

class ReportClient{
    static let shared = ReportClient()
    
    var teKReport : TEKReport?
//        didSet{
//            AppDelegate.sharedInstance.reportPlayer()
//        }
//    }
}
extension Encodable {
    func toDictionary() -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(self)
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            
            if let dictionary = dictionary {
                return dictionary
            }
            return [:]
        }
        catch {
            return [:]
        }
    }
}

