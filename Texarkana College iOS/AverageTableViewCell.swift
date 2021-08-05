//
//  AverageTableViewCell.swift
//  Texarkana College
//
//  Created by Cory Lowry on 8/4/21.
//

import Foundation
import UIKit

class AverageTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var averageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
