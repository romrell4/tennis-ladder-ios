//
//  MainViewController.swift
//  HomeViewController.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import FirebaseUI

private enum ButtonState {
	case loggedIn(user: User), loggedOut
	
	var statusText: String {
		switch self {
		case .loggedIn(let user):
			return "Logged in as \(user.displayName ?? "Anonymous")"
		default:
			return "Not logged in"
		}
	}
	
	func getActionSheetAction(vc: MainViewController) -> UIAlertAction {
		switch self {
		case .loggedIn:
			return UIAlertAction(title: "Log Out", style: .default) { (_) in
				try? Auth.auth().signOut()
				vc.buttonState = .loggedOut
			}
		case .loggedOut:
			return UIAlertAction(title: "Log In", style: .default) { (_) in
				vc.presentLoginViewController()
			}
		}
	}
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	//MARK: Public properties
	var ladderIdToLaunch: Int? {
		didSet {
			if let ladder = ladders.first(where: { $0.ladderId == ladderIdToLaunch }) {
				ladderIdToLaunch = nil
				launchLadder(ladder)
			}
		}
	}
	
	//MARK: Private properties
	private var ladders = [Ladder]() {
		didSet {
			if let ladder = ladders.first(where: { $0.ladderId == ladderIdToLaunch }) {
				ladderIdToLaunch = nil
				launchLadder(ladder)
			}
		}
	}
	fileprivate var buttonState: ButtonState = .loggedOut {
		didSet {
			statusLabel.text = buttonState.statusText
		}
	}
	
	//MARK: Outlets
	@IBOutlet private weak var statusLabel: UILabel!
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.hideEmptyCells()
		
		setupLoginState()
		
		loadLadders()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		tableView.deselectSelectedRow()
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ladderSelected", let vc = segue.destination as? LadderViewController, let ladder = sender as? Ladder {
			vc.ladder = ladder
		} else if segue.identifier == "profile", let navVc = segue.destination as? UINavigationController, let vc = navVc.viewControllers.first as? ProfileViewController {
			vc.userId = Auth.auth().currentUser?.uid
		}
    }
	
	//MARK: UITableViewDelegate/Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ladders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(at: indexPath)
        
        if let cell = cell as? LadderTableViewCell {
			//Initialize the cell with the ladder at that index path
            cell.ladder = ladders[indexPath.row]
        }
        
        return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		launchLadder(ladders[indexPath.row])
	}
	
	//MARK: Listeners
	
	@IBAction func settingsTapped(_ sender: Any) {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		actionSheet.addAction(buttonState.getActionSheetAction(vc: self))
		
		//Show the profile option if they're logged in
		if case .loggedIn = buttonState {
			actionSheet.addAction(UIAlertAction(title: "Profile", style: .default) { (_) in
				self.performSegue(withIdentifier: "profile", sender: nil)
			})
		}
		
		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(actionSheet, animated: true)
	}
	
	//MARK: Private Functions
	
	@objc private func loadLadders() {
		//Make a request to get the ladders and reload the UI when the response comes back
		Endpoints.getLadders().response { (response: Response<[Ladder]>) in
			self.spinner.stopAnimating()
			self.tableView.refreshControl?.endRefreshing()
			
			switch response {
			case .success(let ladders):
				self.ladders = ladders
				self.tableView.setEmptyMessage("There are no available ladders right now. Please check back later.")
				self.tableView.reloadData()
			case .failure(let error):
				self.displayError(error)
			}
		}
	}
	
	private func setupLoginState() {
		let updateState = { (user: User?) in
			if let user = user {
				self.buttonState = .loggedIn(user: user)
			} else {
				self.buttonState = .loggedOut
			}
		}
		
		//Update state right now (initial setup)
		updateState(Auth.auth().currentUser)
		
		//Add a listener to rerun the closure whenever the state changes
		Auth.auth().addStateDidChangeListener { (_, user) in
			updateState(user)
		}
	}
	
	private func launchLadder(_ ladder: Ladder) {
		performSegue(withIdentifier: "ladderSelected", sender: ladder)
	}
}
