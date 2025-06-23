//
//  CustomTextField.swift
//  LGBTQ
//
//  Created by Sanjay on 07/02/19.
//  Copyright © 2019 Sanjay. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.delegate = self as? UITextFieldDelegate
        
        guard let holder = placeholder, !holder.isEmpty else { return }
        attributedPlaceholder = NSAttributedString(string: holder, attributes: [.foregroundColor: UIColor.darkGray])
        
        self.layer.cornerRadius = 0//self.frame.size.height/2
        self.layer.borderColor = UIColor.lightGray.cgColor//UIColor.init(hexCode: "#463332").cgColor
        self.layer.borderWidth = 0
        
        self.textColor = .black
        self.tintColor = .black
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
        
//        self.layer.shadowColor = UIColor.lightGray.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.layer.shadowOpacity = 0.2
//        self.backgroundColor = .white
//        self.layer.cornerRadius = 5
//        self.layer.masksToBounds = false
    }

}
