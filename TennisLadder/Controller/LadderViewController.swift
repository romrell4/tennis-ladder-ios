//
//  LadderViewController.swift
//  Tennis
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import FirebaseAuth
import moa

enum ButtonState {
	case reportMatch, requestInvite, login
}

class LadderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
	//MARK: Public properties
	var ladder: Ladder!
	
	//MARK: Private properties
	private var players = [Player]() {
		didSet {
			tableView.setEmptyMessage("There are no players in this ladder yet. Please check back later.")
			me = players.first { $0.userId == Auth.auth().currentUser?.uid }
			buttonState = me != nil ? .reportMatch : (Auth.auth().currentUser != nil ? .requestInvite : .login)
			tableView.reloadData()
		}
	}
	private var me: Player?
	private var buttonState: ButtonState? {
		didSet {
			if let buttonState = buttonState {
				switch buttonState {
				case .reportMatch:
					bottomButton.title = "Report a Match"
				case .requestInvite:
					bottomButton.title = "Request an Invite to This Ladder"
				case .login:
					bottomButton.title = "Login to Report a Match"
				}
			}
		}
	}
    
	//MARK: Outlets
    @IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var bottomButton: UIBarButtonItem!
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = ladder.name
		tableView.hideEmptyCells()
		tableView.refreshControl = UIRefreshControl(title: "Refreshing...", target: self, action: #selector(loadPlayers))
		
		loadPlayers()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.deselectSelectedRow()
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playerSelected",
            let vc = segue.destination as? PlayerViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            
            vc.player = players[indexPath.row]
        } else if segue.identifier == "matchReported",
            let navVc = segue.destination as? UINavigationController,
			let vc = navVc.viewControllers.first as? ReportMatchViewController,
            let player = sender as? Player {
            
            vc.me = me
            vc.opponent = player
        }
    }
    
	//MARK: UITableViewDelegate/Datasource
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(at: indexPath)
        
        if let cell = cell as? PlayerTableViewCell {
            let player = players[indexPath.row]
            
            //Initialize the cell with the ladder at that index path
            cell.player = player
        
            //Highlight the logged in player
            cell.backgroundColor = player == me ? .meRowColor : .clear
        }
        
        return cell
    }
	
	//MARK: Listeners
	
	@IBAction func unwind(_ segue: UIStoryboardSegue) {
		loadPlayers()
	}
	
	@objc private func loadPlayers() {
		Endpoints.getPlayers(ladder.ladderId).response { (response: Response<[Player]>) in
			self.spinner.stopAnimating()
			self.tableView.refreshControl?.endRefreshing()
			
			switch response {
			case .success(let players):
				self.players = players
			case .failure(let error):
				self.displayError(error) { (_) in
					self.popBack()
				}
			}
		}
	}
    
	@IBAction func rulesTapped(_ sender: Any) {
		presentSafariViewController(urlString: "https://romrell4.github.io/tennis-ladder-ws/rules.html")
	}
	
	@IBAction func bottomButtonTapped(_ sender: Any) {
		if let buttonState = buttonState {
			switch buttonState {
			case .reportMatch:
				let alert = UIAlertController(title: "Who did you play against?", message: nil, preferredStyle: .actionSheet)
				
				//Removing self from list of people to play against
				players.filter { $0 != me }.forEach { player in
					alert.addAction(UIAlertAction(title: player.name, style: .default) { (_) in
						self.performSegue(withIdentifier: "matchReported", sender: player)
					})
				}
				
				alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
				present(alert, animated: true)
			case .requestInvite:
				//TODO: Somehow request to be invited to the ladder
				break
			case .login:
				//TODO: Login the user in
				break
			}
		}
    }
}

