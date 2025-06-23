//
//  DrawPolyline.swift
//  KidsOnTheGo
//
//  Created by Sanjayon 27/09/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import Foundation
import GoogleMaps

private struct MapPath : Decodable{
    var routes : [Route]?
}

private struct Route : Decodable{
    var overview_polyline : OverView?
}

private struct OverView : Decodable {
    var points : String?
}

extension GMSMapView {
    
    //MARK:- Call API for polygon points
    
    func drawPolygon(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, durationText:UILabel) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(GoogleAPIKey)") else {
            return
        }
        
        DispatchQueue.main.async {
            
            session.dataTask(with: url) { (data, response, error) in
                
                guard data != nil else {
                    return
                }
                do {
                    
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        guard let routes = json["routes"] as? NSArray else {
                            return
                        }
                        
                        print("routes:",routes)
                        if (routes.count > 0) {
                            
                            
                            //To get the time
                            let legs:[String:Any] = (routes[0] as? [String:Any])!
                            let arrayLegs:[[String:Any]] = (legs["legs"] as? [[String:Any]])!
                            
                            var totalDistanceInMeters:UInt = 0
                            var totalDurationInSeconds:UInt = 0
                            
                            for leg in arrayLegs {
                                totalDistanceInMeters +=  (leg["distance"] as! [String:Any])["value"] as! UInt
                                totalDurationInSeconds += (leg["duration"] as! [String:Any])["value"] as! UInt
                            }
                            
                            
                            let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
                            let totalDistance = "Distance: \(distanceInKilometers) Km"
                            
                            
                            let mins = totalDurationInSeconds / 60
                            let hours = mins / 60
                            let days = hours / 24
                            let remainingHours = hours % 24
                            let remainingMins = mins % 60
                            let remainingSecs = totalDurationInSeconds % 60
                            
                            var totalDuration = ""
                            
                            if remainingHours == 0 {
                               totalDuration = "This trip will take: \(remainingMins) M, \(remainingSecs) s"
                            } else {
                                totalDuration = "This trip will take: \(remainingHours) h, \(remainingMins) M, \(remainingSecs) s"
                            }
                            
                            
                            
                            print("totalDistance: \(totalDistance), \(totalDuration)")
                            
                            DispatchQueue.main.async {
                                durationText.text = totalDuration
                            }
                            
                            
//                            self.calculateTotalDistanceAndDuration(selectedRoute: arrayLegs! as Array<Dictionary<NSObject, AnyObject>>)
                            
//                            let overview_polyline = routes[0] as? NSDictionary
//                            let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
//                            let points = dictPolyline?.object(forKey: "points") as? String
//
//                            DispatchQueue.main.async {
//                                self.timerPolyline = nil
//                                self.path = GMSPath(fromEncodedPath: points!)!
//                                self.polyline.path = self.path
//                                self.polyline.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
//                                self.polyline.strokeWidth = 3.0
//                                self.polyline.map = self.mapView
//
//
//                                let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
//                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(170, 100, 100, 100))
//                                self.mapView!.moveCamera(update)
//                            }
                        }
                        
                    }
                    
                    //Drawing Route Polyline
                    let route = try JSONDecoder().decode(MapPath.self, from: data!)
                    print("route:\n",route)
                    if let points = route.routes?.first?.overview_polyline?.points {
                        self.drawPath(with: points)
                    }
                    
                } catch let error {
                    
                    print("Failed to draw ",error.localizedDescription)
                }
                }.resume()
        }
        
    }
    
    //MARK:- Draw polygon
    
    private func drawPath(with points : String){
        
        DispatchQueue.main.async {
            
            let path = GMSPath(fromEncodedPath: points)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            polyline.strokeColor = UIColor.black.withAlphaComponent(0.7)
            polyline.map = self
            
        }
    }
    
    
    func drawRoutes(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let origin = "\(source.latitude),\(source.longitude)"
        let destination = "\(destination.latitude),\(destination.longitude)"

//        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?origin=\(origin)&destination=\(destination)"//&mode=driving&key=\(GoogleAPIKey)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(GoogleAPIKey)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
                    print("routes:",routes)
//                    self.mapView.clear()
                    
                    OperationQueue.main.addOperation({
                        for route in routes
                        {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 5.0
                            polyline.strokeColor = UIColor.blue.withAlphaComponent(0.7)
                            
//                            let bounds = GMSCoordinateBounds(path: path!)
//                            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            
                            polyline.map = self//.mapView
                            
                        }
                    })
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }

    /*
     let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = "baseURLDirections" + "origin=" + originLocation + "&destination=" + destinationLocation
                
                directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                let directionsURL = NSURL(string: directionsURLString)
                DispatchQueue.main.async {
                    let directionsData = NSData(contentsOfURL: directionsURL! as URL)
                    
                    var error: NSError?
                    let dictionary: Dictionary<NSObject, AnyObject> = JSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<NSObject, AnyObject>
                    
                    if (error != nil) {
                        completionHandler("", false)
                    }
                    else {
                        let status = dictionary["status"] as String
                        
                        if status == "OK" {
                            let selectedRoute = (dictionary["routes"] as Array<Dictionary<NSObject, AnyObject>>)[0]
                            
                            self.calculateTotalDistanceAndDuration(routeDict:[String:Any])
                            
                            completionHandler(status: status, success: true)
                        }
                        else {
                            completionHandler(status: status, success: false)
                        }
                    }
                }
            }
            else {
                completionHandler(status: "Destination is nil.", success: false)
            }
        }
        else {
            completionHandler(status: "Origin is nil", success: false)
        }
    }
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as Array<Dictionary<NSObject, AnyObject>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as Dictionary<NSObject, AnyObject>)["value"] as UInt
            totalDurationInSeconds += (leg["duration"] as Dictionary<NSObject, AnyObject>)["value"] as UInt
        }
        
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }
 */
 
}
