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
	@IBOutlet private weak var valueTextView: UITextView!

	override func awakeFromNib() {
		super.awakeFromNib()

		valueTextView.textContainerInset = .zero
		valueTextView.textContainer.lineFragmentPadding = 0
	}
	
	//MARK: Public Functions
	
	func setup(title: String, value: String?, editable: Bool) {
		titleLabel?.text = title
		valueTextView.text = value ?? (editable ? "Tap to set" : "")
		//If the value is not set yet, make the text gray
		valueTextView.textColor = value != nil ? .defaultLabel : .gray
	}
}

private extension UIColor {
	static var defaultLabel: UIColor {
		if #available(iOS 13.0, *) {
			return .label
		} else {
			return .black
		}
	}
}
