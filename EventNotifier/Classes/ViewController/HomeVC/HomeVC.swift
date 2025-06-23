//
//  HomeVC.swift
//  EventNotifier
//
//  Created by Sanjay on 16/03/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit
import SideMenu
import Spring
import SDWebImage

class HomeVC: BaseViewController,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    //MARK:- IBOutlets Declaration -
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var upcomingTableView: UITableView!
    @IBOutlet weak var pastTableView: UITableView!
    
    @IBOutlet weak var upcomingView: UIView!
    @IBOutlet weak var pastView: UIView!
    @IBOutlet weak var upcomingBotttomView: UIView!
    @IBOutlet weak var pastBotttomView: UIView!
    
    @IBOutlet weak var transferentView: UIView!
    @IBOutlet weak var filterView: SpringView!
    @IBOutlet weak var filterViewForPast: SpringView!
    
    @IBOutlet var upcomingButton: UIButton!
    @IBOutlet var pastButton: UIButton!
    
    @IBOutlet var noDataFoundUpcomingLabel: UILabel!
    @IBOutlet var noDataFoundPastLabel: UILabel!
    
    //Filter For Upcoming View
    @IBOutlet var allButton: UIButton!
    @IBOutlet var todayButton: UIButton!
    @IBOutlet var tomorrowButton: UIButton!
    @IBOutlet var weekendButton: UIButton!
    
    //Filter For Past View
    @IBOutlet var allButtonForPastFilter: UIButton!
    @IBOutlet var yesterdayButton: UIButton!
    @IBOutlet var lastweekendButton: UIButton!
    
    //Search For Upcoming View
    @IBOutlet var upcomingSearchTextField: UITextField!
    @IBOutlet var upcomingSearchView: UIView!
    
    //Search For Past View
    @IBOutlet var pastSearchTextField: UITextField!
    @IBOutlet var pastSearchView: UIView!
    
    var eventListDictUpcoming:[String:Any]?
    var eventListDictPast:[String:Any]?
    
    @IBOutlet var notificationCountLabel: UILabel!
    
    
    //    var currentIndex:Int = 0
    var currentIndexPath: IndexPath = [0, 0]
    var selectedIndexForUpcoming:Int = 0
    var selectedIndexForPast:Int = 0
