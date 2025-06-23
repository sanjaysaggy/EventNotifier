//
//  Extensions.swift
//  Seeheeheye
//
//  Created by Sanjay on 30/01/18.
//  Copyright © 2018 Sanjay  . All rights reserved.
//

import Foundation
import UIKit
//import DropDown

Sanjay

//Code for custom font
/*
 Usage:
 titleLabel.text = "Welcome"
 titleLabel.font = UIFont.systemFont(ofSize: 70, weight: .bold)
 titleLabel.textColor = UIColor.black
 titleLabel.changeFont(ofText: "lc", with: UIFont.systemFont(ofSize: 60, weight: .light))
 titleLabel.changeTextColor(ofText: "el", with: UIColor.blue)
 titleLabel.changeTextColor(ofText: "co", with: UIColor.red)
 titleLabel.changeTextColor(ofText: "m", with: UIColor.green)
 */
public protocol ChangableFont: AnyObject {
    var text: String? { get set }
    var attributedText: NSAttributedString? { get set }
    var rangedAttributes: [RangedAttributes] { get }
    func getFont() -> UIFont?
    func changeFont(ofText text: String, with font: UIFont)
    func changeFont(inRange range: NSRange, with font: UIFont)
    func changeTextColor(ofText text: String, with color: UIColor)
    func changeTextColor(inRange range: NSRange, with color: UIColor)
}

public struct RangedAttributes {
    
    let attributes: [NSAttributedString.Key: Any]
    let range: NSRange
    
    public init(_ attributes: [NSAttributedString.Key: Any], inRange range: NSRange) {
        self.attributes = attributes
        self.range = range
    }
}

extension UILabel: ChangableFont {
    
    public func getFont() -> UIFont? {
        return font
    }
}

extension UITextField: ChangableFont {
    
    public func getFont() -> UIFont? {
        return font
    }
}

public extension ChangableFont {
    
    public var rangedAttributes: [RangedAttributes] {
        guard let attributedText = attributedText else {
            return []
        }
        var rangedAttributes: [RangedAttributes] = []
        let fullRange = NSRange(
            location: 0,
            length: attributedText.string.count
        )
        attributedText.enumerateAttributes(
            in: fullRange,
            options: []
        ) { (attributes, range, stop) in
            guard range != fullRange, !attributes.isEmpty else { return }
            rangedAttributes.append(RangedAttributes(attributes, inRange: range))
        }
        return rangedAttributes
    }
    
    public func changeFont(ofText text: String, with font: UIFont) {
        guard let range = (self.attributedText?.string ?? self.text)?.range(ofText: text) else { return }
        changeFont(inRange: range, with: font)
    }
    
    public func changeFont(inRange range: NSRange, with font: UIFont) {
        add(attributes: [.font: font], inRange: range)
    }
    
    public func changeTextColor(ofText text: String, with color: UIColor) {
        guard let range = (self.attributedText?.string ?? self.text)?.range(ofText: text) else { return }
        changeTextColor(inRange: range, with: color)
    }
    
    public func changeTextColor(inRange range: NSRange, with color: UIColor) {
        add(attributes: [.foregroundColor: color], inRange: range)
    }
    
    private func add(attributes: [NSAttributedString.Key: Any], inRange range: NSRange) {
        guard !attributes.isEmpty else { return }
        
        var rangedAttributes: [RangedAttributes] = self.rangedAttributes
        
        var attributedString: NSMutableAttributedString
        
        if let attributedText = attributedText {
            attributedString = NSMutableAttributedString(attributedString: attributedText)
        } else if let text = text {
            attributedString = NSMutableAttributedString(string: text)
        } else {
            return
        }
        
        rangedAttributes.append(RangedAttributes(attributes, inRange: range))
        
        rangedAttributes.forEach { (rangedAttributes) in
            attributedString.addAttributes(
                rangedAttributes.attributes,
                range: rangedAttributes.range
            )
        }
        
        attributedText = attributedString
    }
}

public extension String {
    
    public func range(ofText text: String) -> NSRange {
        let fullText = self
        let range = (fullText as NSString).range(of: text)
        return range
    }
}


extension String {
    
    var alphanumeric: String {
        return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
    }
    
    func substring(string: String, fromIndex: Int, toIndex: Int) -> String? {
        if fromIndex < toIndex && toIndex < string.count /*use string.characters.count for swift3*/{
            let startIndex = string.index(string.startIndex, offsetBy: fromIndex)
            let endIndex = string.index(string.startIndex, offsetBy: toIndex)
            return String(string[startIndex..<endIndex])
        }else{
            return nil
        }
    }
    
    func getDateNTimeInCustmizeFormat(dateFormatterToString:String) -> String {
        let date = Date.init()
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatterToString//"dd-MM-yyyy"
        
        //        formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        let strdate1 = formatter.string(from: date as Date)
        
        return strdate1
    }
    
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
    
}

extension Date {
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

extension UINavigationController {
    //How To Use: self.navigationController?.popToViewController(vc: ServiceViewController.self)
    func popToViewController(vc: Any,animated: Bool) {
        // iterate to find the type of vc
        for element in viewControllers as Array {
            if "\(type(of: element)).Type" == "\(type(of: vc))" {
                self.popToViewController(element, animated: animated)
                break
            }
        }
    }
    
}

extension UITextField {
    func textFieldPlaceHolder(color:UIColor) {
        
    }
    
