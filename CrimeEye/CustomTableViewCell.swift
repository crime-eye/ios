//
//  CustomTableViewCell.swift
//  CrimeEye
//
//  Created by Kieran Haden on 26/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var menuLabelText: UILabel!
    @IBOutlet weak var CrimeText: UILabel!
    @IBOutlet weak var crimeIcon: UIImageView!
    @IBOutlet weak var actionTakenText: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
