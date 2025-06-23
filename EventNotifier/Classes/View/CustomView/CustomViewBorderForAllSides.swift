//
//  CustomViewBorderForAllSides.swift
//  Tinge
//
//  Created by Sanjay on 19/07/18.
//  Copyright © 2018 Sanjay. All rights reserved.
//

import Foundation

import UIKit

class CustomViewBorderForAllSides: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.layer.shadowOpacity = Float(0.1)
//        self.layer.shadowRadius = 4
//        self.layer.masksToBounds = false
        
//        self.backgroundColor = UIColor.white
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.1
//        self.backgroundColor = .white
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
    }
    
}
