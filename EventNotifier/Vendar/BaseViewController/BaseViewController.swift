//
//  BaseViewController.swift
//  DoggiePaddle
//
//  Created by Sanjay on 07/03/20.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit
import Toast_Swift
import SVProgressHUD
import EventKit
import SideMenu

class BaseViewController: UIViewController,UITextFieldDelegate {

    var fullName = {(fname:String,lname:String) -> String in
        return fname+" "+lname
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboard()
        
    }
    
    override func viewDidLayoutSubviews() {
        showSideMenu(view: self.view) // show sidemenu
    }

    func showAlertView(title : String, message : String){
        let alertController = UIAlertController( title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        //you can add custom actions as well
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(BaseViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showToastWhiteBackgraound(toastMessage:String,duration:TimeInterval, position:ToastPosition){
        self.view.hideToastActivity()
        ToastManager.shared.style.backgroundColor = UIColor.white.withAlphaComponent(1)
        ToastManager.shared.style.messageColor = UIColor.black
        self.view.makeToast(toastMessage, duration: duration, position: position)
    }
    
    func showToastBlackBackgraound(toastMessage:String,duration:TimeInterval, position:ToastPosition){
        self.view.hideToastActivity()
        ToastManager.shared.style.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        ToastManager.shared.style.messageColor = UIColor.white
        self.view.makeToast(toastMessage, duration: duration, position: position)
    }
    
    func isPhoneNumberValid(text: String) -> Bool {
        let regexp = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", regexp).evaluate(with: text)
    }
    
    func isZipCodeValid(text: String) -> Bool {
        let regexp = "^[0-9]{5}$"
        return NSPredicate(format: "SELF MATCHES %@", regexp).evaluate(with: text)
    }
    
    func isStateValid(text: String) -> Bool {
        let regexp = "^[A-Z]{2}$"
        return NSPredicate(format: "SELF MATCHES %@", regexp).evaluate(with: text)
    }
    
    func isCVCValid(text: String) -> Bool {
        let regexp = "^[0-9]{3,4}$"
        return NSPredicate(format: "SELF MATCHES %@", regexp).evaluate(with: text)
    }
    
    func isEmailValid(_ text: String) -> Bool {
        
        // NOTE: validating email addresses with regex is usually not the best idea.
        // This implementation is for demonstration purposes only and is not recommended for production use.
        // Regex source and more information here: http://emailregex.com
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: text)
    }
    
    func showProgress() {
        SVProgressHUD.show(withStatus: "Loading...")
    }
    
    func dismissProgress() {
        SVProgressHUD.dismiss()
    }
    
    func getDateInCustmizeFormat(_ dateFormatterInputString: String, dateString: String, dateFormatterOutputString:String) -> String {
        // how to use
        //  getDateInCustmizeFormat(dateFormat, dateString: dateString, dateFormatterToString: expectedDateFormat)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormatterInputString//"yyyy-MM-dd HH:mm:ss" //Your date format
        let date = dateFormatter.date(from: dateString) //according to date format your date string
        
        dateFormatter.dateFormat = dateFormatterOutputString //Your New Date format as per requirement change it own
        let newDate = dateFormatter.string(from: date!) //pass Date here
        //        print(newDate) //New formatted Date string
        
        return newDate
    }
    
    func createEventinTheCalendar(with title:String, forDate eventStartDate:Date, toDate eventEndDate:Date) {
        let store:EKEventStore = EKEventStore()
        store.requestAccess(to: .event) { (success, error) in
            if  error == nil {
                let event = EKEvent.init(eventStore: store)
                event.title = title
                event.calendar = store.defaultCalendarForNewEvents // this will return deafult calendar from device calendars
                event.startDate = eventStartDate
                event.endDate = eventEndDate
                
                let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -300, since: event.startDate))
                event.addAlarm(alarm)
                
                do {
                    try store.save(event, span: .thisEvent)
                    //event created successfullt to default calendar
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                
            } else {
                //we have error in getting access to device calnedar
                print("error = \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func createEventinTheCalendarFromString(with title:String, forDate eventStartDate:String, toDate eventEndDate:String) {
        let store:EKEventStore = EKEventStore()
        store.requestAccess(to: .event) { (success, error) in
            if  error == nil {
                let event = EKEvent.init(eventStore: store)
                event.title = title
                event.calendar = store.defaultCalendarForNewEvents // this will return deafult calendar from device calendars
                let startdf = DateFormatter()
                startdf.dateFormat = "yyyy-MM-dd hh:mm a"
                let enddf = DateFormatter()
                enddf.dateFormat = "yyyy-MM-dd"
                
                event.startDate = startdf.date(from: eventStartDate) //eventStartDate
                event.endDate = enddf.date(from: eventEndDate) //eventEndDate
                
                let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -60, since: event.startDate))
                event.addAlarm(alarm)
                
                do {
                    try store.save(event, span: .thisEvent)
                    //event created successfullt to default calendar
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                
            } else {
                //we have error in getting access to device calnedar
                print("error = \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func resetDate(forDate:String,timedate:String) ->String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"//"yyyy-MM-dd"
        let tf = DateFormatter()
        tf.dateFormat = "hh:mm a"
        var resultdate = Date()
        var resultString = ""
        
        if let dateFromString = df.date(from: forDate) {
            let hour = NSCalendar.current.component(.hour, from: tf.date(from: timedate)!)
            let minutes = NSCalendar.current.component(.minute, from: tf.date(from: timedate)!)
            
            if let dateFromStringWithTime = NSCalendar.current.date(bySettingHour: hour, minute: minutes, second: 0, of: dateFromString) {
                let df = DateFormatter()
//                df.timeZone = TimeZone.ReferenceType.local//added now
                df.timeZone = TimeZone(abbreviation: "UTC")
                df.dateFormat = "yyyy-MM-dd hh:mm a"//"yyyy-MM-dd HH:mm:ss.SSS'Z"
                resultString = df.string(from: dateFromStringWithTime)
                resultdate = df.date(from: resultString)!
            }
        }
        
//        if let dateFromString = df.date(from: df.string(from: forDate)) {
//
//            let hour = NSCalendar.current.component(.hour, from: timedate as Date)
//            let minutes = NSCalendar.current.component(.minute, from: timedate as Date)
//            if let dateFromStringWithTime = NSCalendar.current.date(bySettingHour: hour, minute: minutes, second: 0, of: dateFromString) {
//                let df = DateFormatter()
//                df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS'Z"
//                let resultString = df.string(from: dateFromStringWithTime)
//                resultdate = df.date(from: resultString)!
//            }
//        }
        return resultString
    }

    
    func resetTime(forDate:NSDate,timedate:NSDate) ->Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        var resultdate = Date()
        if let dateFromString = df.date(from: df.string(from: forDate as Date)) {
            
            let hour = NSCalendar.current.component(.hour, from: timedate as Date)
            let minutes = NSCalendar.current.component(.minute, from: timedate as Date)
            if let dateFromStringWithTime = NSCalendar.current.date(bySettingHour: hour, minute: minutes, second: 0, of: dateFromString) {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS'Z"
                let resultString = df.string(from: dateFromStringWithTime)
                resultdate = df.date(from: resultString)!
            }
        }
        return resultdate
    }

    func showSideMenu(view: UIView) {
        // Define the menus
//        let sideMenuObj : SideMenuViewController! = SideMenuViewController(nibName: "SideMenuViewController", bundle: nil)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let sideMenuObj : SideMenuViewController! = storyBoard.instantiateViewController(withIdentifier: "SideMenuViewController") as? SideMenuViewController
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: sideMenuObj)
        menuLeftNavigationController.leftSide = true
        // UISideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration
        // of it here like setting its viewControllers. If you're using storyboards, you'll want to do something like:
        // let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the view controller it displays!

        //        SideMenuManager.menuAddPanGestureToPresent(toView: view) //self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: view, forMenu: .left)

        SideMenuManager.default.menuWidth = UIScreen.main.bounds.width - (UIScreen.main.bounds.width/5)
        SideMenuManager.default.menuDismissOnPush = true
        //        SideMenuManager.menuEnableSwipeGestures = false
        SideMenuManager.default.menuAllowPushOfSameClassTwice = false
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.clear

    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint,view:UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    func addImageToTextFieldAtRightSide(imageName:String, textField:UITextField) {
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 8.0, width: 20.0, height: 20.0))
        let image = UIImage(named: imageName)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        //        imageView.backgroundColor = UIColor.red
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 40))
        view.addSubview(imageView)
        view.backgroundColor = .clear
        textField.rightViewMode = .always
        textField.rightView = view
    }
    
     func addImageToTextFieldAtLeftSide(imageName:String, textField:UITextField) {
        let imageView = UIImageView(frame: CGRect(x: 8.0, y: 8.0, width: 24.0, height: 24.0))
        let image = UIImage(named: imageName)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        //        imageView.backgroundColor = UIColor.red
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        view.addSubview(imageView)
        view.backgroundColor = .clear
        textField.leftViewMode = .always
        textField.leftView = view
    }
    
}

class PasswordTextField: UITextField {
    
    override var isSecureTextEntry: Bool {
        didSet {
            if isFirstResponder {
                _ = becomeFirstResponder()
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        
        let success = super.becomeFirstResponder()
        if isSecureTextEntry, let text = self.text {
            self.text?.removeAll()
            insertText(text)
        }
        return success
    }
    
}
