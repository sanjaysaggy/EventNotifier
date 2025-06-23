//
//  RegisterVC.swift
//  LGBTQ
//
//  Created by Sanjay on 07/02/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit

class RegisterVC: BaseViewController {
    
    
    @IBOutlet weak var fullNameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var phoneNoTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var confirmPassTextField: CustomTextField!
    @IBOutlet weak var registerButton : UIButton!
    @IBOutlet weak var loginButton : UIButton!
    
    var forPurpose = ""
    var dictDetails : [String:Any]?
    
    //MARK:- View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImageToTextFieldAtLeftSide(imageName: "full_name", textField: fullNameTextField)
        addImageToTextFieldAtLeftSide(imageName: "email_address", textField: emailTextField)
        addImageToTextFieldAtLeftSide(imageName: "mobile_number", textField: phoneNoTextField)
        addImageToTextFieldAtLeftSide(imageName: "password", textField: passwordTextField)
        addImageToTextFieldAtLeftSide(imageName: "password", textField: confirmPassTextField)
        
        emailTextField.addTarget(self, action: #selector(emailtextfieldChanged(_:)), for: UIControl.Event.editingChanged)
        
        setMaxLength()
        
        if forPurpose == WSRequest.LoginWithTwitterWS() ||
            forPurpose == WSRequest.LoginWithFBWS() ||
            forPurpose == WSRequest.LoginWithGoogleWS() {
            
            self.passwordTextField.isHidden = true
            self.confirmPassTextField.isHidden = true
            
            self.fullNameTextField.text = self.dictDetails!["name"] as? String
            self.emailTextField.text = self.dictDetails!["email"] as? String
        }
    }
    
    @objc private func emailtextfieldChanged(_ textField: UITextField) {
        if let text:String = self.emailTextField.text {
            DispatchQueue.main.async {
                self.emailTextField.text = text.lowercased()
            }
        }
    }
    