//    var selectedIndexForTopTitle = 0
//    var arrayTopTitles = ["ONE FEED","COMMUNITY","PHOTOS","VIDEOS"]
    var upcomingArrayList = [[String:Any]]()
    var pastArrayList = [[String:Any]]()
    var index = 0
    
    var searchedArrayUpcoming = [[String:Any]]()
    var isSearchingUpcoming = false
    
    var searchedArrayPast = [[String:Any]]()
    var isSearchingPast = false
    
    //MARK:- View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        self.scrollView.scrollToPage(index: UInt8(selectedIndexForUpcoming), animated: false, after: 0)
        let indexPath = IndexPath(item: selectedIndexForUpcoming, section: 0)
        currentIndexPath = indexPath
        
        upcomingButton.setTitleColor(.black, for: .normal)
        
        self.getUpcomingWebService(parameters: ["":""], APIName: WSRequest.UpcommingEventWS())
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.getPastWebService(parameters: ["":""], APIName: WSRequest.PastEventWS())
        })
        
        upcomingSearchTextField.addTarget(self, action: #selector(self.textFieldDidChangeUpcoming(textField:)), for: UIControl.Event.editingChanged)
        pastSearchTextField.addTarget(self, action: #selector(self.textFieldDidChangePast(textField:)), for: UIControl.Event.editingChanged)
        
        upcomingSearchView.isHidden = true
        pastSearchView.isHidden = true
        
        
        upcomingBotttomView.isHidden = false
        pastBotttomView.isHidden = true
        
        allButton.setImage(UIImage(named: "selected_redio_black"), for: .normal)
        allButtonForPastFilter.setImage(UIImage(named: "selected_redio_black"), for: .normal)
        
        hideUpcomingFilterView()
        hidePastFilterView()
        
        //Adding view to scroll view
        upcomingView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        
        pastView.frame = CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        
        scrollView.addSubview(upcomingView)
        scrollView.addSubview(pastView)
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 2, height: scrollView.frame.size.height)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.getInfo(_:)), name: Notification.Name(rawValue: "HomeVC"), object: nil)
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
    
    @objc func getInfo(_ notification: Notification) {
        if let info = (notification as NSNotification).userInfo!["type"] as? String {
            
            self.getUpcomingWebService(parameters: ["":""], APIName: WSRequest.UpcommingEventWS())
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.getPastWebService(parameters: ["":""], APIName: WSRequest.PastEventWS())
            })
            
            upcomingButton.setTitleColor(.gray, for: .normal)
            pastButton.setTitleColor(.gray, for: .normal)
            
            if info == "Upcoming" {
                upcomingButton.setTitleColor(.black, for: .normal)
                upcomingBotttomView.isHidden = false
                pastBotttomView.isHidden = true
                self.scrollView.scrollToPage(index: UInt8(0), animated: true, after: 0)
            } else if info == "Past" {
                pastButton.setTitleColor(.black, for: .normal)
                pastBotttomView.isHidden = false
                upcomingBotttomView.isHidden = true
                self.scrollView.scrollToPage(index: UInt8(1), animated: true, after: 0)
            }
        }
    }
    
    @objc private func textFieldDidChangeUpcoming(textField: UITextField){
        
        let text = textField.text!
        
        if text == "" {
            isSearchingUpcoming = false
//            self.totalCount.text="Total : \(self.favouriteListArray.count)"
        } else {
            isSearchingUpcoming = true
            let array = self.upcomingArrayList
            let resultPredicate: NSPredicate = NSPredicate(format: "event_name contains[c] %@", text)
            searchedArrayUpcoming = (array.filter { resultPredicate.evaluate(with: ($0))})
            
            if searchedArrayUpcoming.count == 0 {
                noDataFoundUpcomingLabel.isHidden = false
            } else {
                noDataFoundUpcomingLabel.isHidden = true
            }
            
//            self.totalCount.text="Total : \(self.searchedArray.count)"
            //            print("searchedArray:",searchedArray)
        }
        
        self.upcomingTableView.reloadData()
    }
    
    @objc private func textFieldDidChangePast(textField: UITextField){
        
        let text = textField.text!
        
        if text == "" {
            isSearchingPast = false
            //            self.totalCount.text="Total : \(self.favouriteListArray.count)"
        } else {
            isSearchingPast = true
            let array = self.pastArrayList
            let resultPredicate: NSPredicate = NSPredicate(format: "event_name contains[c] %@", text)
            searchedArrayPast = (array.filter { resultPredicate.evaluate(with: ($0))})
            //            self.totalCount.text="Total : \(self.searchedArray.count)"
            //            print("searchedArray:",searchedArray)
            
            if searchedArrayPast.count == 0 {
                noDataFoundPastLabel.isHidden = false
            } else {
                noDataFoundPastLabel.isHidden = true
            }
        }
        
        self.pastTableView.reloadData()
    }
    
    
    func showUpcomingFilterView() {
        filterView.isHidden = false
        transferentView.isHidden = false
        
        filterView.animation = "fadeInUp"
        filterView.curve = "spring"
        filterView.duration = 0.7
        filterView.animate()
    }
    
    func hideUpcomingFilterView() {
        filterView.isHidden = true
        transferentView.isHidden = true
    }
    
    func showPastFilterView() {
        filterViewForPast.isHidden = false
        transferentView.isHidden = false
        
        filterViewForPast.animation = "fadeInUp"
        filterViewForPast.curve = "spring"
        filterViewForPast.duration = 0.7
        filterViewForPast.animate()
    }
    
    func hidePastFilterView() {
        filterViewForPast.isHidden = true
        transferentView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    
    // the controller that has a reference to the collection view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
    }
    
    
    
    
    //MARK:- ScrollView Delegates -
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let indexPath = IndexPath(item: scrollView.currentPage, section: 0)
            currentIndexPath = indexPath
            
            upcomingButton.setTitleColor(.gray, for: .normal)
            pastButton.setTitleColor(.gray, for: .normal)
            
            if currentIndexPath.row == 0 {
                upcomingButton.setTitleColor(.black, for: .normal)
                upcomingBotttomView.isHidden = false
                pastBotttomView.isHidden = true
            } else if currentIndexPath.row == 1 {
                pastButton.setTitleColor(.black, for: .normal)
                pastBotttomView.isHidden = false
                upcomingBotttomView.isHidden = true
            }
            
