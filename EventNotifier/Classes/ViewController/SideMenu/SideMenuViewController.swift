//
//  SideMenuViewController.swift
//  TimeStamp
//
 

import UIKit
import SDWebImage
import Alamofire
import Cosmos
//protocol getCountInfoDelegate: class {
//    func setUserInfo(dict:[String:Any]!)
//}


class SideMenuViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UpdateProfileInfo {
    
    
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
//    @IBOutlet weak var ratingCountLabel: UILabel!
//    @IBOutlet weak var ratingCosmosView: CosmosView!
    @IBOutlet weak var tableView: UITableView!
    
    var userImage: UIImage!
    var imageName = String()
    
    var arraySideMenuTitle: [String]! = [String]()
    var arrayDict: [[String:Any]]! = [[String:Any]]()
    var arraySideMenuImages: [String]! = [String]()
//    weak var delegate: getCountInfoDelegate?
    
    
    //MARK:- View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.tableView.tableFooterView = UIView()
//        NotificationCenter.default.addObserver(self, selector: #selector(SideMenuViewController.setAndUpdateCounts(_:)), name: Notification.Name(rawValue: "setAndUpdateCounts"), object: nil)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = .lightContent
        
//        ratingCosmosView.settings.fillMode = .precise
//        ratingCosmosView.rating = Double(4.5)
        
//        let tapUserImage = UITapGestureRecognizer(target: self, action: #selector(SideMenuViewController.handleTapUserImage))
//        profileImageView?.addGestureRecognizer(tapUserImage)
//        profileImageView.layer.cornerRadius = 10
//        self.profileImageView.clipsToBounds = true
        
