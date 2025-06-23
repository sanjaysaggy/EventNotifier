//
//  SambagMonthYearPickerViewController.swift
//  Sambag
//
//  Created by Mounir Ybanez on 03/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import UIKit

public protocol SambagMonthYearPickerViewControllerDelegate: class {
    
    func sambagMonthYearPickerDidSet(_ viewController: SambagMonthYearPickerViewController, result: String)
    func sambagMonthYearPickerDidCancel(_ viewController: SambagMonthYearPickerViewController)
}

@objc protocol SambagMonthYearPickerViewControllerInteraction: class {
    
    func didTapSet()
    func didTapCancel()
}

public class SambagMonthYearPickerViewController: UIViewController {
    
    
    var contentView: UIView!
    var titleLabel: UILabel!
    var strip1: UIView!
    var strip2: UIView!
    var strip3: UIView!
    
    var okayButton: UIButton!
    var cancelButton: UIButton!
    
    var monthWheel: WheelViewController!
    var yearWheel: WheelViewController!

    var result: SambagMonthYearPickerResult {
        var result = SambagMonthYearPickerResult()
        result.month = SambagMonth(rawValue: monthWheel.selectedIndexPath.row + 1)!
        result.year = Int(yearWheel.items[yearWheel.selectedIndexPath.row])!
        return result
    }
    
    public weak var delegate: SambagMonthYearPickerViewControllerDelegate?
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }
    
    public override func loadView() {
        super.loadView()
        
        yearWheel = WheelViewController()

        view.backgroundColor = UIColor.clear
        
        contentView = UIView()
        contentView.backgroundColor = UIColor.clear
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        
        titleLabel = UILabel()
        titleLabel.text = "Select year"
        titleLabel.textColor = yearWheel.cellTextColor
        titleLabel.font = yearWheel.cellTextFont
        
        strip1 = UIView()
        strip1.backgroundColor = yearWheel.stripColor
        
        strip2 = UIView()
        strip2.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        
        strip3 = UIView()
        strip3.backgroundColor = strip2.backgroundColor
        
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        
        var items = [String]()
        for i in 1..<13 {
            let month = SambagMonth(rawValue: i)!
            items.append("\(month)")
        }
        
        monthWheel = WheelViewController()
        monthWheel.items = items
        monthWheel.selectedIndexPath.row = month - 1
        
        items.removeAll()
        let offset: Int = 101
        for i in 1..<offset {
            items.append("\(year - (offset - i))")
        }
        for i in 0..<offset {
            items.append("\(year + i)")
        }
        
        yearWheel.items = items
        yearWheel.selectedIndexPath.row = offset - 1
    }
    
    public override func viewDidLayoutSubviews() {
        var rect = CGRect.zero
        
        let contentViewHorizontalMargin: CGFloat = 10
        let contentViewWidth: CGFloat = (view.frame.width - contentViewHorizontalMargin * 2)
        
        rect.origin.x = 20
        rect.size.width = contentViewWidth - rect.origin.x * 2
        rect.origin.y = 20
        rect.size.height = titleLabel.sizeThatFits(rect.size).height
        titleLabel.frame = rect
        
        rect.origin.x = 0
        rect.origin.y = rect.maxY + rect.origin.y
        rect.size.width = contentViewWidth
        rect.size.height = 2
        strip1.frame = rect
        
        let wheelWidth: CGFloat = 72
        
        rect.origin.y = rect.maxY + 10
        rect.size.width = wheelWidth
        rect.size.height = 150
        rect.origin.x = (contentViewWidth - wheelWidth) / 2
        yearWheel.itemHeight = rect.height / 3
        yearWheel.view.frame = rect

        rect.origin.y = rect.maxY + 20
        rect.origin.x = 0
        rect.size.width = strip1.frame.width
        rect.size.height = 1
        strip2.frame = rect

        rect.origin.x = rect.maxX
        rect.size.width = 1
        strip3.frame = rect
        
        contentView.frame = CGRect(x: 0, y: 0, width: contentViewWidth , height: 240)
        if(contentView.superview == nil) {
            view.addSubview(contentView)
            contentView.addSubview(titleLabel)
            contentView.addSubview(strip1)
            contentView.addSubview(strip2)
            contentView.addSubview(strip3)
            contentView.addSubview(yearWheel.view)
        }
        
        let alertController = UIAlertController(title: nil, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertController.Style.actionSheet)
        alertController.view.addSubview(contentView)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        { (action) in
            self.delegate?.sambagMonthYearPickerDidCancel(self)
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "Done", style: .default)
        { (action) in
            let year = self.yearWheel.items[self.yearWheel.selectedIndexPath.row]
            self.delegate?.sambagMonthYearPickerDidSet(self, result: year)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
    }
    
    func initSetup() {
        modalPresentationStyle = .custom
    }
}

//extension SambagMonthYearPickerViewController: SambagMonthYearPickerViewControllerInteraction {
//
////    func didTapSet() {
////        var result = SambagMonthYearPickerResult()
//////        result.month = SambagMonth(rawValue: monthWheel.selectedIndexPath.row + 1)!
////        result.year = Int(yearWheel.items[yearWheel.selectedIndexPath.row])!
////        delegate?.sambagMonthYearPickerDidSet(self, result: result)
////    }
////
////    func didTapCancel() {
////        delegate?.sambagMonthYearPickerDidCancel(self)
////    }
//}
