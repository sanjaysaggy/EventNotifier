//
//  SideMenuTableViewCell.swift
//  TimeStamp
//
 

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTitle : UILabel!
//    @IBOutlet weak var switchObj : UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

//        switchObj.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
//        self.labelCount.layer.cornerRadius = self.labelCount.frame.size.height/2
//        self.labelCount.layer.borderColor = GreenColor.cgColor
//        self.labelCount.layer.borderWidth = 1
    }
    
}
