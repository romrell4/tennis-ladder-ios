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

private enum ButtonState {
	case reportMatch, requestInvite, login
}

class LadderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
	//MARK: Public properties
	var ladder: Ladder!
	
	//MARK: Private properties
	private var players = [Player]() {
		didSet {
			tableView.setEmptyMessage("There are no players in this ladder yet. Please check back later.")
			updateState()
		}
	}
	private var me: Player? {
		return players.filter { $0.user.userId == Auth.auth().currentUser?.uid }.first
	}
    private var isAdmin: Bool = false {
        didSet {
            // Only add the button if we're an admin before the start date
            if isAdmin, ladder.startDate > Date() {
                navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(adminMenuTapped)), animated: true)
            }
        }
    }
	private var buttonState: ButtonState? {
		didSet {
			if let buttonState = buttonState {
				switch buttonState {
				case .reportMatch:
					bottomButton.title = "Report a Match"
				case .requestInvite:
					bottomButton.title = "Join This Ladder"
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
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressDetected(sender:))))
        
        if let userId = Auth.auth().currentUser?.uid {
            Endpoints.getUser(userId).response { (response: Response<TLUser>) in
                if case let .success(user) = response {
                    self.isAdmin = user.admin
                }
            }
        }
		
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
			vc.me = me
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = players[sourceIndexPath.row]
        players.remove(at: sourceIndexPath.row)
        players.insert(movedObject, at: destinationIndexPath.row)
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
    
    @objc func longPressDetected(sender: UILongPressGestureRecognizer) {
        if isAdmin && ladder.startDate < Date() && sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                var player = players[indexPath.row]
                
                let alert = UIAlertController(title: "Update Player", message: "Please enter the new borrowed points for this player.", preferredStyle: .alert)
                alert.addTextField {
                    $0.keyboardType = .numberPad
                    $0.placeholder = "Borrowed Points"
                }
                alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
                    if let text = alert.textFields?.first?.text, let newBorrowedPoints = Int(text) {
                        player.borrowedPoints = newBorrowedPoints
                        self.spinner.startAnimating()
                        Endpoints.updatePlayer(ladderId: self.ladder.ladderId, userId: player.user.userId, player: player).response { (response: Response<[Player]>) in
                            self.spinner.stopAnimating()
                            switch (response) {
                            case .success(let players):
                                self.players = players
                            case .failure(let error):
                                self.displayError(error)
                            }
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc func adminMenuTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Admin options", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: tableView.isEditing ? "Save" : "Edit", style: .default) { _ in
            if self.tableView.isEditing {
                // Just finished editing. Need to save order
                self.updatePlayerOrder(generateBorrowedPoints: false)
            } else {
                self.tableView.isEditing = true
            }
        })
        actionSheet.addAction(UIAlertAction(title: "Generate borrowed points", style: .destructive) { _ in
            self.updatePlayerOrder(generateBorrowedPoints: true)
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
	
	@IBAction func bottomButtonTapped(_ sender: Any) {
		if let buttonState = buttonState {
			switch buttonState {
			case .reportMatch:
				let alert = UIAlertController(title: "Who did you play against?", message: nil, preferredStyle: .actionSheet)
				
				//Removing self from list of people to play against, and order alphabetically
				players.filter { $0 != me }.sorted { $0.user.name.lowercased() < $1.user.name.lowercased() }.forEach { player in
					alert.addAction(UIAlertAction(title: player.user.name, style: .default) { (_) in
						self.performSegue(withIdentifier: "matchReported", sender: player)
					})
				}
				
				alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
				present(alert, animated: true)
			case .requestInvite:
				//Present a challenge for the ladder's code
				let alert = UIAlertController(title: "Ladder Invite Request", message: "Please provide the entry code for this ladder:", preferredStyle: .alert)
				alert.addTextField()
				alert.addAction(UIAlertAction(title: "Go", style: .default, handler: { (_) in
					guard let code = alert.textFields?.first?.text else { return }
					
					//Dismiss the code dialog, and make the request
					self.spinner.startAnimating()
					Endpoints.addUserToLadder(self.ladder.ladderId, code).response { (response: Response<[Player]>) in
						self.spinner.stopAnimating()
						
						switch response {
						case .success(let players):
							self.displayAlert(title: "Success!", message: "You have successfully been added to this ladder.")
							self.players = players
						case .failure(let error):
							self.displayError(error)
						}
					}
				}))
				alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
				present(alert, animated: true)
				break
			case .login:
				presentLoginViewController { (user) in
					self.updateState()
				}
			}
		}
    }
    
    private func updatePlayerOrder(generateBorrowedPoints: Bool) {
        spinner.startAnimating()
        Endpoints.updatePlayerOrder(ladderId: self.ladder.ladderId, players: self.players, generateBorrowedPoints: generateBorrowedPoints).response { (response: Response<[Player]>) in
            self.spinner.stopAnimating()
            switch response {
            case .success(let players):
                self.tableView.isEditing = false
                self.players = players
            case .failure(let error):
                self.displayError(error)
            }
        }
    }
	
	private func updateState() {
		if me != nil {
			buttonState = .reportMatch
		} else if Auth.auth().currentUser != nil {
			buttonState = .requestInvite
		} else {
			buttonState = .login
		}
		
		//Reload the table (so that the cell background color gets reloaded)
		tableView.reloadData()
	}
}

