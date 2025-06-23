//
//  DrawRouteOnMap.swift
//  Paxi
//
//  Created bySanjay on 09/03/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import Foundation
import GoogleMaps

class DrawRouteOnMap {
    
    var mapView:GMSMapView!
    
    var polyline = GMSPolyline()
    var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timerPolyline: Timer!
    
    func drawPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (_ totalDurationInSeconds: Int,_ totalDistanceInMeters:Int) -> Void) {
        
        DispatchQueue.main.async {
            //            self.progressHUDObj?.show()
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=\(GoogleAPIKey)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                DispatchQueue.main.async {
                    //                    self.progressHUDObj?.hide()
                }
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        guard let routes = json["routes"] as? NSArray else {
                            DispatchQueue.main.async {
                                //                                self.progressHUDObj?.hide()
                            }
                            return
                        }
                        
                        if (routes.count > 0) {
                            let overview_polyline = routes[0] as? NSDictionary
                            let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                            let points = dictPolyline?.object(forKey: "points") as? String
                            
                            DispatchQueue.main.async {
                                //                                self.progressHUDObj?.hide()
                                self.timerPolyline = nil
                                self.path = GMSPath(fromEncodedPath: points!)!
                                self.polyline.path = self.path
                                self.polyline.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                                self.polyline.strokeWidth = 3.0
                                self.polyline.map = self.mapView
                                self.timerPolyline = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.animatePolylinePath), userInfo: nil, repeats: true)
                                
                                let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 170, left: 100, bottom: 100, right: 100))
                                self.mapView!.moveCamera(update)
                                
                                
                                
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
                                
//                                var totalDuration = ""
//
//                                if remainingHours == 0 {
//                                    totalDuration = "\(remainingMins) Minutes"
//                                } else {
//                                    totalDuration = "\(remainingHours) Hour, \(remainingMins) Minutes"
//                                }
                                
                                completion(Int(totalDurationInSeconds), Int(totalDistanceInMeters))
                                
                                print("totalDistance: \(totalDistance)")
                                
                                //                                DispatchQueue.main.async {
                                //                                    self.timeLabel.text = totalDuration
                                //
                                //                                    let tf = DateFormatter()
                                //                                    tf.dateFormat = "hh:mm a"
                                //                                    let resultdate = Date()
                                //
                                //                                    self.arrivalTimeLabel.text = tf.string(from: resultdate.adding(minutes: Int(mins)))
                                //
                                //                                }
                                
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                //                                self.progressHUDObj?.hide()
                            }
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                    DispatchQueue.main.async {
                        //                        self.progressHUDObj?.hide()
                    }
                }
            }
        })
        task.resume()
    }
    
    @objc func animatePolylinePath() {
        if (self.i < self.path.count()) {
            self.animationPath.add(self.path.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = UIColor.black
            self.animationPolyline.strokeWidth = 3
            self.animationPolyline.map = self.mapView
            self.i += 1
        }
        else {
            self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline.map = nil
        }
    }
    
}

extension GMSPolyline {
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        if self.path != nil {
            if GMSGeometryIsLocationOnPathTolerance(coordinate, self.path!, true, 1000) {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
}
