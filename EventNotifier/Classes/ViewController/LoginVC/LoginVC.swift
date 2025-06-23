//
//  LoginVC.swift
//  LGBTQ
//
//  Created by Sanjay on 07/02/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit
import FBSDKLoginKit
//import Google
import GoogleSignIn
import Spring
import FBSDKLoginKit
import TwitterKit

class LoginVC: BaseViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    //Forgot Password View
    @IBOutlet weak var transferentView: UIView!
    @IBOutlet weak var forgotPassView: SpringView!
    @IBOutlet weak var emailForForgotPassTextField: UITextField!
    
    var socialMediaInfoDict:[String:Any]?
    
    
    //MARK:- View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        addImageToTextFieldAtLeftSide(imageName: "email_address", textField: emailTextField)
        addImageToTextFieldAtLeftSide(imageName: "password", textField: passwordTextField)
        
        hideForgotPassView()
        
        passwordTextField.clearsOnInsertion = false
        passwordTextField.clearsOnBeginEditing = false
        
        emailTextField.addTarget(self, action: #selector(textfieldChanged(_:)), for: UIControl.Event.editingChanged)
        
    }
    
    @objc private func textfieldChanged(_ textField: UITextField) {
        if let text:String = self.emailTextField.text {
            DispatchQueue.main.async {
                self.emailTextField.text = text.lowercased()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.loginButton.cornerRadius = self.loginButton.frame.size.height/2
    }
    
    func validateUserEnterDetails() -> Bool {
        
        if (emailTextField.text?.isEmpty)! && (passwordTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please fill All Fields", duration: 1, position: .center)
            return false
        } else if (emailTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Your Email-ID", duration: 1, position: .center)
            emailTextField.becomeFirstResponder()
            return false
        } else if !isEmailValid(emailTextField.text!) {
            showToastBlackBackgraound(toastMessage: "Please Enter Valid Email-ID", duration: 1, position: .center)
            emailTextField.becomeFirstResponder()
            return false
        } else if (passwordTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Password", duration: 1, position: .center)
            passwordTextField.becomeFirstResponder()
            return false
        }
        
        return true
    }
    
    func showForgotPassView() {
        forgotPassView.isHidden = false
        transferentView.isHidden = false
        
        forgotPassView.animation = "fadeInUp"
        forgotPassView.curve = "spring"
        forgotPassView.duration = 0.7
        forgotPassView.animate()
    }
    
    func hideForgotPassView() {
        forgotPassView.isHidden = true
        transferentView.isHidden = true
    }
    
    
    //MARK:- Button Actions -
    
    @IBAction func logInButtonAction(_ sender: Any) {
        if validateUserEnterDetails() {
            let parameters:[String:Any] = ["email":self.emailTextField.text!,
                                           "password":self.passwordTextField.text!,
                                           "device_type":"iOS",
                                           "device_token":Utility.getDeviceToken()]
            self.WebService(parameters: parameters, APIName: WSRequest.LoginWS())
        }
        //        let VC:AvailableTaskVC = storyBoardTasker.instantiateViewController(withIdentifier: "AvailableTaskVC") as! AvailableTaskVC
        //        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func socialLoginButtonAction(_ sender: Any) {
        //        self.showToastBlackBackgraound(toastMessage: UnderDevelopment, duration: 1.5, position: .center)
        if (sender as AnyObject).tag == 0 {
            fbLoginInitiate()
        } else if (sender as AnyObject).tag == 1 {
            self.twitterLogin()
//            self.showToastBlackBackgraound(toastMessage: UnderDevelopment, duration: 1.5, position: .center)
        } else if (sender as AnyObject).tag == 2 {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    @IBAction func registerButtonAction(_ sender: Any) {
        let VC:RegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func forgotPasswordButtonAction(_ sender: Any) {
        self.showForgotPassView()
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.hideForgotPassView()
    }
    
    @IBAction func submitForgotPassButtonAction(_ sender: Any) {
        if (emailForForgotPassTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Your Email-ID", duration: 1, position: .center)
            emailForForgotPassTextField.becomeFirstResponder()
        } else {
            let parameters:[String:Any] = ["email":self.emailForForgotPassTextField.text!]
            self.WebServiceForgotPassword(parameters: parameters, APIName: WSRequest.ForgotPasswordWS())
        }
    }
    
    //MARK:- Web Services Methods -
    
    func WebService(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.dismissProgress()
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    let profileDict = responseData["response"] as! [String:Any]
                    //                    Utility.setUserType(profileDict["type"] as! String)
                    Utility.setUserID(profileDict["user_id"] as! String)
                    Utility.setEmail(profileDict["email_address"] as! String)
                    Utility.setPhoneNo(profileDict["phone_number"] as! String)
                    Utility.setProfileURL(profileDict["profile_picture"] as! String)
                    Utility.setUserName(profileDict["name"] as! String)
                    Utility.setLoginStatus()
                    
                    let VC:HomeVC! = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
                    self.navigationController?.pushViewController(VC, animated: true)
                    
                } else {
                    self.dismissProgress()
                    self.showAlertView(title: "Sorry!", message: message)
                }
            })
            
        } else {
            self.dismissProgress()
            self.showAlertView(title: NetworkIssueTitle, message: NoInternetConnectionMessage)
        }
    }
    
    func WebServiceForgotPassword(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.emailForForgotPassTextField.text = ""
                    self.showAlertView(title: "Alert", message: "Please check your email inbox, We have sent password on registered email address")
                    self.hideForgotPassView()
                } else {
                    self.showAlertView(title: "Sorry!", message: message)
                }
                self.dismissProgress()
            })
        } else {
            self.dismissProgress()
            self.showAlertView(title: NetworkIssueTitle, message: NoInternetConnectionMessage)
        }
    }
    
    func socialMediaLoginWebService(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.dismissProgress()
                    let profileDict = responseData["response"] as! [String:Any]
                    Utility.setUserID(profileDict["user_id"] as! String)
                    Utility.setEmail(profileDict["email_address"] as! String)
                    Utility.setPhoneNo(profileDict["phone_number"] as! String)
                    Utility.setProfileURL(profileDict["profile_picture"] as! String)
                    Utility.setUserName(profileDict["name"] as! String)
                    Utility.setLoginStatus()

                    let VC:HomeVC! = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
                    self.navigationController?.pushViewController(VC, animated: true)
                } else {
                    self.dismissProgress()
                    if message == "New user" {
                        let VC:RegisterVC! = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as? RegisterVC
                        VC.forPurpose = APIName
                        VC.dictDetails = parameters
                        self.navigationController?.pushViewController(VC, animated: true)
                    } else {
                        self.showAlertView(title: "Sorry!", message: message)
                    }
                }
            })
            
        } else {
            self.dismissProgress()
            self.showAlertView(title: NetworkIssueTitle, message: NoInternetConnectionMessage)
        }
    }
    
    func checkSocialMediaAccountExistWebService(parameters:[String:Any],APIName:String) {
        //        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.dismissProgress()
                    
                    Utility.setUserFirstName(responseData["first_name"] as! String)
                    Utility.setUserLastName(responseData["last_name"] as! String)
                    Utility.setEmail(responseData["email"] as! String)
                    Utility.setPhoneNo(responseData["phone_number"] as! String)
                    if responseData["city"] as? String != nil {
                        Utility.setCity(responseData["city"] as! String)
                    }
                    if let profilePicURL = responseData["photo"] as? String {
                        Utility.setProfileURL(profilePicURL)
                    }
                    Utility.setUserID(responseData["userID"] as! String)
                    //                    Utility.setLoginStatus()
                    Utility.setUserName("\(Utility.getUserFirstName()) \(Utility.getUserLastName())")
                    Utility.setUserType(responseData["user_type"] as! String)
                    
                    //                    let VC:PersonalInfoViewController = storyBoardMain.instantiateViewController(withIdentifier: "PersonalInfoViewController") as! PersonalInfoViewController
                    //                    VC.alreadyExist = AccountAlreadyExist
                    //                    VC.from = SocialLogin
                    //                    VC.socialMediaInfoDict = self.socialMediaInfoDict
                    //                    //                    VC.user_typeString = Utility.getUserType()
                    //                    self.navigationController?.pushViewController(VC, animated: true)
                    
                    
                } else {
                    self.dismissProgress()
                    //                    let VC:PersonalInfoViewController = storyBoardMain.instantiateViewController(withIdentifier: "PersonalInfoViewController") as! PersonalInfoViewController
                    //                    VC.from = SocialLogin
                    //                    VC.socialMediaInfoDict = self.socialMediaInfoDict
                    //                    //                    VC.user_typeString = self.user_typeString
                    //
                    //                    self.navigationController?.pushViewController(VC, animated: true)
                }
            })
            
        } else {
            self.dismissProgress()
            self.showAlertView(title: NetworkIssueTitle, message: NoInternetConnectionMessage)
        }
    }
    
    //MARK:- Facebook Signin Methods
    func fbLoginInitiate()
    {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        loginManager.logIn(withReadPermissions: ["public_profile","email"], from: self, handler: { (result, error) -> Void in   // Opens the facebook login window
            if (error != nil) {
                print("Facebook Signin error:",error!.localizedDescription)
            } else if (result?.isCancelled)! {
                print("User Cancelled")
                self.removeFbData()
            } else {
                // After successfull signin, calling facebook api to get the user details.
                if (result?.grantedPermissions.contains("email"))! && (result?.grantedPermissions.contains("public_profile"))! {
                    //Do work
                    self.fetchFacebookProfile()
                } else {
                    self.showToastBlackBackgraound(toastMessage: "Please allow us to access yor email & prublic profile.", duration: 1, position: .center)
                }
            }
        })
    }
    
    func removeFbData()
    {
        //Remove FB Data
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrent(nil)
    }
    
    var strDeviceID = ""
    func fetchFacebookProfile()
    {
        self.showProgress()
        if FBSDKAccessToken.current() != nil
        {
            FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"id,name,first_name, last_name,age_range,email,picture.type(large)"]).start { (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    //Handle error
                    self.dismissProgress()
                    print("Errrorrrrrrrr  fetchFacebookProfile")
                }
                else
                {
                    let dictResult = result as! NSDictionary
                    self.socialMediaInfoDict = ["email": dictResult.value(forKey: "email")!,
                                                "facebook_id":dictResult.value(forKey: "id")!,
                                                "name":"\(dictResult.value(forKey: "first_name")!) \(dictResult.value(forKey: "last_name")!)",
                        "device_type":"iOS",
                        "token":Utility.getDeviceToken()]
                    //                    print("dict \(postDictionary)")
                    
                    
                    //                    let facebookProfileUrl = "http://graph.facebook.com/\(postDictionary["facebook_id"] as! String)/picture?type=large"
                    //
                    //                    print("facebookProfileUrl: \(facebookProfileUrl)")
                    
                    //                    if Utility.getUserType() == PROJECTMANAGER {
                    //                        self.checkSocialMediaAccountExistWebService(parameters: ["facebook_id":dictResult.value(forKey: "id")!], APIName: WSRequest.checkPMFBIDWS())
                    //                    } else {
                    //                        self.checkSocialMediaAccountExistWebService(parameters: ["facebook_id":dictResult.value(forKey: "id")!], APIName: WSRequest.checkFBIDWS())
                    //                    }
                    
                    self.socialMediaLoginWebService(parameters: self.socialMediaInfoDict!, APIName: WSRequest.LoginWithFBWS())
                    
                }
            }
        }
    }
    
    
    //MARK:- Google SignIn Delegate
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            print("User Details:",user)
            
            let userId = user.userID
            //            let tokenID = user.authentication.idToken
            //            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            //            let postDictionary = ["email": email!,"gplusId":userId!,"name":fullName!,"deviceId": "devicetocken"]
            
            self.socialMediaInfoDict = ["email": email!,
                                        "google_id":userId!,
                                        "name":"\(givenName!) \(familyName!)",
                "device_type":"iOS",
                "token":Utility.getDeviceToken()]
            
            //            print("dict \(postDictionary)")
            self.socialMediaLoginWebService(parameters: self.socialMediaInfoDict!, APIName: WSRequest.LoginWithGoogleWS())
            
            //            self.checkSocialMediaAccountExistWebService(parameters: ["googleID":userId!], APIName: WSRequest.checkGoogleIDWS())
        } else {
            print("Google SignIn Error: \(error.localizedDescription)")
        }
    }
    
    // Called before opens the google signin window
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!)
    {
        print("Called before opens the google signin window")
    }
    // This delegate method called after google signin dispatch, need to present the google signin view controller
    // from current view controller.
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!)
    {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Called when the user taps on cancel in google signin view controller.
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Twitter Login
    
    func twitterLogin() {
        TWTRTwitter.sharedInstance().logIn(completion: { (twitterSession, error) in
            if (twitterSession != nil) {
                print("signed in as \(String(describing: twitterSession!.userName))")
                print("userID \(String(describing: twitterSession!.userID))")
                print("authToken \(String(describing: twitterSession!.authToken))")
                
                self.showProgress()
                
                if let session = twitterSession {
                    let client = TWTRAPIClient.withCurrentUser()
                    
                    client.loadUser(withID: session.userID, completion: { (twitterUser, userError) in
                        if let user = twitterUser {
                            print("user.name -> \(user.name)")
                            print("user.profileImageURL -> \(user.profileImageURL)")
                            print("user.profileURL -> \(user.profileURL)")
                            print("user -> \(user)")
                            var firstName:String?
                            var lastName:String?
                            var fullName = user.name
                            
                            if fullName.contains(" ") {
                                var components = fullName.components(separatedBy: " ")
                                if(components.count > 0) {
                                    firstName = components.removeFirst()
                                    lastName = components.joined(separator: " ")
                                    
                                    fullName = firstName! + " " + lastName!
                                    debugPrint(firstName!)
                                    debugPrint(lastName!)
                                }
                            }
                        
                            client.requestEmail { email, error in
                                if (email != nil) {
                                    self.socialMediaInfoDict = ["email": email ?? "",
                                                                "twitter_id":session.userID,
                                                                "name":fullName,
                                        "device_type":"iOS",
                                        "token":Utility.getDeviceToken()]
                                    
                                    print("self.socialMediaInfoDict:",self.socialMediaInfoDict as Any)
                                    self.socialMediaLoginWebService(parameters: self.socialMediaInfoDict!, APIName: WSRequest.LoginWithTwitterWS())
                                }else {
                                    print("error--: \(String(describing: error?.localizedDescription))");
                                    self.socialMediaInfoDict = ["email": "",
                                                                "twitter_id":session.userID,
                                                                "name":fullName,
                                        "device_type":"iOS",
                                        "token":Utility.getDeviceToken()]
                                    
                                    print("self.socialMediaInfoDict:",self.socialMediaInfoDict as Any)
                                    self.socialMediaLoginWebService(parameters: self.socialMediaInfoDict!, APIName: WSRequest.LoginWithTwitterWS())
                                }
                            }
//                            self.checkSocialMediaAccountExistWebService(parameters: ["twiter_id":session.userID], APIName: WSRequest.checkTwitterIDWS())
                            
                        } else {
                            self.dismissProgress()
                            print("userError: \(String(describing: userError?.localizedDescription))");
                        }
                    })
                } else {
                    self.dismissProgress()
                    print("error: \(String(describing: error?.localizedDescription))")
                }
            } else {
                self.dismissProgress()
                print("error: \(String(describing: error?.localizedDescription))")
            }
        })
    }
}
