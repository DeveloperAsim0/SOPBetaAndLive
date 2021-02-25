//
//  ScanHistoryTableViewCell.swift
//  SOP
//
//  Created by Shivam Saini on 06/10/18.
//  Copyright © 2018 StarTrack. All rights reserved.
//

import UIKit

class ScanHistoryTableViewCell: UITableViewCell {

    @IBOutlet var jobNumber: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var timeIn: UILabel!
    @IBOutlet var timeOut: UILabel!
    @IBOutlet var RMeter: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
