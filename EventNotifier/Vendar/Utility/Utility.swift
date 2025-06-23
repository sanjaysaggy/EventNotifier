//
//  Utility.swift
//  DoggiePaddle
//
//  Created by Sanjay on 07/03/18.
//  Copyright © 2018 Sanjay. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import AVFoundation

class Utility {
        
    class func showToastWithWhiteBackgraound(message:String){
        ToastManager.shared.style.backgroundColor = UIColor.white
    }
    
    class func getLoginStatus() -> Bool {
        return (UserDefaults.standard.string(forKey: "loginStatus") == nil ? false : true)
    }
    
    class func setLoginStatus(){
        UserDefaults.standard.set(true, forKey: "loginStatus")
        UserDefaults.standard.synchronize()
    }
    
    class func getUserID() -> String {
        return UserDefaults.standard.string(forKey: "UserID") ?? Blank
    }
    
    class func setUserID(_ userID : String){
        UserDefaults.standard.set(userID, forKey: "UserID")
        UserDefaults.standard.synchronize()
    }
    
    class func getUserName() -> String {
        return UserDefaults.standard.string(forKey: "UserName") ?? Blank
    }
    
    class func setUserName(_ userName : String){
        UserDefaults.standard.set(userName, forKey: "UserName")
        UserDefaults.standard.synchronize()
    }
    
    class func getUserFirstName() -> String {
        return UserDefaults.standard.string(forKey: "UserFirstName") ?? Blank
    }
    
    class func setUserFirstName(_ userFirstName : String){
        UserDefaults.standard.set(userFirstName, forKey: "UserFirstName")
        UserDefaults.standard.synchronize()
    }
    
    class func getUserLastName() -> String {
        return UserDefaults.standard.string(forKey: "UserLastName") ?? Blank
    }
    
    class func setUserLastName(_ userLastName : String){
        UserDefaults.standard.set(userLastName, forKey: "UserLastName")
        UserDefaults.standard.synchronize()
    }
    
    class func getPhoneNo() -> String {
        return UserDefaults.standard.string(forKey: "PhoneNo") ?? Blank
    }
    
    class func setPhoneNo(_ PhoneNo : String){
        UserDefaults.standard.set(PhoneNo, forKey: "PhoneNo")
        UserDefaults.standard.synchronize()
    }
    
    class func getCity() -> String {
        return UserDefaults.standard.string(forKey: "City") ?? Blank
    }
    
    class func setCity(_ City : String){
        UserDefaults.standard.set(City, forKey: "City")
        UserDefaults.standard.synchronize()
    }
    
    class func getCurrentDrivingAddress() -> String {
        return UserDefaults.standard.string(forKey: "CurrentDrivingAddress") ?? Blank
    }
    
    class func setCurrentDrivingAddress(_ Address : String){
        UserDefaults.standard.set(Address, forKey: "CurrentDrivingAddress")
        UserDefaults.standard.synchronize()
    }
    
    class func getCurrentDrivingLatitude() -> String {
        return UserDefaults.standard.string(forKey: "CurrentDrivingLatitude") ?? Blank
    }
    
    class func setCurrentDrivingLatitude(_ Latitude : String){
        UserDefaults.standard.set(Latitude, forKey: "CurrentDrivingLatitude")
        UserDefaults.standard.synchronize()
    }
    
    class func getCurrentDrivingLongitude() -> String {
        return UserDefaults.standard.string(forKey: "CurrentDrivingLongitude") ?? Blank
    }
    
    class func setCurrentDrivingLongitude(_ Longitude : String){
        UserDefaults.standard.set(Longitude, forKey: "CurrentDrivingLongitude")
        UserDefaults.standard.synchronize()
    }
    
    class func setProfileURL(_ profileURL : String){
        UserDefaults.standard.set(profileURL, forKey: "ProfileURL")
        UserDefaults.standard.synchronize()
    }
    
    class func getProfileURL() -> String {
        return UserDefaults.standard.string(forKey: "ProfileURL") ?? Blank
    }
    
    class func getEmail() -> String {
        return UserDefaults.standard.string(forKey: "email_address") ?? Blank
    }
    
    class func setEmail(_ email : String){
        UserDefaults.standard.set(email, forKey: "email_address")
        UserDefaults.standard.synchronize()
    }
    
    class func getUserType() -> String {
        return UserDefaults.standard.string(forKey: "userType") ?? Blank
    }
    
    class func setUserType(_ userType : String){
        UserDefaults.standard.set(userType, forKey: "userType")
        UserDefaults.standard.synchronize()
    }
    
//    class func getMobileNo() -> String {
//        return UserDefaults.standard.string(forKey: "mobile_no") ?? Blank
//    }
//    
//    class func setMobileNo(_ mobile_no : String){
//        UserDefaults.standard.set(mobile_no, forKey: "mobile_no")
//        UserDefaults.standard.synchronize()
//    }
    
    class func getDeviceToken() -> String {
        return UserDefaults.standard.string(forKey: "DeviceToken") ?? Blank
    }
    
    class func setDeviceToken(_ DeviceToken : String){
        UserDefaults.standard.set(DeviceToken, forKey: "DeviceToken")
        UserDefaults.standard.synchronize()
    }
    
    class func getNotificationStatus() -> String {
        return UserDefaults.standard.string(forKey: "NotificationStatus") ?? Blank
    }
    
    class func setNotificationStatus(_ NotificationStatus : String){
        UserDefaults.standard.set(NotificationStatus, forKey: "NotificationStatus")
        UserDefaults.standard.synchronize()
    }
    
