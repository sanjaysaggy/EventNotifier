//
//  CustomView.swift
//  Tinge
//
 

import Foundation
import UIKit

class CustomView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 7)
        self.layer.shadowOpacity = Float(0.1)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
    }
    
}
