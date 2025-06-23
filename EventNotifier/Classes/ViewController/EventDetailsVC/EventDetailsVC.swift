//
//  EventDetailsVC.swift
//  EventNotifier
//
//  Created by Sanjay on 12/04/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit
import GoogleMaps
import Spring

protocol UpdateEventListing:class {
    func updateEvents()
}

class EventDetailsVC: BaseViewController {

    //MARK:- IBOutlets Declaration -
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var availableSeatsLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var bookButton: UIButton!
    
    //Book View
    @IBOutlet weak var transferentView: UIView!
    @IBOutlet weak var bookView: SpringView!
    @IBOutlet weak var ticketsNoLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var dateForBookLabel: UILabel!
    @IBOutlet weak var timeForBookLabel: UILabel!
    
    //Ticket Details View
    @IBOutlet weak var ticketDetailsView: SpringView!
    @IBOutlet weak var ticketsNoLabelForDetailsView: UILabel!
    @IBOutlet weak var totalAmountLabelForDetailsView: UILabel!
    @IBOutlet weak var dateLabelForDetailsView: UILabel!
    @IBOutlet weak var timeLabelForDetailsView: UILabel!
    
    
    var eventListDict = [String:Any]()
    var ticketNo = 1
    var amount = Double()
    var forPurpose = ""
    var availableSeats = 0
    var delegate:UpdateEventListing!
    
    
    //MARK:- View Life Cycle -
    
    fileprivate func assignInformation() {
        let dateStart = self.getDateInCustmizeFormat("yyyy-MM-dd", dateString: eventListDict["event_date"] as! String, dateFormatterOutputString: "dd MMM yyyy")
        let dateEnd = self.getDateInCustmizeFormat("yyyy-MM-dd", dateString: eventListDict["event_endDate"] as! String, dateFormatterOutputString: "dd MMM yyyy")
        //            let time = self.getDateInCustmizeFormat("hh:mm:ss", dateString: eventListDict["event_starttime"] as! String, dateFormatterOutputString: "hh:mm a")
        
        print("eventListDict:",eventListDict)
        
        amount = Double(eventListDict["price"] as! String)!
        titleLabel.text = eventListDict["event_name"] as? String
        amountLabel.text = "$\(eventListDict["price"] as! String)"
        startDateLabel.text = dateStart
        startTimeLabel.text = eventListDict["event_starttime"] as? String
        endDateLabel.text = dateEnd
        endTimeLabel.text = eventListDict["event_endtime"] as? String
        descriptionLabel.text = eventListDict["event_descr"] as? String
        venueLabel.text = eventListDict["event_place"] as? String
        availableSeatsLabel.text = "AVAILABLE SEATS : \(eventListDict["available_seats"] as! String)"
        availableSeats = Int(eventListDict["available_seats"] as! String)!
//        .text = date + " " + "\(eventListDict["event_starttime"] as! String)"
        
        if let urlString = eventListDict["image"] as? String {
            if let imageURL:URL = URL(string: urlString) {
                //                    SDImageCache.shared().clearMemory()
                //                    SDImageCache.shared().clearDisk()
                eventImageView.sd_setShowActivityIndicatorView(true)
                eventImageView.sd_setIndicatorStyle(.whiteLarge)
                eventImageView.sd_setImage(with: imageURL, completed: { (image, error, cache, urls) in
                    if (error != nil) {
                        self.eventImageView.image = UIImage(named: "default-thumb")
                    } else {
                        self.eventImageView.image = image
                    }
                })
                
            } else {
                eventImageView.image = UIImage(named:"default-thumb")
            }
        }
        
        self.dropPinLocations(source_latitude: Double(eventListDict["latitude"] as! String)!, source_longitude: Double(eventListDict["longitude"] as! String)!, mapViewObj: self.mapView)
        
        
        dateForBookLabel.text = dateStart
        timeForBookLabel.text = eventListDict["event_starttime"] as? String
        self.totalAmountLabel.text = "Total Amount     $ \(self.amount*Double(self.ticketNo))"
        self.totalAmountLabelForDetailsView.text = "$ \(self.amount*Double(self.ticketNo))"
        self.ticketsNoLabelForDetailsView.text = "\(ticketNo)"
        
        dateLabelForDetailsView.text = dateStart
        timeLabelForDetailsView.text = eventListDict["event_starttime"] as? String
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if forPurpose == "Upcoming" {
            bookButton.isHidden = false
        } else {
            bookButton.isHidden = true
        }
        
        hideBookView()
        hideTicketDetailsView()
        assignInformation()
        
    }
    
    //MARK:- Button Actions -
    
    @IBAction func bookButtonAction(_ sender: UIButton) {
        if availableSeats > 0 {
            self.showBookView()
        } else {
            self.showToastBlackBackgraound(toastMessage: "Sorry! No Seats Available.", duration: 2, position: .center)
        }
    }
    
    @IBAction func closeBookButtonAction(_ sender: UIButton) {
        self.hideBookView()
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
//        showToastBlackBackgraound(toastMessage: UnderDevelopment, duration: 1, position: .center)
        shareOnShocialMedia()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addRemoveButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            if ticketNo > 1 {
                ticketNo -= 1
            }
        } else {
            if availableSeats > ticketNo {
                ticketNo += 1
            } else {
                self.showToastBlackBackgraound(toastMessage: "Sorry! Available seats are less than that you required.", duration: 2, position: .center)
            }
        }
        