    class func makeDeviceVibrate() {
        AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, nil)
    }
    
    
    class func getDrivingStatus() -> Bool {
        return (UserDefaults.standard.string(forKey: "DrivingStatus") == nil ? false : true)
    }
    
    class func setDrivingStatus(){
        UserDefaults.standard.set(true, forKey: "DrivingStatus")
        UserDefaults.standard.synchronize()
    }
    
    class func setDrivingStatusNIL(){
        UserDefaults.standard.set(nil, forKey: "DrivingStatus")
        UserDefaults.standard.synchronize()
    }
    
    class func getCurrentDrivingID() -> String {
        return UserDefaults.standard.string(forKey: "CurrentDrivingID") ?? Blank
    }
    
    class func setCurrentDrivingID(_ CurrentDrivingID : String){
        UserDefaults.standard.set(CurrentDrivingID, forKey: "CurrentDrivingID")
        UserDefaults.standard.synchronize()
    }
    
    class func getCurrentDrivingStatus() -> String {
        return UserDefaults.standard.string(forKey: "CurrentDrivingStatus") ?? Blank
    }
    
    class func setCurrentDrivingStatus(_ CurrentDrivingStatus : String){
        UserDefaults.standard.set(CurrentDrivingStatus, forKey: "CurrentDrivingStatus")
        UserDefaults.standard.synchronize()
    }
    
    class func getCurrentDrivingChildrenInfo() -> [String:Any] {
        return UserDefaults.standard.value(forKey: "CurrentDrivingChildrenInfo") as! [String : Any]
    }
    
    class func setCurrentDrivingChildrenInfo(_ CurrentDrivingChildrenInfo : [String:Any]){
        UserDefaults.standard.set(CurrentDrivingChildrenInfo, forKey: "CurrentDrivingChildrenInfo")
        UserDefaults.standard.synchronize()
    }
    
    class func getWaitingCount() -> String {
        return UserDefaults.standard.string(forKey: "WaitingCount") ?? "0"
    }
    
    class func setWaitingCount(_ ChildCount : String){
        UserDefaults.standard.set(ChildCount, forKey: "WaitingCount")
        UserDefaults.standard.synchronize()
    }
    
    class func getActiveCount() -> String {
        return UserDefaults.standard.string(forKey: "ActiveCount") ?? "0"
    }
    
    class func setActiveCount(_ DestCount : String){
        UserDefaults.standard.set(DestCount, forKey: "ActiveCount")
        UserDefaults.standard.synchronize()
    }
    
    class func getCompletedCount() -> String {
        return UserDefaults.standard.string(forKey: "CompletedCount") ?? "0"
    }
    
    class func setCompletedCount(_ CardCount : String){
        UserDefaults.standard.set(CardCount, forKey: "CompletedCount")
        UserDefaults.standard.synchronize()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ///*********************
    
    class func getPMUserID() -> String {
        return UserDefaults.standard.string(forKey: "PMUserID") ?? Blank
    }
    
    class func setPMUserID(_ userID : String){
        UserDefaults.standard.set(userID, forKey: "PMUserID")
        UserDefaults.standard.synchronize()
    }
    
    class func getPMUserName() -> String {
        return UserDefaults.standard.string(forKey: "PMUserName") ?? Blank
    }
    
    class func setPMUserName(_ userName : String){
        UserDefaults.standard.set(userName, forKey: "PMUserName")
        UserDefaults.standard.synchronize()
    }
    
    class func getPMUserFirstName() -> String {
        return UserDefaults.standard.string(forKey: "PMUserFirstName") ?? Blank
    }
    
    class func setPMUserFirstName(_ userFirstName : String){
        UserDefaults.standard.set(userFirstName, forKey: "PMUserFirstName")
        UserDefaults.standard.synchronize()
    }
    
    class func getPMUserLastName() -> String {
        return UserDefaults.standard.string(forKey: "PMUserLastName") ?? Blank
    }
    
    class func setPMUserLastName(_ userLastName : String){
        UserDefaults.standard.set(userLastName, forKey: "PMUserLastName")
        UserDefaults.standard.synchronize()
    }
    
    class func getPMPhoneNo() -> String {
        return UserDefaults.standard.string(forKey: "PMPhoneNo") ?? Blank
    }
    
    class func setPMPhoneNo(_ PhoneNo : String){
        UserDefaults.standard.set(PhoneNo, forKey: "PMPhoneNo")
        UserDefaults.standard.synchronize()
    }
    
    class func getPMCity() -> String {
        return UserDefaults.standard.string(forKey: "PMCity") ?? Blank
    }
    
    class func setPMCity(_ City : String){
        UserDefaults.standard.set(City, forKey: "PMCity")
        UserDefaults.standard.synchronize()
    }
    class func setPMProfileURL(_ profileURL : String){
        UserDefaults.standard.set(profileURL, forKey: "PMProfileURL")
        UserDefaults.standard.synchronize()
    }
    
    class func getPMProfileURL() -> String {
        return UserDefaults.standard.string(forKey: "PMProfileURL") ?? Blank
    }
    
    class func getPMEmail() -> String {
        return UserDefaults.standard.string(forKey: "PMemail_address") ?? Blank
    }
    
    class func setPMEmail(_ email : String){
        UserDefaults.standard.set(email, forKey: "PMemail_address")
        UserDefaults.standard.synchronize()
    }
    
    class func getPMSelectedUser() -> String {
        return UserDefaults.standard.string(forKey: "PMSelectedUser") ?? Blank
    }
    
    class func setPMSelectedUser(_ PMSelectedUser : String){
        UserDefaults.standard.set(PMSelectedUser, forKey: "PMSelectedUser")
        UserDefaults.standard.synchronize()
    }
    
    
    
//    func noInternetConnectionToast() {
//        if let currentToast = ToastCenter.default.currentToast {
//            currentToast.cancel()
//        }
//        let toast = Toast(text: NoInternetConnectionMessage, duration: 1.5)
//        toast.show()
//    }
}
