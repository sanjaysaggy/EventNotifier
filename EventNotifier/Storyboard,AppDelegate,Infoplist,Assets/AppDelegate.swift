//
//  AppDelegate.swift
//  Paxi
//
//  Created by Sanjay on 04/03/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//
/ 
import UIKit
import IQKeyboardManagerSwift
import SVProgressHUD
import Stripe
import GoogleMaps
//import GooglePlaces
import FBSDKCoreKit //For FB Login
//import Google //For Google Login
import GoogleSignIn
import TwitterCore
import TwitterKit

let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
let appdelegate = UIApplication.shared.delegate as! AppDelegate
let baseVC = BaseViewController()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var timerGetNotificationCount: Timer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        UIApplication.shared.statusBarStyle = .lightContent
        
        application.statusBarStyle = .lightContent // .default
        
        //Stripe Config
        STPPaymentConfiguration.shared().publishableKey = STRIPEKEY
        
        IQKeyboardManager.shared.enable = true //Keyboard manager
        
        SVProgressHUD.setDefaultMaskType(.black) //ProgressHUD settings
        
        //Google Maps
        GMSServices.provideAPIKey(GoogleAPIKey)
//        GMSPlacesClient.provideAPIKey(GoogleAPIKey)//Google Places
        
        //Facebook Login
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Twitter Login
//        TWTRTwitter.sharedInstance().start(withConsumerKey:"vnCvZMe1oHjFfSzf7Ktr6JrID", consumerSecret:"j3VdcW2YUGBRoxR0Jxz7QiQARyzPNtkPLf2LYIbt9lfEz4NxcS")
        TWTRTwitter.sharedInstance().start(withConsumerKey:"mEppffg758pxi4cS9PAB8Gnlj", consumerSecret:"DCs0kEEIOedUBUIAC8TyLxcTcVn99uwJhNpBq1SsLWBIEp35s3")
        
//        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = GoogleSignInClientID
        
        
//        //Checks Login in options
        if Utility.getLoginStatus() {
            let rootViewController = self.window!.rootViewController as!
            UINavigationController
            let HomeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            rootViewController.pushViewController(HomeViewController, animated: false)
        }
        
        self.timerGetNotificationCount = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.animatePolylinePath), userInfo: nil, repeats: true)
        
        return true
    }
    
    @objc func animatePolylinePath() {
        if Utility.getUserID() != "" {
            self.getNotificationsWebService(parameters: ["user_id":Utility.getUserID()], APIName: WSRequest.NotificationCountWS())
        }
    }
    
    private func application(application: UIApplication, openURL url: URL, options: [String: AnyObject]) -> Bool
    {
        if #available(iOS 9.0, *)
        {
            let facebook = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as? String, annotation: options["UIApplicationOpenURLOptionsAnnotationKey"])
            
            let googleplus = GIDSignIn.sharedInstance().handle(url, sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as? String, annotation: options["UIApplicationOpenURLOptionsAnnotationKey"])
            
            let twitter = TWTRTwitter.sharedInstance().application(application, open: url, options: options)//Twitter.sharedInstance().application(app, open: url, options: options)
            
            return facebook || googleplus || twitter
            
        } else {
            return false
        }
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        if (extensionPointIdentifier == UIApplication.ExtensionPointIdentifier.keyboard) {
            return false
        }
        return true
    }
    
//    func application(_ application: UIApplication,
//                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        var handle: Bool = true
//        
//        
//        let options: [String: AnyObject] = [UIApplication.OpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject, UIApplication.OpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
//        
//        handle = TWTRTwitter.sharedInstance().application(application, open: url, options: options)
//        
//        
//        
//        return handle
//    }
    
    func application(_ application: UIApplication,open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url as URL!,
                                                                sourceApplication: sourceApplication,
                                                                annotation: annotation)
        
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
        var twitterDidHandle: Bool = true
        
        let options: [String: AnyObject] = [UIApplication.OpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject, UIApplication.OpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        
        twitterDidHandle = TWTRTwitter.sharedInstance().application(application, open: url, options: options)
        
        return googleDidHandle || facebookDidHandle || twitterDidHandle
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    //MARK:- Web Services Methods -
    
    func getNotificationsWebService(parameters:[String:Any],APIName:String) {
        //        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "GetNotificationCount"), object: nil, userInfo:["type":"Count","notification_count":"\(responseData["count"] as! Int)"])
                } else {
                    baseVC.showAlertView(title: "SORRY!", message: message)
                }
//                baseVC.dismissProgress()
            })
            
        } else {
//            baseVC.dismissProgress()
            baseVC.showAlertView(title: NetworkIssueTitle, message: NoInternetConnectionMessage)
        }
    }
    

}

