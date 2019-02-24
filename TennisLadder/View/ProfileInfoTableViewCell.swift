//
//  ProfileInfoTableViewCell.swift
//  TennisLadder
//
//  Created by Eric Romrell on 2/23/19.
//  Copyright © 2019 Z Tai. All rights reserved.
//

import UIKit

class ProfileInfoTableViewCell: UITableViewCell {
	
	//MARK: Private Outlets
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var valueLabel: UILabel!
	
	//MARK: Public Functions
	
	func setup(title: String, value: String?, editable: Bool) {
		titleLabel?.text = title
		valueLabel?.text = value ?? (editable ? "Tap to set" : nil)
		
		//If the value is not set yet, make the text gray
		valueLabel?.textColor = value != nil ? .black : .gray
	}
}
