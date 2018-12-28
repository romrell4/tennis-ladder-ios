//
//  LadderViewController.swift
//  Tennis
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import moa

class LadderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
	//MARK: Public properties
	var ladder: Ladder!
	
	//MARK: Private properties
	private var players = [Player]()
	
	//MARK: Outlets
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Endpoints.getPlayers(ladder.ladderId).response { (response: Response<[Player]>) in
            switch response {
            case .success(let players):
                self.players = players
                self.tableView.reloadData()
            case .failure(let error):
                self.displayError(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playerSelected",
            let vc = segue.destination as? PlayerViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            
            vc.player = players[indexPath.row]
        } else if segue.identifier == "matchReported",
            let vc = segue.destination as? ReportMatchViewController,
            let player = sender as? Player {
            //TODO: Figure out Google's Auth.auth().currentUser.userId
                vc.currentPlayer = player
                vc.userPlayer = player
            }
    }
    
	//MARK: UITableViewDelegate/Datasource
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(at: indexPath)
        
        if let cell = cell as? PlayerCell {
            //Initialize the cell with the ladder at that index path
            cell.player = players[indexPath.row]
        }
        
        return cell
    }
    
    @IBAction func reportMatchTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Who did you play agaisnt?", message: nil, preferredStyle: .actionSheet)
        
        players.forEach { player in
            alert.addAction(UIAlertAction(title: player.name, style: .default) { (_) in
                self.performSegue(withIdentifier: "playerSelected", sender: player)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

