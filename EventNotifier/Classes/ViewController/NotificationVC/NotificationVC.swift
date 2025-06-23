//
//  NotificationVC.swift
//  EventNotifier
//
//  Created by Sanjay on 15/04/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit
import SideMenu

class NotificationVC: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK:- IBOutlets Declaration -
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noDataFoundLabel: UILabel!
    
    
    var notificationsArrayList = [[String:Any]]()
    
    
    //MARK:- View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getNotificationsWebService(parameters: ["user_id":Utility.getUserID()], APIName: WSRequest.NotificationMarkAsReadWS())
        self.getNotificationsWebService(parameters: ["user_id":Utility.getUserID()], APIName: WSRequest.GetNotificationListingWS())
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
        return notificationsArrayList.count
    }

    fileprivate func bindCellData(_ cell: NotificationsTableViewCell,eventListDict:[String:Any]) {
        let date = self.getDateInCustmizeFormat("yyyy-MM-dd hh:mm:ss", dateString: eventListDict["created_dt"] as! String, dateFormatterOutputString: "dd MMM yyyy")
        let time = self.getDateInCustmizeFormat("yyyy-MM-dd hh:mm:ss", dateString: eventListDict["created_dt"] as! String, dateFormatterOutputString: "hh:mm a")
        
        cell.titleLabel.text = eventListDict["msg"] as? String
        cell.dateTimeLabel.text = date + ", " + time
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTableViewCell", for: indexPath) as! NotificationsTableViewCell
        cell.selectionStyle = .none
        
        var eventListDict = [String:Any]()
        eventListDict = self.notificationsArrayList[indexPath.row]
        bindCellData(cell, eventListDict: eventListDict)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    //MARK:- Web Services Methods -
    
    func getNotificationsWebService(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    if APIName == WSRequest.GetNotificationListingWS() {
                        self.notificationsArrayList = responseData["details"] as! [[String:Any]]
                        if self.notificationsArrayList.count == 0 {
                            self.tableView.isHidden = true
                            self.noDataFoundLabel.isHidden = false
                        } else {
                            self.tableView.isHidden = false
                            self.noDataFoundLabel.isHidden = true
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    self.showAlertView(title: "Sorry!", message: message)
                    if APIName == WSRequest.GetNotificationListingWS() {
                        self.tableView.isHidden = true
                        self.noDataFoundLabel.isHidden = false
                    }
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
    
    @IBAction func backButtonAction(sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
