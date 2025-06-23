//
//  PurchaseHistoryVC.swift
//  EventNotifier
//
//  Created by Sanjay on 13/04/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit
import SideMenu

class PurchaseHistoryVC: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK:- IBOutlets Declaration -
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noDataFoundLabel: UILabel!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var notificationCountLabel: UILabel!
    
    var eventArrayList = [[String:Any]]()
    var searchedArray = [[String:Any]]()
    var isSearching = false
    
    
    //MARK:- View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getEventHistoryWebService(parameters: ["user_id":Utility.getUserID()], APIName: WSRequest.BookingHistoryWS())
        searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
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
    
    
    @objc private func textFieldDidChange(textField: UITextField){
        let text = textField.text!
        if text == "" {
            isSearching = false
            //            self.totalCount.text="Total : \(self.favouriteListArray.count)"
        } else {
            isSearching = true
            let array = self.eventArrayList
            let resultPredicate: NSPredicate = NSPredicate(format: "event_name contains[c] %@", text)
            searchedArray = (array.filter { resultPredicate.evaluate(with: ($0))})
            
            if searchedArray.count == 0 {
                noDataFoundLabel.isHidden = false
            } else {
                noDataFoundLabel.isHidden = true
            }
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    
    // the controller that has a reference to the collection view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
    }
    
    
    // MARK: - Table View Delegates/Datasources -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching == true {
            return searchedArray.count
        } else {
            return eventArrayList.count
        }
    }
    
    fileprivate func bindCellData(_ cell: HomeTableViewCell,eventListDict:[String:Any]) {
        let date = self.getDateInCustmizeFormat("yyyy-MM-dd", dateString: eventListDict["event_date"] as! String, dateFormatterOutputString: "dd MMM yyyy")
        //            let time = self.getDateInCustmizeFormat("hh:mm:ss", dateString: eventListDict["event_starttime"] as! String, dateFormatterOutputString: "hh:mm a")
        
        cell.titleLabel.text = eventListDict["event_name"] as? String
        cell.amountLabel.text = "$\(eventListDict["total_price"] as! String)"
        cell.addressLabel.text = eventListDict["event_place"] as? String
        cell.datetimeLabel.text = date + " " + "\(eventListDict["event_starttime"] as! String)"
        cell.ticketLabel.text = "\(eventListDict["no_of_tickets"] as! String) Ticket"
        
        if let urlString = eventListDict["image"] as? String {
            if let imageURL:URL = URL(string: urlString) {
                //                    SDImageCache.shared().clearMemory()
                //                    SDImageCache.shared().clearDisk()
                cell.backgroundImageView.sd_setShowActivityIndicatorView(true)
                cell.backgroundImageView.sd_setIndicatorStyle(.whiteLarge)
                cell.backgroundImageView.sd_setImage(with: imageURL, completed: { (image, error, cache, urls) in
                    if (error != nil) {
                        cell.backgroundImageView.image = UIImage(named: "default-thumb")
                    } else {
                        cell.backgroundImageView.image = image
                    }
                })
                
            } else {
                cell.backgroundImageView.image = UIImage(named:"default-thumb")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        cell.selectionStyle = .none
        
        var eventListDict = [String:Any]()
        if isSearching == true {
            eventListDict = self.searchedArray[indexPath.row]
        } else {
            eventListDict = self.eventArrayList[indexPath.row]
        }
        
        bindCellData(cell, eventListDict: eventListDict)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    
    
    
    //MARK:- Web Services Methods -
    
    func getEventHistoryWebService(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.eventArrayList = responseData["response"] as! [[String:Any]]
                    if self.eventArrayList.count == 0 {
                        self.tableView.isHidden = true
                        self.noDataFoundLabel.isHidden = false
                    } else {
                        self.tableView.isHidden = false
                        self.noDataFoundLabel.isHidden = true
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    self.showAlertView(title: "Sorry!", message: message)
                    self.tableView.isHidden = true
                    self.noDataFoundLabel.isHidden = false
                }
                self.dismissProgress()
            })
            
        } else {
            self.dismissProgress()
            self.showAlertView(title: NetworkIssueTitle, message: NoInternetConnectionMessage)
        }
    }

    
    //MARK:- Button Actions -
    
    @IBAction func SideMenuAction(sender: AnyObject) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
//        let VC:NotificationVC! = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC
//        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    @IBAction func clsoeSearchButtonAction(_ sender: UIButton) {
        if !(searchTextField.text?.isEmpty)! {
            searchTextField.text = ""
            searchTextField.resignFirstResponder()
            isSearching = false
            tableView.reloadData()
            if self.eventArrayList.count == 0 {
                self.tableView.isHidden = true
                self.noDataFoundLabel.isHidden = false
            } else {
                self.tableView.isHidden = false
                self.noDataFoundLabel.isHidden = true
            }
        }
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        self.view.endEditing(true)
        return false
    }
    
    
}