        self.profileBasicInfo()
    }
    
    func updateProfileInfo() {
        self.profileBasicInfo()
    }
    
    fileprivate func profileBasicInfo() {
        
        userNameLabel.text = Utility.getUserName()
        emailLabel.text = Utility.getEmail()
        
        self.profileImageView.setRounded(borderWidth: 1, borderColor: .white)
        
        if let imageURL:URL = URL(string: Utility.getProfileURL()) {
            SDImageCache.shared().clearMemory()
            SDImageCache.shared().clearDisk()
            self.profileImageView.sd_setShowActivityIndicatorView(true)
            self.profileImageView.sd_setIndicatorStyle(.whiteLarge)
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
    }
    
//    @objc func setAndUpdateCounts(_ notification: Notification) {
//        // animate the text field to stay above the keyboard
////        let info = (notification as NSNotification).userInfo!
//        if let dict = notification.userInfo as NSDictionary? {
//            if Utility.getUserType() == USER {
//                arrayDict = [["name":"Your Children","count":String(describing: dict["child_cnt"]!)],["name":"Your Destinations","count":String(describing: dict["dest_cnt"]!)],["name":"Payment Methods","count":String(describing: dict["card_cnt"]!)],["name":"Notifications","count":"0"],["name":"Account Settings","count":"0"],["name":"Logout","count":"0"]]
//            } else if Utility.getUserType() == DRIVER {
//                arrayDict = [["name":"Waiting","count":"0"],["name":"Active","count":"0"],["name":"Completed","count":"0"],["name":"Rates","count":"0"],["name":"Edit Profile","count":"0"],["name":"Logout","count":"0"]]
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
    
//    func setUserInfo(dict:[String:Any]!) {
//        print("Dict:",dict)
//        if Utility.getUserType() == USER {
//            arrayDict = [["name":"Your Children","count":String(describing: dict["child_cnt"]!)],["name":"Your Destinations","count":String(describing: dict["dest_cnt"]!)],["name":"Payment Methods","count":String(describing: dict["card_cnt"]!)],["name":"Notifications","count":"0"],["name":"Account Settings","count":"0"],["name":"Logout","count":"0"]]
//        } else if Utility.getUserType() == DRIVER {
//            arrayDict = [["name":"Waiting","count":"0"],["name":"Active","count":"0"],["name":"Completed","count":"0"],["name":"Rates","count":"0"],["name":"Edit Profile","count":"0"],["name":"Logout","count":"0"]]
//        }
//        
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//    }
    
    @objc func handleTapUserImage(_ sender:UITapGestureRecognizer) {
        showActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        startButton.layer.cornerRadius = startButton.frame.size.height/2
        
        profileImageView.setRounded(borderWidth: 1, borderColor: UIColor.white)
        profileImageView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        arrayDict = [["name":"Home","imageName":"home_navigation"],
                     ["name":"Upcoming Events","imageName":"upcoming_events_navigation"],
                     ["name":"Past Events","imageName":"past_events_navigation"],
                     ["name":"Purchase History","imageName":"tickets_navigation"],
                     ["name":"Change Password","imageName":"tickets_navigation"],
                     ["name":"Log Out","imageName":"logout_navigation"]]
        
        
        //            arraySideMenuTitle = ["Your Children","Your Destinations","Payment Methods","Notifications","Account Settings","Logout"]
//        arraySideMenuImages = ["profile","add_another_destination","cardSideMenu","notifications","settings","logout"]
        
        self.tableView.reloadData()
        
//        userNameLabel.text = Utility.getUserName()
//        addressLabel.text = Utility.getEmail()
//
//        if let imageURL:URL = URL(string: Utility.getProfileURL()) {
//
//            SDImageCache.shared().clearMemory()
//            SDImageCache.shared().clearDisk()
//
//            self.profileImageView.sd_setShowActivityIndicatorView(true)
//            self.profileImageView.sd_setIndicatorStyle(.whiteLarge)
//            self.profileImageView.sd_setImage(with: imageURL, completed: { (image, error, cache, urls) in
//                if (error != nil) {
//                    self.profileImageView.image = UIImage(named: "upload_profile_pic_img")
//                } else {
//                    self.profileImageView.image = image
//                }
//            })
//
//        } else {
//            self.profileImageView.image = UIImage(named:"upload_profile_pic_img")
//        }
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
        
    }
    
    // MARK: - Table View Delegates -
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SideMenuTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell", for: indexPath) as? SideMenuTableViewCell
        
        cell.imageViewIcon.image = UIImage(named:"\(String(describing: arrayDict[indexPath.row]["imageName"]!))")
        cell.labelTitle.text = arrayDict[indexPath.row]["name"] as? String// as? String
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.getNotificationsWebService(parameters: ["user_id":Utility.getUserID()], APIName: WSRequest.NotificationCountWS())
        
        if indexPath.row != 5 {
            self.navigationController?.popToViewController(vc: HomeVC.self, animated: false)
        }
        
        switch indexPath.row {
        case 0:
            let VC:HomeVC! = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
            self.navigationController?.pushViewController(VC, animated: false)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "HomeVC"), object: nil, userInfo:["type":"Upcoming"])
            break
        case 1:
            let VC:HomeVC! = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
            self.navigationController?.pushViewController(VC, animated: false)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "HomeVC"), object: nil, userInfo:["type":"Upcoming"])
            break
        case 2:
            let VC:HomeVC! = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
            self.navigationController?.pushViewController(VC, animated: false)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "HomeVC"), object: nil, userInfo:["type":"Past"])
            break
        case 3:
            let VC:PurchaseHistoryVC! = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseHistoryVC") as? PurchaseHistoryVC
            self.navigationController?.pushViewController(VC, animated: false)
            break
        case 4:
            let VC:ChangePasswordVC! = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC
            self.navigationController?.pushViewController(VC, animated: false)
            break
        case 5:
            logout()
            break
            
        default: break
            
        }
        
        DispatchQueue.main.async {
            if indexPath.row != 5 {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func logout() {
        
        DispatchQueue.main.async {
            let objAlertController = UIAlertController(title: "LOGOUT", message: "Do you really want to LOGOUT?", preferredStyle: .alert)
            
            let objAction = UIAlertAction(title: "CONFIRM", style: .destructive, handler:
            {Void in
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let LoginViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UserDefaults.standard.set(nil, forKey: "loginStatus")
                UserDefaults.standard.synchronize()
                print("LoginStatus:",Utility.getLoginStatus())
                Utility.setProfileURL("")
                self.navigationController?.pushViewController(LoginViewController, animated: true)
                
            })
            objAlertController.addAction(objAction)
            
            let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler:
            {Void in
                
            })
            objAlertController.addAction(cancelAction)
            
            self.present(objAlertController, animated: true, completion: nil)
        }
 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 70
//        return tableView.frame.size.height/6
    }
    
    //MARK:- Button Actions -
    
    @IBAction func startActivityButtonClick(_ sender: Any) {
        /*
        if Utility.getUserType() == USER {
//            self.showToastWhiteBackgraound(toastMessage: UnderDevelopment, duration: 1.5, position: .center)
            if validateBookService() {
                let VC:BookARideViewController! = self.storyboard?.instantiateViewController(withIdentifier: "BookARideViewController") as! BookARideViewController
                self.navigationController?.pushViewController(VC, animated: false)
            }
        } else if Utility.getUserType() == DRIVER {
//            self.showToastWhiteBackgraound(toastMessage: UnderDevelopment, duration: 1.5, position: .center)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ChildrenOnTheGoVC"), object: nil, userInfo:["type":"Waiting"])
            let VC:ChildrenOnTheGoVC! = self.storyboard?.instantiateViewController(withIdentifier: "ChildrenOnTheGoVC") as! ChildrenOnTheGoVC
            VC.forFlag = "Waiting"
            self.navigationController?.pushViewController(VC, animated: false)
        }
        */
    }
    
    @IBAction func closeSideMenuButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editSideMenuButtonClick(_ sender: Any) {
        let VC:MyProfileVC! = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as? MyProfileVC
        VC.delegate = self
        self.navigationController?.pushViewController(VC, animated: false)
    }
    
    func setUserInfo(_ userName:String!, userImage:UIImage!) {
        print("userName:",userName)
        DispatchQueue.main.async {
            self.userNameLabel.text = userName
            if let imageURL:URL = URL(string: Utility.getProfileURL()) {
                SDImageCache.shared().clearMemory()
                SDImageCache.shared().clearDisk()
                self.profileImageView.sd_setShowActivityIndicatorView(true)
                self.profileImageView.sd_setIndicatorStyle(.gray)
                self.profileImageView.sd_setImage(with: imageURL, completed: { (image, error, cache, urls) in
                    if (error != nil) {
                        self.profileImageView.image = UIImage(named: "profileImage")
                    } else {
                        self.profileImageView.image = image
                    }
                })
                
            } else {
                self.profileImageView.image = UIImage(named:"profileImage")
            }
        }
    }
    
    //MARK:- ImagePicker Methods -
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: "Change Profile Photo", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose from Gallery", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
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
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.showsCameraControls = true
            imagePicker.isToolbarHidden = true
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            self.showAlertView(title: "Warning!", message: "Your device don't have camera.")
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
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        /*
        if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
            imageName   = (imageURL.lastPathComponent)
        }
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            userImage = img
        }
        else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            userImage = img
        }
        */
        self.profileImageView.image = userImage
        self.dismiss(animated: true, completion: nil)
        
//        callSaveUserProfileWebService()
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
    }    /*
    func callSaveUserProfileWebService()  {
        
        DispatchQueue.main.async {//DispatchQueue.global(qos: .background).async {
            self.showProgress()
            let urlString = "\(BaseURL)"//"\(WSRequest.updateProfilePhotoWS())"
            let parameters:[String:Any] = ["userID":Utility.getUserID()]
            
            let imgData:Data!
            if (self.userImage) != nil {
                imgData = UIImageJPEGRepresentation(self.userImage, 0.2)!
            } else {
                imgData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.2)!
            }
            
            print("urlString:",urlString)
            print("parameters:",parameters)
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imgData, withName: "photo",fileName: "profile_photo.jpg", mimeType: "image/jpg")
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
                        let json = response.result.value as? [String:Any]
                        print("Response:",json as Any)
                        let str = json?["message"] as? String!
                        print("\(str!)")
                        
                        //                        self.getUserProfile()
                        
                        let userDetailDict : [String:Any] = json!["user_data"] as! [String : Any]
                        if let profilePicURL = userDetailDict["photo"] as? String {
                            Utility.setProfileURL(profilePicURL)
                        }
                        
                        print("Profile Image:",Utility.getProfileURL())
                        DispatchQueue.main.async {
                            if let imageURL:URL = URL(string: Utility.getProfileURL()) {
                                self.profileImageView.sd_setShowActivityIndicatorView(true)
                                self.profileImageView.sd_setIndicatorStyle(.white)
                                self.profileImageView.sd_setImage(with: imageURL, completed: { (image, error, cache, urls) in
                                    if (error != nil) {
                                        self.profileImageView.image = UIImage(named: "profileImage")//health_care")
                                    } else {
                                        self.profileImageView.image = image
                                    }
                                    self.dismissProgress()
                                    //                        self.showToastBlackBackgraound(toastMessage: str!, duration: 1, position: .center)
                                    let objAlertController = UIAlertController(title: "Congratulations!", message: str!, preferredStyle: .alert)
                                    
                                    let objAction = UIAlertAction(title: "OK", style: .default, handler:
                                    {Void in
                                        //                            self.getUserProfile()
                                    })
                                    objAlertController.addAction(objAction)
                                    
                                    self.present(objAlertController, animated: true, completion: nil)
                                })
                                
                            }
                            
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
    */
}
