//
//  ProfileViewController.swift
//  TennisLadder
//
//  Created by Eric Romrell on 1/13/19.
//  Copyright © 2019 Z Tai. All rights reserved.
//

import UIKit
import moa

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	//MARK: Public Properties
	var myId: String!
	var userId: String!
	
	//MARK: Private Properties
	private var editable: Bool { return myId == userId }
	private var user: TLUser? {
		didSet {
			profileImage.moa.url = user?.photoUrl
			loadTableData()
		}
	}
	private var tableData = [RowData]()
	private struct RowData {
		let label: String
		var value: String?
		let action: ((String) -> Void)
	}
	
	//MARK: Outlets
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
	@IBOutlet private weak var profileImage: UIImageView!
	@IBOutlet private weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.hideEmptyCells()
		
		//Remove the "Save" button if they aren't able to edit
		if !editable {
			navigationItem.rightBarButtonItem = nil
		}
		
		Endpoints.getUser(userId).response { (response: Response<TLUser>) in
			self.spinner.stopAnimating()
			
			switch response {
			case .success(let user):
				self.user = user
			case .failure(let error):
				self.displayError(error)
			}
		}
	}
	
	//MARK: UITableViewDataSource/Delegate
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return editable ? "Tap to Edit Values" : nil
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let rowData = tableData[indexPath.row]
		
		let cell = tableView.dequeueCell(at: indexPath)
		if let cell = cell as? ProfileInfoTableViewCell {
			cell.setup(title: rowData.label, value: rowData.value, editable: editable)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		//Only allow them to tap cells if we are editable
		return editable ? indexPath : nil
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let rowData = tableData[indexPath.row]
		
		showEditDialog(label: rowData.label) {
			rowData.action($0)
			self.loadTableData()
		}
	}
	
	//MARK: Listeners
	
	@IBAction func cancelTapped(_ sender: Any) {
		dismiss(animated: true)
	}
	
	@IBAction func saveTapped(_ sender: Any) {
		if let user = user {
			spinner.startAnimating()
			Endpoints.updateUser(userId, user).response { (response: Response<TLUser>) in
				self.spinner.stopAnimating()
				
				switch response {
				case .success(let user):
					self.user = user
					self.displayAlert(title: "Success", message: "Profile successfully updated") { (_) in
						self.dismiss(animated: true)
					}
				case .failure(let error):
					self.displayError(error)
				}
			}
		}
	}
	
	@IBAction func photoTapped(_ sender: Any) {
		//Only let them edit the photo if we are editable
		if editable {
			showEditDialog(label: "Photo URL") {
				self.user?.photoUrl = $0
				self.profileImage.moa.url = $0
			}
		}
	}
	
	//MARK: Private Functions
	
	private func showEditDialog(label: String, action: @escaping (String) -> Void) {
		let alert = UIAlertController(title: "Edit Value", message: "Enter new value for '\(label)':", preferredStyle: .alert)
		alert.addTextField()
		alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
			if let newValue = alert.textFields?.first?.text {
				action(newValue)
			}
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
			self.tableView.deselectSelectedRow()
		})
		present(alert, animated: true)
	}
	
	private func loadTableData() {
		if let user = user {
			tableData = [
				RowData(label: "Email", value: user.email, action: {
					self.user?.email = $0
				}),
				RowData(label: "Name", value: user.name, action: {
					self.user?.name = $0
				}),
				RowData(label: "Phone Number", value: user.phoneNumber, action: {
					//If the user tries to set an empty string, treat it as nil
					self.user?.phoneNumber = $0.nonEmpty()
				}),
				RowData(label: "Availability", value: user.availabilityText, action: {
					//If the user tries to set an empty string, treat it as nil
					self.user?.availabilityText = $0.nonEmpty()
				})
			]
			tableView.reloadData()
		}
	}
}

private extension String {
	func nonEmpty() -> String? {
		return self.isEmpty ? nil : self
	}
}
