//
//  PlayerViewController.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import moa
import MessageUI
import ContactsUI

class PlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, CNContactViewControllerDelegate {
    //MARK: Public Properties
    var player: Player!
	var me: Player?
    var isAdmin: Bool!
    
    //MARK: Private Properties
    private var matches = [Match]()
    
    //MARK: Outlets
    @IBOutlet private weak var playerImage: UIImageView!
	@IBOutlet private weak var viewProfileButton: UIButton!
	@IBOutlet private weak var currentRankingLabel: UILabel!
    @IBOutlet private weak var recordLabel: UILabel!
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
	@IBOutlet private weak var matchTableView: UITableView!
	@IBOutlet private weak var toolbar: UIToolbar!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = player.user.name
		matchTableView.hideEmptyCells()
		
        loadViews()

        Endpoints.getMatches(player.ladderId, player.user.userId).response { (response: Response<[Match]>) in
			self.spinner.stopAnimating()
			
            switch response {
            case .success(let matches):
                self.matches = matches
				self.matchTableView.setEmptyMessage("This player hasn't played any matches in this ladder yet. Please check back later.")
                self.matchTableView.reloadData()
            case .failure(let error):
				self.displayError(error)
            }
        }
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "viewProfile", let navVc = segue.destination as? UINavigationController, let vc = navVc.viewControllers.first as? ProfileViewController {
			vc.myId = me?.user.userId
			vc.userId = player.user.userId
		}
	}
	
	//MARK: UITableViewDataSource/Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = matchTableView.dequeueCell(at: indexPath)
		if let cell = cell as? MatchTableViewCell {
			cell.setup(match: matches[indexPath.row], for: player)
		}
		
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAdmin {
            let actionSheet = UIAlertController(title: "What would you like to do with this match?", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Edit Scores", style: .default, handler: { _ in
                self.editMatchScores(at: indexPath)
            }))
            actionSheet.addAction(UIAlertAction(title: "Delete", style: .default, handler: { _ in
                self.deleteMatch(at: indexPath)
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true)
        }
    }
	
	//MARK: MFMessageComposeViewControllerDelegate
	
	func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
		controller.dismiss(animated: true)
	}
	
	//MARK:
	
	func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
		viewController.dismiss(animated: true)
	}
	
	//MARK: Listeners
	
	@IBAction func addTapped(_ sender: Any) {
		var nameParts = player.user.name.split(separator: " ")
		let lastName = String(nameParts.removeLast())
		let givenName = nameParts.joined(separator: " ")
		
		let contact = CNMutableContact()
		contact.givenName = givenName
		contact.familyName = lastName
		contact.imageData = playerImage.image?.pngData()
		contact.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: player.user.email as NSString)]
		if let phoneNumber = player.user.phoneNumber {
			contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: phoneNumber))]
		}
		let vc = CNContactViewController(forUnknownContact: contact)
		vc.delegate = self
		vc.contactStore = CNContactStore()
		
		let navVc = UINavigationController(rootViewController: vc)
		vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissContacts))
		present(navVc, animated: true)
	}
	
	@objc func dismissContacts() {
		dismiss(animated: true)
	}
	
	@IBAction func challengeTapped(_ sender: Any) {
		let contactOptions: [(String, String?, (String?) -> Void)] = [
			("Email", player.user.email, { email in
				if let email = email {
					let mailUrlPrefixes = [
						("Mail", "mailto:"),
						("Gmail", "googlegmail:///co"),
						("Outlook", "ms-outlook://compose")
					]
					let subject = "Tennis Ladder Challenge".replacingOccurrences(of: " ", with: "%20")
					
					let alert = UIAlertController(title: "Which mail app would you like to use?", message: nil, preferredStyle: .actionSheet)
					
					mailUrlPrefixes.forEach {
						if let url = URL(string: "\($0.1)?to=\(email)&subject=\(subject)"), UIApplication.shared.canOpenURL(url) {
							alert.addAction(UIAlertAction(title: $0.0, style: .default) { _ in
								UIApplication.shared.open(url)
							})
						}
					}
					alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
					self.present(alert, animated: true)
				}
			}),
			("Phone", player.user.phoneNumber, { phoneNumber in
				if let phoneNumber = phoneNumber {
					let vc = MFMessageComposeViewController()
					vc.messageComposeDelegate = self
					vc.recipients = [phoneNumber]
					if MFMessageComposeViewController.canSendText() {
						self.present(vc, animated: true)
					}
				}
			})
		].filter { $0.1 != nil }
		
		let alert = UIAlertController(title: "Contact player via:", message: nil, preferredStyle: .actionSheet)
		contactOptions.forEach { (option) in
			alert.addAction(UIAlertAction(title: option.0, style: .default) { _ in
				option.2(option.1)
			})
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(alert, animated: true)
	}
	
	//MARK: Private Functions
	
	private func loadViews() {
		playerImage.moa.url = player.user.photoUrl
		currentRankingLabel.text = "#\(String(player.ranking))"
		recordLabel.text = String("\(player.wins) - \(player.losses)")
		
		//If nobody is logged in, or if you're looking at yourself, remove a few buttons
		if me == nil || me == player {
			navigationItem.rightBarButtonItem = nil
			toolbar.isHidden = true
			viewProfileButton.removeFromSuperview()
		}
	}
    
    private func editMatchScores(at indexPath: IndexPath) {
        var match = matches[indexPath.row]
        let alert = UIAlertController(title: "Edit Match Scores", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = String(match.winnerSet1Score) }
        alert.addTextField { $0.text = String(match.loserSet1Score) }
        alert.addTextField { $0.text = String(match.winnerSet2Score) }
        alert.addTextField { $0.text = String(match.loserSet2Score) }
        alert.addTextField {
            if let score = match.winnerSet3Score {
                $0.text = String(score)
            } else {
                $0.placeholder = "Winner set 3 score"
            }
        }
        alert.addTextField {
            if let score = match.loserSet3Score {
                $0.text = String(score)
            } else {
                $0.placeholder = "Loser set 3 score"
            }
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            if let matchId = match.matchId,
               let winnerSet1 = alert.textFields?[0].text?.toInt(), let loserSet1 = alert.textFields?[1].text?.toInt(),
               let winnerSet2 = alert.textFields?[2].text?.toInt(), let loserSet2 = alert.textFields?[3].text?.toInt() {
                let winnerSet3 = alert.textFields?[4].text?.toInt()
                let loserSet3 = alert.textFields?[5].text?.toInt()
                
                match.winnerSet1Score = winnerSet1
                match.winnerSet2Score = winnerSet2
                match.winnerSet3Score = winnerSet3
                match.loserSet1Score = loserSet1
                match.loserSet2Score = loserSet2
                match.loserSet3Score = loserSet3
                self.spinner.startAnimating()
                Endpoints.updateMatchScores(match.ladderId, matchId, match).response { (response: Response<Match>) in
                    self.spinner.stopAnimating()
                    
                    switch response {
                    case .success(let match):
                        self.matches[indexPath.row] = match
                        self.matchTableView.reloadRows(at: [indexPath], with: .automatic)
                    case .failure(let error):
                        self.displayError(error)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func deleteMatch(at indexPath: IndexPath) {
        let match = matches[indexPath.row]
        self.spinner.startAnimating()
        Endpoints.deleteMatch(ladderId: match.ladderId, matchId: match.matchId ?? 0).response { response in
            self.spinner.stopAnimating()
            
            switch response {
            case .success:
                self.matches.remove(at: indexPath.row)
                self.matchTableView.deleteRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                self.displayError(error)
            }
        }
    }
}