    private func setMaxLength() {
        phoneNoTextField.addTarget(self, action: #selector(textfieldChanged(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc private func textfieldChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let trimmed = text.prefix(10)
        textField.text = String(trimmed)
    }
    
    override func viewWillLayoutSubviews() {
        self.registerButton.cornerRadius = self.registerButton.frame.size.height/2
        
    }
    
    func validateUserEnterDetails() -> Bool {
        
        if (fullNameTextField.text?.isEmpty)! && (phoneNoTextField.text?.isEmpty)! && (emailTextField.text?.isEmpty)! && (passwordTextField.text?.isEmpty)! && (confirmPassTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please fill all fields", duration: 1, position: .center)
            return false
        } else if (fullNameTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Full Name", duration: 1, position: .center)
            fullNameTextField.becomeFirstResponder()
            return false
        } else if !(fullNameTextField.text?.contains(" "))! {
            showToastBlackBackgraound(toastMessage: "Please Enter Full Name Properly", duration: 1, position: .center)
            fullNameTextField.becomeFirstResponder()
            return false
        } else if (emailTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Email", duration: 1, position: .center)
            emailTextField.becomeFirstResponder()
            return false
        } else if !isEmailValid(emailTextField.text!) {
            showToastBlackBackgraound(toastMessage: "Please Enter Valid Email", duration: 1, position: .center)
            emailTextField.becomeFirstResponder()
            return false
        } else if (phoneNoTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Phone No.", duration: 1, position: .center)
            phoneNoTextField.becomeFirstResponder()
            return false
        } else if passwordTextField.text!.count < 7 {
            showToastBlackBackgraound(toastMessage: "Password should be atleast 7 characters", duration: 1, position: .center)
            passwordTextField.becomeFirstResponder()
            return false
        } else if (confirmPassTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Confirm Password", duration: 1, position: .center)
            confirmPassTextField.becomeFirstResponder()
            return false
        } else if passwordTextField.text != confirmPassTextField.text! {
            showToastBlackBackgraound(toastMessage:  "Passwords do not match" , duration: 1, position: .center)
            return false
        }
        
        return true
    }
    
    func validateUserEnterDetailsForSocialMedia() -> Bool {
        
        if (fullNameTextField.text?.isEmpty)! && (phoneNoTextField.text?.isEmpty)! && (emailTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please fill all fields", duration: 1, position: .center)
            return false
        } else if (fullNameTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Full Name", duration: 1, position: .center)
            fullNameTextField.becomeFirstResponder()
            return false
        } else if !(fullNameTextField.text?.contains(" "))! {
            showToastBlackBackgraound(toastMessage: "Please Enter Full Name Properly", duration: 1, position: .center)
            fullNameTextField.becomeFirstResponder()
            return false
        } else if (emailTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Email", duration: 1, position: .center)
            emailTextField.becomeFirstResponder()
            return false
        } else if !isEmailValid(emailTextField.text!) {
            showToastBlackBackgraound(toastMessage: "Please Enter Valid Email", duration: 1, position: .center)
            emailTextField.becomeFirstResponder()
            return false
        } else if (phoneNoTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Phone No.", duration: 1, position: .center)
            phoneNoTextField.becomeFirstResponder()
            return false
        }
        
        return true
    }
    
    //MARK:- Button Actions -
    
    //    @IBAction func continueButtonAction(_ sender: Any) {
    //        if validateUserEnterDetails() {
    //            showToastWhiteBackgraound(toastMessage: UnderDevelopment, duration: 1, position: .center)
    //        }
    //    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerButtonAction(_ sender: Any) {
        //Social media registration
        if forPurpose == WSRequest.LoginWithTwitterWS() ||
            forPurpose == WSRequest.LoginWithFBWS() ||
            forPurpose == WSRequest.LoginWithGoogleWS() {
            
            if validateUserEnterDetailsForSocialMedia() {
                var facebook_id = ""
                var google_id = ""
                var twitter_id = ""
                
                if let id = self.dictDetails!["facebook_id"] as? String {
                    facebook_id = id
                }
                
                if let id = self.dictDetails!["google_id"] as? String {
                    google_id = id
                }
                
                if let id = self.dictDetails!["twitter_id"] as? String {
                    twitter_id = id
                }
                
                let parameters:[String:Any] = ["name":self.fullNameTextField.text!,
                                               "email_address":self.emailTextField.text!,
                                               "phone_number":self.phoneNoTextField.text!,
                                               "facebook_id":facebook_id,
                                               "google_id":google_id,
                                               "twitter_id":twitter_id]
                
                self.WebServiceSubmit(parameters: parameters, APIName: WSRequest.RegisterSocialMediaWS())
            }
        } else {
            //Regular Registration
            if validateUserEnterDetails() {
                let parameters:[String:Any] = ["name":self.fullNameTextField.text!,
                                               "email_address":self.emailTextField.text!,
                                               "phone_number":self.phoneNoTextField.text!,
                                               "password":self.confirmPassTextField.text!]
                
                self.WebServiceSubmit(parameters: parameters, APIName: WSRequest.RegisterWS())
            }
        }
    }
    
    func WebServiceSubmit(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.dismissProgress()
                    
                    let objAlertController = UIAlertController(title: CONGRATULATIONS, message: message, preferredStyle: .alert)
                    
                    let objAction = UIAlertAction(title: "OK", style: .default, handler:
                    {Void in
                        let profileDict = responseData["response"] as! [String:Any]
                        Utility.setUserID(profileDict["user_id"] as! String)
                        Utility.setEmail(profileDict["email_address"] as! String)
                        Utility.setPhoneNo(profileDict["phone_number"] as! String)
                        Utility.setProfileURL(profileDict["profile_picture"] as! String)
                        Utility.setUserName(profileDict["name"] as! String)
                        Utility.setLoginStatus()
                        
                        let VC:HomeVC! = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
                        self.navigationController?.pushViewController(VC, animated: true)
                        
//                        let VC:LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
//                        self.navigationController?.pushViewController(VC, animated: true)
                    })
                    objAlertController.addAction(objAction)
                    self.present(objAlertController, animated: true, completion: nil)
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
    
}
