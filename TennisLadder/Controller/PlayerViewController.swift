//
//  PlayerViewController.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit
import moa

class PlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Public Properties
    var player: Player!
    
    //MARK: Private Properties
    private var matches = [Match]()
    
    //MARK: Outlets
    @IBOutlet private weak var playerImage: UIImageView!
    @IBOutlet private weak var currentRankingLabel: UILabel!
    @IBOutlet private weak var recordLabel: UILabel!
    @IBOutlet private weak var matchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = player.name
		matchTableView.hideEmptyCells()
		
        loadViews()

        Endpoints.getMatches(player.ladderId, player.userId).response { (response: Response<[Match]>) in
            switch response {
            case .success(let matches):
                self.matches = matches
                self.matchTableView.reloadData()
            case .failure(let error):
                self.displayError(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.matchTableView.reloadData()
    }
    
    private func loadViews() {
        playerImage.moa.url = player.photoUrl
        currentRankingLabel.text = "#\(String(player.ranking))"
        recordLabel.text = String("\(player.wins) - \(player.losses)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = matchTableView.dequeueCell(at: indexPath)
        
        if let cell = cell as? MatchTableViewCell {
            //Initialize the cell with the ladder at that index path
            cell.match = matches[indexPath.row]
        }
        
        return cell
    }
}