    func customizeTextField(_ borderWidth : CGFloat, _ color : UIColor, cornerRadius : CGFloat) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = cornerRadius
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setPlaceHolderColor(){
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }
}




// MARK:- Extension UIButton
extension UIButton {
    
    // MARK: shadow for Button
    
    func customizeButton(_ borderWidth : CGFloat, _ borderColor : UIColor, borderCornerRadius : CGFloat, shadowOffset_X: CGFloat, shadowOffset_Y: CGFloat, shadowOpacity: CGFloat, shadowRadius: CGFloat, shadowColor: UIColor) {
        
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = borderCornerRadius
        
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: shadowOffset_X, height: shadowOffset_Y)
        self.layer.shadowOpacity = Float(shadowOpacity)
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
    }
}

//MARK: - Extension UIColor
extension UIColor {
    convenience init(hexCode: String) {
        let hex = hexCode.trimmingCharacters(in: NSCharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

//MARK: - Extension UIImageView
extension UIImageView {
    //MARK: circular Image
    func setRounded(borderWidth:CGFloat,borderColor:UIColor) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.layer.masksToBounds = true
//        self.clipsToBounds = true
    }
    
    func imageTintColor(image:UIImageView,color:UIColor) {
        image.image = image.image!.withRenderingMode(.alwaysTemplate)
        image.tintColor = color
    }
    
    func dropShadow(shadowColor:UIColor,shadowOpacity:Float,shadowRadius:CGFloat) {
//        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func maskWith(color: UIColor) {
        guard let tempImage = image?.withRenderingMode(.alwaysTemplate) else { return }
        image = tempImage
        tintColor = color
    }
    
    func customizeImageView(_ borderWidth : CGFloat, _ borderColor : UIColor, borderCornerRadius : CGFloat, shadowOffset_X: CGFloat, shadowOffset_Y: CGFloat, shadowOpacity: CGFloat, shadowRadius: CGFloat, shadowColor: UIColor) {
        
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = borderCornerRadius
        
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: shadowOffset_X, height: shadowOffset_Y)
        self.layer.shadowOpacity = Float(shadowOpacity)
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
    }
}


extension UITableView{
    func animateTableViewCells(tableView:UITableView) {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            
            UIView.animate(withDuration: 1, delay: 0.05, usingSpringWithDamping: 0.75, initialSpringVelocity:0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
            
            index += 1
        }
    }
    
    func registerAndCustomizeTableView(_ nibName : String, cellReuseIdentifier : String){
        
        let nib = UINib(nibName: nibName, bundle: nil);
        self.register(nib, forCellReuseIdentifier: cellReuseIdentifier);
        
        //        if self.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
        //
        //            self.separatorInset = UIEdgeInsets.zero;
        //        }
        //        if self.responds(to: #selector(getter: UIView.layoutMargins)) {
        //
        //            self.layoutMargins = UIEdgeInsets.zero;
        //        }
        
        self.tableFooterView = UIView()
        
    }
}

extension UITextView {
    func setTextView(textViewObj:UITextView,CornerRadius:CGFloat,BorderColor:UIColor,BorderWidth:CGFloat) {
        textViewObj.layer.borderColor = BorderColor.withAlphaComponent(0.5).cgColor
        textViewObj.layer.borderWidth = BorderWidth
        textViewObj.layer.cornerRadius = CornerRadius
    }
}

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x+(0.5*self.frame.size.width))/self.frame.width)
    }
    
    //    how to use
    //    any subclass of scrollview
    //
    //    scrollview.currentPage or collectionView.currentPage
    
    
    func scrollToPage(index: UInt8, animated: Bool, after delay: TimeInterval) {
        let offset: CGPoint = CGPoint(x: CGFloat(index) * frame.size.width, y: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            self.setContentOffset(offset, animated: animated)
        })
    }
    
    //    scrollView.scrollToPage(index: 1, animated: true, after: 0.5)
}

//extension UIView {
//
//    func dropShadow() {
//        self.layer.masksToBounds = false
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 0.5
//        self.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.layer.shadowRadius = 5
//        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = UIScreen.main.scale
//    }
//
////    func dorpDownViewSetting(dropDwonObj:DropDown,anchorView:)
////    dropDown.anchorView = preferedContactTextField // UIView or UIBarButtonItem
////    dropDown.direction = .bottom
////    dropDown.backgroundColor = UIColor.white
////    dropDown.cellHeight = 30
////    dropDown.dataSource = ["SMS", "Text"]
////    dropDown.width = 100
//}

extension UILabel {
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}

extension UIView {
    
    func addDashedBorder(lineHeight:CGFloat,paintedSegmentLength:NSNumber,unPaintedSegmentLength:NSNumber,color:UIColor) {
        //Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineHeight//2
        // passing an array with the values [2,3] sets a dash pattern that alternates between a 2-user-space-unit-long painted segment and a 3-user-space-unit-long unpainted segment
        shapeLayer.lineDashPattern = [paintedSegmentLength,unPaintedSegmentLength]//[2,3]
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0),
                                CGPoint(x: self.frame.width, y: 0)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}




