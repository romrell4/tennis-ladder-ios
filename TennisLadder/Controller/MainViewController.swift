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
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	//MARK: Private properties
    private var ladders = [Ladder]()
	private var buttonState: ButtonState = .loggedOut {
		didSet {
			switch buttonState {
			case .loggedIn(let user):
				statusButton.title = "Log Out"
				statusLabel.text = "Logged in as \(user.displayName ?? "Anonymous")"
			default:
				statusButton.title = "Log In"
				statusLabel.text = "Not logged in"
			}
		}
	}
	
	//MARK: Outlets
	@IBOutlet private weak var statusButton: UIBarButtonItem!
	@IBOutlet private weak var statusLabel: UILabel!
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.hideEmptyCells()
		
		setupLoginState()
		
		//Make a request to get the ladders and reload the UI when the response comes back
		Endpoints.getLadders().response { (response: Response<[Ladder]>) in
			self.spinner.stopAnimating()
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
	
	override func viewWillAppear(_ animated: Bool) {
		tableView.deselectSelectedRow()
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ladderSelected", let vc = segue.destination as? LadderViewController, let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
			//Pass the ladder they click on to the next view controller
			vc.ladder = ladders[indexPath.row]
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
	
	//MARK: Listeners
	
	@IBAction func settingsTapped(_ sender: Any) {
		//TODO: Add profile page
		if Auth.auth().currentUser != nil {
			try? Auth.auth().signOut()
			buttonState = .loggedOut
		} else {
			presentLoginViewController()
		}
	}
	
	//MARK: Private Functions
	
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
}
