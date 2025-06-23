//
//  MyProfileVC.swift
//  EventNotifier
//
//  Created by Sanjay on 15/04/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit
import SideMenu
import Alamofire
import SDWebImage


protocol UpdateProfileInfo:class {
    func updateProfileInfo()
}

class MyProfileVC: BaseViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobNoTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet var notificationCountLabel: UILabel!
    
    //MARK:- Variable Declarations
//    var userImage: UIImage?
    var imageName = String()
    var profileImageFlag = false
    var delegate:UpdateProfileInfo!


    //MARK:- View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.addTarget(self, action: #selector(emailtextfieldChanged(_:)), for: UIControl.Event.editingChanged)
        
        let parameters:[String:Any] = ["user_id":Utility.getUserID()]
        self.setMaxLength()
        self.getProfileWebService(parameters: parameters, APIName: WSRequest.GetProfileWS())
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.getCountInfo(_:)), name: Notification.Name(rawValue: "GetNotificationCount"), object: nil)
    }
    
    @objc private func emailtextfieldChanged(_ textField: UITextField) {
        if let text:String = self.emailTextField.text {
            DispatchQueue.main.async {
                self.emailTextField.text = text.lowercased()
            }
        }
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
    
    private func setMaxLength() {
        mobNoTextField.addTarget(self, action: #selector(textfieldChanged(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc private func textfieldChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let trimmed = text.prefix(10)
        textField.text = String(trimmed)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.saveButton.cornerRadius = self.saveButton.frame.size.height/2
        profileImageView.setRounded(borderWidth: 0, borderColor: UIColor.black)
        profileImageView.layoutIfNeeded()
    }
    
    func validateUserEnterDetails() -> Bool {
        
        if (fullNameTextField.text?.isEmpty)! && (emailTextField.text?.isEmpty)! && (mobNoTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please fill All Fields", duration: 1, position: .center)
            return false
        } else if (fullNameTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Full Name", duration: 1, position: .center)
            fullNameTextField.becomeFirstResponder()
            return false
        } else if (emailTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Email", duration: 1, position: .center)
            emailTextField.becomeFirstResponder()
            return false
        } else if (mobNoTextField.text?.isEmpty)! {
            showToastBlackBackgraound(toastMessage: "Please Enter Mobile No.", duration: 1, position: .center)
            mobNoTextField.becomeFirstResponder()
            return false
        }
        
        return true
    }
    
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == self.mobNoTextField
//        {
//            let maxLength = 10
//            let currentString: NSString = textField.text! as NSString
//            let newString: NSString =
//                currentString.replacingCharacters(in: range, with: string.uppercased()) as NSString
//            return newString.length <= maxLength
//
//        }
//        return true
//    }
    
    //MARK:- Button Actions -
    
    @IBAction func sideMenuAction(sender: AnyObject) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        if validateUserEnterDetails() {
            self.updateProfileInfoWebService()
        }
    }
    
    @IBAction func changeProfileImageButtonAction(_ sender: Any) {
        self.showActionSheet()
    }
    
    @IBAction func notificationButtonAction(_ sender: UIButton) {
        let VC:NotificationVC! = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    //MARK:- Web Services Methods -
    
    func getProfileWebService(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    let profileDict = responseData["response"] as! [String:Any]
                    self.updateBasicInfo(profileDict)
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
    
    func updateProfileInfoWebService() {
        
        DispatchQueue.main.async {//DispatchQueue.global(qos: .background).async {
            self.showProgress()
            let urlString = "\(BaseURL)\(WSRequest.UpdateProfileWS())"
            let parameters:[String:Any] = ["user_id":Utility.getUserID(),
                "name":self.fullNameTextField.text!,
                "phone_no":self.mobNoTextField.text!]
            
            let imgData:Data!
//            if (self.userImage) != nil {
//                imgData = self.userImage!.jpegData(compressionQuality: 0.2)
//            } else {
                imgData = self.profileImageView.image!.jpegData(compressionQuality: 0.2)
//            }
            
            print("urlString:",urlString)
            print("parameters:",parameters)
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imgData, withName: "profile_photo",fileName: "profile_photo.jpg", mimeType: "image/jpg")
                for (key, value) in parameters {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            },
                             to:urlString)
            { (result) in
                
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        print("response:",response.result.value!)
                        let json:[String:Any] = (response.result.value as? [String:Any])!
                        print("Response:",json)
                        let str = json["message"] as! String
                        print("\(str)")
                        self.dismissProgress()
                        if json["message_code"] as! Int == 0 {
                            self.showAlertView(title: "Sorry!", message: str)
                        } else {
                            self.showAlertView(title: CONGRATULATIONS, message: str)
                            let dict = json["response"] as! [String:Any]
                            self.updateBasicInfo(dict)
                        }
                    }
                    
                case .failure(let encodingError):
                    self.dismissProgress()
                    self.showToastWhiteBackgraound(toastMessage: SometingWentWrongMessage, duration: 1, position: .center)
                    print(encodingError)
                }
            }
        }
    }
    
    //MARK:- ImagePicker Methods -
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = true
            imagePicker.showsCameraControls = true
            imagePicker.isToolbarHidden = true
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            self.showAlertView(title: "Warning", message: "Your device don't have camera.")
        }
    }
    
    func photoLibrary()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary;
            imagePicker.allowsEditing = true
            imagePicker.isToolbarHidden = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            picker.dismiss(animated: true, completion: nil)
        }
        
//        userImage = selectedImage
        profileImageFlag = true
        self.profileImageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func updateBasicInfo(_ profileDict: [String : Any]) {
        Utility.setUserID(profileDict["user_id"] as! String)
        Utility.setEmail(profileDict["email_address"] as! String)
        Utility.setPhoneNo(profileDict["phone_number"] as! String)
        Utility.setProfileURL(profileDict["profile_picture"] as! String)
        Utility.setUserName(profileDict["name"] as! String)
        
        
        self.fullNameTextField.text = profileDict["name"] as? String
        self.mobNoTextField.text = profileDict["phone_number"] as? String
        self.emailTextField.text = profileDict["email_address"] as? String
        
        if let urlString = profileDict["profile_picture"] as? String {
            if let imageURL:URL = URL(string: urlString) {
                SDImageCache.shared().clearMemory()
                SDImageCache.shared().clearDisk()
                self.profileImageView.sd_setShowActivityIndicatorView(true)
                self.profileImageView.sd_setIndicatorStyle(.gray)
                self.profileImageView.sd_setImage(with: imageURL, completed: { (image, error, cache, urls) in
                    if (error != nil) {
                        self.profileImageView.image = UIImage(named: "upload_profile_pic_img")
                    } else {
                        self.profileImageView.image = image
                    }
                })
                
            } else {
                self.profileImageView.image = UIImage(named:"upload_profile_pic_img")
            }
        } else {
            self.profileImageView.image = UIImage(named:"upload_profile_pic_img")
        }
        
        self.delegate.updateProfileInfo()
    }
    
    
    
    
}