        self.ticketsNoLabel.text = "\(ticketNo)"
        self.totalAmountLabel.text = "Total Amount     $ \(self.amount*Double(self.ticketNo))"
        
        self.ticketsNoLabelForDetailsView.text = "\(ticketNo)"
        self.totalAmountLabelForDetailsView.text = "\(self.amount*Double(self.ticketNo))"
    }
    
    @IBAction func payButtonAction(_ sender: UIButton) {
        self.showTicketDetailsView()
    }
    
    @IBAction func payButtonForTicketDetailsViewAction(_ sender: UIButton) {
        let VC:PaymentVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        self.eventListDict.updateValue("\(ticketNo)", forKey: "no_of_tickets")
        self.eventListDict.updateValue(self.totalAmountLabelForDetailsView.text!, forKey: "total_price")
        VC.eventListDict = eventListDict
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func backButtonForTicketDetailsViewAction(_ sender: UIButton) {
        self.hideTicketDetailsView()
    }
    
    //MARK:- General Functions -
    
    func showBookView() {
        bookView.isHidden = false
        transferentView.isHidden = false
        
        bookView.animation = "fadeInUp"
        bookView.curve = "spring"
        bookView.duration = 0.7
        bookView.animate()
    }
    
    func hideBookView() {
        bookView.isHidden = true
        transferentView.isHidden = true
    }
    
    func showTicketDetailsView() {
        ticketDetailsView.isHidden = false
        
        ticketDetailsView.animation = "fadeInUp"
        ticketDetailsView.curve = "spring"
        ticketDetailsView.duration = 0.7
        ticketDetailsView.animate()
    }
    
    func hideTicketDetailsView() {
        ticketDetailsView.isHidden = true
    }
    
    func dropPinLocations(source_latitude:Double,source_longitude:Double,mapViewObj:GMSMapView) {
        
        let marker = GMSMarker()
//        let markerEndPoint = GMSMarker()
        
//        let path = GMSMutablePath()
        
        mapViewObj.clear()
        
        let theImageView = UIImageView(image:UIImage(named:"place-marker"))
        //        theImageView.image = theImageView.image!.withRenderingMode(.alwaysTemplate)
        //        theImageView.tintColor = UIColor.blue.withAlphaComponent(0.55)
        
        //creating a marker view
        marker.iconView = theImageView
        marker.map = mapViewObj
        
        //        CATransaction.begin()
        //        CATransaction.setAnimationDuration(5.0)
        
        let position = CLLocationCoordinate2D(latitude: source_latitude, longitude: source_longitude)
        mapViewObj.camera = GMSCameraPosition.camera(withTarget: position, zoom: 14)
        marker.position = position
        marker.title = eventListDict["event_place"] as? String
        //        mapView.selectedMarker = self.marker
//        path.add(marker.position)
        
        //        CATransaction.commit()
        
        //Positioning End Marker Icon on Map
        
//        let theImageViewEnd = UIImageView(image:UIImage(named:"location_red"))
        //            theImageViewEnd.image = theImageViewEnd.image!.withRenderingMode(.alwaysTemplate)
        //            theImageViewEnd.tintColor = UIColor.red.withAlphaComponent(0.55)
        
        //creating a marker view
//        markerEndPoint.iconView = theImageViewEnd
//        markerEndPoint.map = mapViewObj
//        let positionEndPoint = CLLocationCoordinate2D(latitude: dest_latitude, longitude: dest_longitude)
//        //            self.mapView.camera=GMSCameraPosition.camera(withTarget: position, zoom: 18)
//        markerEndPoint.position = positionEndPoint
//        //        self.markerEndPoint.title = dictInfo["destAdd"]
//        //        self.markerEndPoint.snippet = ""
//        path.add(markerEndPoint.position)
        
        //        mapView.selectedMarker = self.markerEndPoint
        
//        let bounds = GMSCoordinateBounds(path: path)
//        mapViewObj.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 40.0))
    }
    
    
    func shareOnShocialMedia() {
        
//        amount = Double(eventListDict["price"] as! String)!
//        titleLabel.text = eventListDict["event_name"] as? String
//        amountLabel.text = "$\(eventListDict["price"] as! String)"
//        startDateLabel.text = dateStart
//        startTimeLabel.text = eventListDict["event_starttime"] as? String
//        endDateLabel.text = dateEnd
//        endTimeLabel.text = eventListDict["event_endtime"] as? String
//        descriptionLabel.text = eventListDict["event_descr"] as? String
//        venueLabel.text = eventListDict["event_place"] as? String
        
//        if let image = UIImage(named: "myImage") {
//            let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
//            present(vc, animated: true)
//        }
        
        let shareText = "Event Name: \(titleLabel.text!)\nStart Date & Time: \(startDateLabel.text!),\(startTimeLabel.text!)\nEnd Date & Time: \(endDateLabel.text!), \(endTimeLabel.text!)\n Amount: \(amountLabel.text!)\nVenue: \(venueLabel.text!)"
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        present(vc, animated: true)
    }
    
}