//            self.scrollView.scrollToPage(index: UInt8(currentIndexPath.row), animated: true, after: 0)
        }
    }
    
    // MARK: - Table View Delegates/Datasources -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == upcomingTableView {
            if isSearchingUpcoming == true {
                return searchedArrayUpcoming.count
            } else {
                return upcomingArrayList.count
            }
        } else {
            if isSearchingPast == true {
                return searchedArrayPast.count
            } else {
                return pastArrayList.count
            }
        }
    }
    
    fileprivate func bindCellData(_ cell: HomeTableViewCell,eventListDict:[String:Any]) {
        let date = self.getDateInCustmizeFormat("yyyy-MM-dd", dateString: eventListDict["event_date"] as! String, dateFormatterOutputString: "dd MMM yyyy")
        //            let time = self.getDateInCustmizeFormat("hh:mm:ss", dateString: eventListDict["event_starttime"] as! String, dateFormatterOutputString: "hh:mm a")
        
        cell.titleLabel.text = eventListDict["event_name"] as? String
        cell.amountLabel.text = "$\(eventListDict["price"] as! String)"
        cell.addressLabel.text = eventListDict["event_place"] as? String
        cell.datetimeLabel.text = date + " " + "\(eventListDict["event_starttime"] as! String)"
        
        if let urlString = eventListDict["image"] as? String {
            if let imageURL:URL = URL(string: urlString) {
                //                    SDImageCache.shared().clearMemory()
                //                    SDImageCache.shared().clearDisk()
                cell.backgroundImageView.sd_setShowActivityIndicatorView(true)
                cell.backgroundImageView.sd_setIndicatorStyle(.gray)
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
        if tableView == upcomingTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
            cell.selectionStyle = .none
            
            if isSearchingUpcoming == true {
                self.eventListDictUpcoming = self.searchedArrayUpcoming[indexPath.row]
            } else {
                self.eventListDictUpcoming = self.upcomingArrayList[indexPath.row]
            }
            
            bindCellData(cell, eventListDict: self.eventListDictUpcoming!)
            
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
            cell.selectionStyle = .none
            
            if isSearchingUpcoming == true {
                self.eventListDictPast = self.searchedArrayPast[indexPath.row]
            } else {
                self.eventListDictPast = self.pastArrayList[indexPath.row]
            }
            
            bindCellData(cell, eventListDict: self.eventListDictPast!)
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if tableView == upcomingTableView {
            if isSearchingUpcoming == true {
                self.eventListDictUpcoming = self.searchedArrayUpcoming[indexPath.row]
            } else {
                self.eventListDictUpcoming = self.upcomingArrayList[indexPath.row]
            }
            let VC:EventDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsVC") as! EventDetailsVC
            VC.eventListDict = self.eventListDictUpcoming!
            VC.forPurpose = "Upcoming"
            self.navigationController?.pushViewController(VC, animated: true)
        } else {
            if isSearchingUpcoming == true {
                self.eventListDictPast = self.searchedArrayPast[indexPath.row]
            } else {
                self.eventListDictPast = self.pastArrayList[indexPath.row]
            }
            let VC:EventDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsVC") as! EventDetailsVC
            VC.eventListDict = self.eventListDictPast!
            self.navigationController?.pushViewController(VC, animated: true)
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    
    
    
    //MARK:- Web Services Methods -
    
    func getUpcomingWebService(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .get, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.dismissProgress()
                    self.upcomingArrayList = responseData["response"] as! [[String:Any]]
                    if self.upcomingArrayList.count == 0 {
                        self.upcomingTableView.isHidden = true
                        self.noDataFoundUpcomingLabel.isHidden = false
                    } else {
                        self.upcomingTableView.isHidden = false
                        self.noDataFoundUpcomingLabel.isHidden = true
                    }
                    DispatchQueue.main.async {
                        self.upcomingTableView.reloadData()
                    }
                } else {
                    self.dismissProgress()
                    self.showAlertView(title: "Sorry!", message: message)
                    self.upcomingTableView.isHidden = true
                    self.noDataFoundUpcomingLabel.isHidden = false
                }
            })
            
        } else {
            self.dismissProgress()
            self.showAlertView(title: NetworkIssueTitle, message: NoInternetConnectionMessage)
        }
    }
    
    func getPastWebService(parameters:[String:Any],APIName:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .get, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.dismissProgress()
                    self.pastArrayList = responseData["response"] as! [[String:Any]]
                    if self.pastArrayList.count == 0 {
                        self.pastTableView.isHidden = true
                        self.noDataFoundPastLabel.isHidden = false
                    } else {
                        self.pastTableView.isHidden = false
                        self.noDataFoundPastLabel.isHidden = true
                    }
                    DispatchQueue.main.async {
                        self.pastTableView.reloadData()
                    }
                } else {
                    self.dismissProgress()
                    self.showAlertView(title: "Sorry!", message: message)
                    self.pastTableView.isHidden = true
                    self.noDataFoundPastLabel.isHidden = false
                }
            })
            
        } else {
            self.dismissProgress()
            self.showAlertView(title: NetworkIssueTitle, message: NoInternetConnectionMessage)
        }
    }
    
    func getEventByDateWebService(parameters:[String:Any],APIName:String,forPurpose:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.dismissProgress()
                    if forPurpose == UPCOMING_EVENT {
                        self.upcomingArrayList = responseData["response"] as! [[String:Any]]
                        if self.upcomingArrayList.count == 0 {
                            self.upcomingTableView.isHidden = true
                            self.noDataFoundUpcomingLabel.isHidden = false
                        } else {
                            self.noDataFoundUpcomingLabel.isHidden = true
                        }
                        DispatchQueue.main.async {
                            self.upcomingTableView.reloadData()
                        }
                    } else if forPurpose == PAST_EVENT {
                        self.pastArrayList = responseData["response"] as! [[String:Any]]
                        if self.pastArrayList.count == 0 {
                            self.pastTableView.isHidden = true
                            self.noDataFoundPastLabel.isHidden = false
                        } else {
                            self.noDataFoundPastLabel.isHidden = true
                        }
                        DispatchQueue.main.async {
                            self.pastTableView.reloadData()
                        }
                    }
                    
                } else {
                    self.dismissProgress()
                    self.showAlertView(title: "Sorry!", message: message)
                    if forPurpose == UPCOMING_EVENT {
                        self.noDataFoundUpcomingLabel.isHidden = false
                        self.upcomingTableView.isHidden = true
                    } else if forPurpose == PAST_EVENT {
                        self.noDataFoundPastLabel.isHidden = false
                        self.pastTableView.isHidden = true
                    }
                }
            })
            
        } else {
            self.dismissProgress()
            self.showAlertView(title: NetworkIssueTitle, message: NoInternetConnectionMessage)
        }
    }
    
    func filterEventWebService(parameters:[String:Any],APIName:String,forPurpose:String) {
        self.showProgress()
        if( ReachabilitySwift.isConnectedToNetwork()) {
            WebServiceManager.sharedInstance.WebServiceRequest(parametersDict: parameters,APIName: APIName, Method: .post, completionHandler: { (status, message, responseData) in
                if status == true {
                    self.dismissProgress()
                    if forPurpose == UPCOMING_EVENT {
                        self.upcomingArrayList = responseData["response"] as! [[String:Any]]
                        if self.upcomingArrayList.count == 0 {
                            self.upcomingTableView.isHidden = true
                            self.noDataFoundUpcomingLabel.isHidden = false
                        } else {
                            self.upcomingTableView.isHidden = false
                            self.noDataFoundUpcomingLabel.isHidden = true
                        }
                        DispatchQueue.main.async {
                            self.upcomingTableView.reloadData()
                        }
                    } else if forPurpose == PAST_EVENT {
                        self.pastArrayList = responseData["response"] as! [[String:Any]]
                        if self.pastArrayList.count == 0 {
                            self.pastTableView.isHidden = true
                            self.noDataFoundPastLabel.isHidden = false
                        } else {
                            self.pastTableView.isHidden = false
                            self.noDataFoundPastLabel.isHidden = true
                        }
                        DispatchQueue.main.async {
                            self.pastTableView.reloadData()
                        }
                    }
                    
                } else {
                    self.dismissProgress()
                    self.showAlertView(title: "Sorry!", message: message)
                    if forPurpose == UPCOMING_EVENT {
                        self.noDataFoundUpcomingLabel.isHidden = false
                        self.upcomingTableView.isHidden = true
                    } else if forPurpose == PAST_EVENT {
                        self.noDataFoundPastLabel.isHidden = false
                        self.pastTableView.isHidden = true
                    }
                }
            })
            
        } else {
            self.dismissProgress()
            self.showAlertView(title: NetworkIssueTitle, message: NoInternetConnectionMessage)
        }
    }
    
    
    //MARK:- Button Actions -
    
    @IBAction func mainTitleMenuClickButtonAction(_ sender: UIButton) {
        
        upcomingButton.setTitleColor(.gray, for: .normal)
        pastButton.setTitleColor(.gray, for: .normal)
        
        if sender.tag == 0 {
            upcomingButton.setTitleColor(.black, for: .normal)
            upcomingBotttomView.isHidden = false
            pastBotttomView.isHidden = true
            self.scrollView.scrollToPage(index: UInt8(0), animated: true, after: 0)
        } else if sender.tag == 1 {
            pastButton.setTitleColor(.black, for: .normal)
            pastBotttomView.isHidden = false
            upcomingBotttomView.isHidden = true
            self.scrollView.scrollToPage(index: UInt8(1), animated: true, after: 0)
        }
        
    }
    
    @IBAction func filterButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            self.showUpcomingFilterView()
        } else if sender.tag == 1 {
            self.showPastFilterView()
        }
    }
    
    @IBAction func cancelFilterButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            self.hideUpcomingFilterView()
        } else if sender.tag == 1 {
            self.hidePastFilterView()
        }
    }
    
    @IBAction func notificationButtonAction(_ sender: UIButton) {
        let VC:NotificationVC! = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    

    @IBAction func applyFilterButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {//upcomming View
            if selectedIndexForUpcoming == 0 {
                self.getUpcomingWebService(parameters: ["":""], APIName: WSRequest.UpcommingEventWS())
            } else if selectedIndexForUpcoming == 1 {
                self.filterEventWebService(parameters: [:], APIName: WSRequest.TodaysEventWS(), forPurpose: UPCOMING_EVENT)
            } else if selectedIndexForUpcoming == 2 {
                self.filterEventWebService(parameters: [:], APIName: WSRequest.TomarrowsEventWS(), forPurpose: UPCOMING_EVENT)
            } else if selectedIndexForUpcoming == 3 {
                self.filterEventWebService(parameters: [:], APIName: WSRequest.WeekendsEventWS(), forPurpose: UPCOMING_EVENT)
            }
            self.hideUpcomingFilterView()
        } else if sender.tag == 1 {//past View
            if selectedIndexForPast == 0 {
                self.getPastWebService(parameters: ["":""], APIName: WSRequest.PastEventWS())
            } else if selectedIndexForPast == 1 {
                self.filterEventWebService(parameters: [:], APIName: WSRequest.YesterdaysEventWS(), forPurpose: PAST_EVENT)
            } else if selectedIndexForPast == 2 {
                self.filterEventWebService(parameters: [:], APIName: WSRequest.LastweekendEventWS(), forPurpose: PAST_EVENT)
            }
            self.hidePastFilterView()
        }
        
    }
    
    @IBAction func datePickerButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {//upcomming View
            datePickerTapped(forPurpose: UPCOMING_EVENT)
        } else if sender.tag == 1 {//past View
            datePickerTapped(forPurpose: PAST_EVENT)
        }
    }
    
    @IBAction func searchButtonAction(_ sender: UIButton) {
        if sender.tag == 0 { //upcomming View
            upcomingSearchView.isHidden = false
            upcomingSearchTextField.becomeFirstResponder()
        } else if sender.tag == 1 { //past View
            pastSearchView.isHidden = false
            pastSearchTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func clsoeSearchButtonAction(_ sender: UIButton) {
        if sender.tag == 0 { //upcomming View
            upcomingSearchTextField.text = ""
            upcomingSearchView.isHidden = true
            upcomingSearchTextField.resignFirstResponder()
            isSearchingUpcoming = false
            if self.upcomingArrayList.count == 0 {
                self.upcomingTableView.isHidden = true
                self.noDataFoundUpcomingLabel.isHidden = false
            } else {
                self.upcomingTableView.isHidden = false
                self.noDataFoundUpcomingLabel.isHidden = true
            }
            upcomingTableView.reloadData()
        } else if sender.tag == 1 { //past View
            pastSearchTextField.text = ""
            pastSearchView.isHidden = true
            pastSearchTextField.resignFirstResponder()
            isSearchingPast = false
            if self.pastArrayList.count == 0 {
                self.pastTableView.isHidden = true
                self.noDataFoundPastLabel.isHidden = false
            } else {
                self.pastTableView.isHidden = false
                self.noDataFoundPastLabel.isHidden = true
            }
            pastTableView.reloadData()
        }
    }
    
    
    @IBAction func selectUnselectRedioButtonAction(_ sender: UIButton) {
        
        allButton.setImage(UIImage(named: "unselected_redio_black"), for: .normal)
        todayButton.setImage(UIImage(named: "unselected_redio_black"), for: .normal)
        tomorrowButton.setImage(UIImage(named: "unselected_redio_black"), for: .normal)
        weekendButton.setImage(UIImage(named: "unselected_redio_black"), for: .normal)
        
        selectedIndexForUpcoming = sender.tag
        
        if sender.tag == 0 {
            allButton.setImage(UIImage(named: "selected_redio_black"), for: .normal)
        } else if sender.tag == 1 {
            todayButton.setImage(UIImage(named: "selected_redio_black"), for: .normal)
        } else if sender.tag == 2 {
            tomorrowButton.setImage(UIImage(named: "selected_redio_black"), for: .normal)
        } else if sender.tag == 3 {
            weekendButton.setImage(UIImage(named: "selected_redio_black"), for: .normal)
        }
        
//        self.hideImageSliderView()
    }
    
    @IBAction func selectUnselectRedioButtonActionFroPastFilterView(_ sender: UIButton) {
        
        allButtonForPastFilter.setImage(UIImage(named: "unselected_redio_black"), for: .normal)
        yesterdayButton.setImage(UIImage(named: "unselected_redio_black"), for: .normal)
        lastweekendButton.setImage(UIImage(named: "unselected_redio_black"), for: .normal)
        
        selectedIndexForPast = sender.tag
        
        if sender.tag == 0 {
            allButtonForPastFilter.setImage(UIImage(named: "selected_redio_black"), for: .normal)
        } else if sender.tag == 1 {
            yesterdayButton.setImage(UIImage(named: "selected_redio_black"), for: .normal)
        } else if sender.tag == 2 {
            lastweekendButton.setImage(UIImage(named: "selected_redio_black"), for: .normal)
        }
    }
    
    @IBAction func SideMenuAction(sender: AnyObject) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    
    func datePickerTapped(forPurpose:String) {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.year = 100
        let yearsLater = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        
        let datePicker = DatePickerDialog(textColor: .black,
                                          buttonColor: .black,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        
        if forPurpose == UPCOMING_EVENT {
            datePicker.show("Select Date",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            minimumDate: currentDate,
                            maximumDate: yearsLater,
                            datePickerMode: .date) { (date) in
                                if let dt = date {
                                    let dateformatter = DateFormatter()
                                    //                    let timeformatter = DateFormatter()
                                    dateformatter.dateFormat = "yyyy-MM-dd"//"MM/dd/yyyy"
                                    //                    timeformatter.dateFormat = "hh:mm a"//"MM/dd/yyyy"
                                    let dateSelected = "\(dateformatter.string(from: dt))"
                                    self.getEventByDateWebService(parameters: ["selected_date":dateSelected], APIName: WSRequest.SelectedDateEventWS(), forPurpose: forPurpose)
                                }
            }
        } else if forPurpose == PAST_EVENT {
            datePicker.show("Select Date",
                            doneButtonTitle: "Done",
                            cancelButtonTitle: "Cancel",
                            maximumDate: currentDate,
                            datePickerMode: .date) { (date) in
                                if let dt = date {
                                    let dateformatter = DateFormatter()
                                    //                    let timeformatter = DateFormatter()
                                    dateformatter.dateFormat = "yyyy-MM-dd"//"MM/dd/yyyy"
                                    //                    timeformatter.dateFormat = "hh:mm a"//"MM/dd/yyyy"
                                    let dateSelected = "\(dateformatter.string(from: dt))"
                                    self.getEventByDateWebService(parameters: ["selected_date":dateSelected], APIName: WSRequest.SelectedDateEventWS(), forPurpose: forPurpose)
                                }
            }
        }
        
        
    }
    
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == upcomingSearchTextField {
            upcomingSearchView.isHidden = true
        } else if textField == pastSearchTextField {
            pastSearchView.isHidden = true
        }
        resignFirstResponder()
        self.view.endEditing(true)
        return false
    }
    
    
    
    
}
