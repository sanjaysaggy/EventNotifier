//
//  ReverseGeocoding.swift
//  Paxi
//
//  Created by Sanjay on 07/03/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import Foundation
import CoreLocation

class ReverseGeocoding {
    
    static func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, _ completeAddress: String?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, nil, error)
                return
            }
            
            let completeAddress = getCompleteAddress(placemarks)
            
            completion(placemark, completeAddress, nil)
        }
    }
    
    static private func getCompleteAddress(_ placemarks: [CLPlacemark]?) -> String {
        guard let placemarks = placemarks else {
            return ""
        }
        
        let place = placemarks as [CLPlacemark]
        if place.count > 0 {
            let place = placemarks[0]
            var addressString : String = ""
            if place.thoroughfare != nil {
                addressString = addressString + place.thoroughfare! + ", "
            }
            if place.subThoroughfare != nil {
                addressString = addressString + place.subThoroughfare! + ", "
            }
            if place.locality != nil {
                addressString = addressString + place.locality! + ", "
            }
            if place.postalCode != nil {
                addressString = addressString + place.postalCode! + ", "
            }
            if place.subAdministrativeArea != nil {
                addressString = addressString + place.subAdministrativeArea! + ", "
            }
            if place.country != nil {
                addressString = addressString + place.country!
            }
            
            return addressString
        }
        return ""
    }
}
