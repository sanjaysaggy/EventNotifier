//
//  PaymentVC.swift
//  EventNotifier
//
//  Created by Sanjay on 13/04/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit
import Stripe

class PaymentVC: BaseViewController,CLPopListViewDelegate,STPPaymentCardTextFieldDelegate {
    
    @IBOutlet weak var cardNoTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    
    let cardParams = STPCardParams()
    var eventListDict = [String:Any]()
    var monthArrayList = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    var yearArrayList = ["2019","2020","2021","2022","2023","2024","2025","2026","2027","2028","2029","2030","2031","2032","2033","2034","2035","2036","2037","2038","2039","2040"]
    
    
    //MARK:- View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let amount = self.eventListDict["total_price"] as? String {
            self.totalAmountLabel.text = amount
        } else {
            self.totalAmountLabel.text = "$ 0.00"
        }
        self.addImageToTextFieldAtRightSide(imageName: "drop_down", textField: monthTextField)
        self.addImageToTextFieldAtRightSide(imageName: "drop_down", textField: yearTextField)
    }
    
    //MARK:- Button Actions -
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func payButtonAction(_ sender: UIButton) {
        if validateUserEnterDetails() {
            if checkCreadiCardValidation() {
                self.getStripeToken(self.cardParams)
            } else {
                self.showAlertView(title: "Sorry!", message: "Please Enter A Valid Credit Card")
            }
        }
    }
    
    @IBAction func notificationButtonAction(_ sender: UIButton) {
        let VC:NotificationVC! = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    //MARK:- General Methods -
    
    func validateUserEnterDetails() -> Bool {
        if (cardNoTextField.text?.count)! == 0 {
            showToastBlackBackgraound(toastMessage: "Please Enter Card Number", duration: 1, position: .center)
            return false
        } else if (monthTextField.text?.count)! == 0 {
            showToastBlackBackgraound(toastMessage: "Please Select Card Expiration Month", duration: 1, position: .center)
            return false
        } else if (yearTextField.text?.count)! == 0 {
            showToastBlackBackgraound(toastMessage: "Please Select Card Expiration Year", duration: 1, position: .center)
            return false
        } else if (cvvTextField.text?.count)! == 0 {
            showToastBlackBackgraound(toastMessage: "Please Enter CVV", duration: 1, position: .center)
            return false
        }
        
        return true
    }
    
    func checkCreadiCardValidation()  -> Bool {
//        let dateArray = textExpDate.text!.components(separatedBy: "/")
//        let expMonth = dateArray[0]//10
//        let expYear = dateArray[1]//2018
        cardParams.number = cardNoTextField.text!
        cardParams.expMonth = UInt(monthTextField.text!)!
        cardParams.expYear = UInt(yearTextField.text!)!
        cardParams.cvc = cvvTextField.text!
        
        //        cardParams.number = "4242424242424242"
        //        cardParams.expMonth = 10
        //        cardParams.expYear = 2018
        //        cardParams.cvc = "123"
        
        return STPCardValidator.validationState(forCard: cardParams) == .valid
    }
    
    func getStripeToken(_ card:STPCardParams) {
        // get stripe token for current card
        self.showProgress()
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            if let token = token {
                print("token:",token)
                print("Brand:",token.card?.brand as Any)
                print((STPCard.string(from: (token.card?.brand)!)))
                let cardType = (STPCard.string(from: (token.card?.brand)!))
                
                //API Calling
                let parameters:[String:String] = ["user_id":Utility.getUserID(),
                                                  "event_id":self.eventListDict["id"] as! String,
                                                  "event_price":self.eventListDict["price"] as! String,
                                                  "no_of_tickets":self.eventListDict["no_of_tickets"] as! String,
                                                  "total_price":(self.eventListDict["total_price"] as! String).replacingOccurrences(of: "$ ", with: ""),
                                                  "stripeToken":"\(token)"]
                self.WebService(parameters: parameters, APIName: WSRequest.EventBookingWS())
            } else {
                self.showAlertView(title: "Sorry!", message: SometingWentWrongMessage)
                print("error:",error as Any)
            }
        }
    }
    
    
    //MARK:- TextField Delegates -
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == monthTextField {
            let list : CLPopListView = CLPopListView(title: "Select Month", options: self.monthArrayList)
            list.delegate = self
            list.tag = 1
            list.allowScroll = true
            list.selectedIndex = 0
            list.show(in: appdelegate.window?.rootViewController?.view, animated: true)
            return false
        } else if textField == yearTextField {
            
            let list : CLPopListView = CLPopListView(title: "Select Year", options: self.yearArrayList)
            list.delegate = self
            list.tag = 2
            list.allowScroll = true
            list.selectedIndex = 0
            list.show(in: appdelegate.window?.rootViewController?.view, animated: true)
            
            return false
        }
        return true
    }
    
    //MARK:- Web Services Methods -
    
    func WebService(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.dismissProgress()
                    
                    let objAlertController = UIAlertController(title: CONGRATULATIONS, message: message, preferredStyle: .alert)
                    
                    let objAction = UIAlertAction(title: "OK", style: .default, handler:
                    {Void in
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "HomeVC"), object: nil, userInfo:["type":"Upcoming"])
                        self.navigationController?.popToViewController(vc: HomeVC.self, animated: true)
                    })
                    objAlertController.addAction(objAction)
                    
                    //                    let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler:
                    //                    {Void in
                    //
                    //                    })
                    //                    objAlertController.addAction(cancelAction)
                    
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
    
    
    //MARK:- CLPopListView Delegate -
    
    func leveyPopListView(_ popListView: CLPopListView!, didSelectedIndex anIndex: Int) {
        if popListView.tag == 1 {
            self.monthTextField.text = self.monthArrayList[anIndex]
        } else if popListView.tag == 2 {//Make
            self.yearTextField.text = self.yearArrayList[anIndex]
        }
    }
}
