//
//  TableViewCell.swift
//  Texarkana College
//
//  Created by Cory Lowry on 8/4/21.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var classLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
