//
//  CustomCellTableViewCell.swift
//  Tennis
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit

private let DATE_FORMATTTER = DateFormatter.defaultDateFormat("d/M/yyyy")

class LadderTableViewCell: UITableViewCell {
    @IBOutlet weak var ladderText: UILabel!
    @IBOutlet weak var dateRange: UILabel!
	
	var ladder: Ladder! {
		didSet {
			ladderText.text = ladder.name
			dateRange.text = "\(DATE_FORMATTTER.string(from: ladder.startDate)) - \(DATE_FORMATTTER.string(from: ladder.endDate))"
		}
	}
}
