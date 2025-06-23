//
//  ChangePasswordVC.swift
//  EventNotifier
//
//  Created by Sanjay on 13/04/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit
import SideMenu

class ChangePasswordVC: BaseViewController {
    
    @IBOutlet weak var oldPassTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var changePassButton: UIButton!
    @IBOutlet var notificationCountLabel: UILabel!
    
    //MARK:- View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.getCountInfo(_:)), name: Notification.Name(rawValue: "GetNotificationCount"), object: nil)
    }
    
    @objc func getCountInfo(_ notification: Notification) {
        if let info = (notification as NSNotification).userInfo!["type"] as? String {
            if info == "Count" {
                if (notification as NSNotification).userInfo!["notification_count"] as! String == "0" {
                    self.notificationCountLabel.isHidden = true
                } else {
                    self.notificationCountLabel.isHidden = false
                    self.notificationCountLabel.text = (notification as NSNotification).userInfo!["notification_count"] as? String
                }
                
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.changePassButton.cornerRadius = self.changePassButton.frame.size.height/2
    }
    
    func validateUserEnterDetails() -> Bool {
        
        if (oldPassTextField.text?.isEmpty)! && (newPassTextField.text?.isEmpty)! && (confirmPassTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please fill all fields", duration: 1, position: .center)
            return false
        } else if (oldPassTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Old Password", duration: 1, position: .center)
            oldPassTextField.becomeFirstResponder()
            return false
        } else if (newPassTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter New Password", duration: 1, position: .center)
            newPassTextField.becomeFirstResponder()
            return false
        } else if newPassTextField.text!.count < 7 {
            showToastBlackBackgraound(toastMessage: "Password should be atleast 7 characters", duration: 1, position: .center)
            newPassTextField.becomeFirstResponder()
            return false
        } else if (confirmPassTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Confirm Password", duration: 1, position: .center)
            confirmPassTextField.becomeFirstResponder()
            return false
        } else if newPassTextField.text! != confirmPassTextField.text! {
            showToastBlackBackgraound(toastMessage: "New & Confirm Password must be match.", duration: 1, position: .center)
            return false
        }
        return true
    }
    
    
    //MARK:- Button Actions -
    
    @IBAction func SideMenuAction(sender: AnyObject) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func changePassButtonAction(_ sender: Any) {
        if validateUserEnterDetails() {
            let parameters:[String:Any] = ["user_id":Utility.getUserID(),
                                           "password":self.confirmPassTextField.text!,
                                           "old_password":self.oldPassTextField.text!]
            self.WebService(parameters: parameters, APIName: WSRequest.ChangePasswordWS())
        }
    }
    
    @IBAction func notificationButtonAction(_ sender: UIButton) {
        let VC:NotificationVC! = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    //MARK:- Web Services Methods -
    
    func WebService(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    let objAlertController = UIAlertController(title: CONGRATULATIONS, message: message, preferredStyle: .alert)
                    
                    let objAction = UIAlertAction(title: "OK", style: .default, handler:
                    {Void in
                        self.oldPassTextField.text = ""
                        self.newPassTextField.text = ""
                        self.confirmPassTextField.text = ""
                        self.navigationController?.popToViewController(vc: HomeVC.self, animated: true)
                    })
                    objAlertController.addAction(objAction)
                    
                    self.present(objAlertController, animated: true, completion: nil)
                    
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
    
    
}
