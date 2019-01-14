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
	var userId: String!
	
	//MARK: Private Properties
	private var user: TLUser? {
		didSet {
			if let user = user {
				profileImage.moa.url = user.photoUrl
				tableData = [
					RowData(title: "Name", value: user.name, editable: false),
					RowData(title: "Email", value: user.email, editable: false),
					RowData(title: "Phone Number", value: user.phoneNumber, editable: true)
				]
				tableView.reloadData()
			}
		}
	}
	private var tableData = [RowData]()
	private struct RowData {
		let title: String
		var value: String?
		let editable: Bool
	}
	
	//MARK: Outlets
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
	@IBOutlet private weak var profileImage: UIImageView!
	@IBOutlet private weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.hideEmptyCells()
		
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
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let rowData = tableData[indexPath.row]
		
		let cell = tableView.dequeueCell(at: indexPath)
		cell.textLabel?.text = rowData.title
		cell.detailTextLabel?.text = rowData.value ?? "Tap to set"
		cell.detailTextLabel?.textColor = rowData.value != nil ? UIColor.black : UIColor.gray
		return cell
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		return tableData[indexPath.row].editable ? indexPath : nil
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let rowData = tableData[indexPath.row]
		
		let alert = UIAlertController(title: "Edit Value", message: "Enter new value for '\(rowData.title)':", preferredStyle: .alert)
		alert.addTextField()
		alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
			//TODO: Gotta save the value somehow so that when they tap save, it sends the new object across...
			self.tableData[indexPath.row].value = alert.textFields?.first?.text
			self.tableView.reloadData()
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
			self.tableView.deselectSelectedRow()
		})
		present(alert, animated: true)
	}
	
	//MARK: Listeners
	
	@IBAction func saveTapped(_ sender: Any) {
		if let user = user {
			spinner.startAnimating()
			Endpoints.updateUser(userId, user).response { (response: Response<TLUser>) in
				self.spinner.stopAnimating()
				
				switch response {
				case .success(let user):
					self.user = user
					self.displayAlert(title: "Success", message: "Profile successfully updated")
				case .failure(let error):
					self.displayError(error)
				}
			}
		}
	}
}
