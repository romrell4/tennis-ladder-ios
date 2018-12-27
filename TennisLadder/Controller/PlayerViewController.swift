//
//  PlayerViewController.swift
//  Tennis
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
        loadViews()
        
        if let userId = Int(player.userId) {
            Endpoints.getMatches(player.ladderId, userId).response { (response: Response<[Match]>) in
                switch response {
                case .success(let matches):
                    self.matches = matches
                    self.matchTableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        let cell = matchTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let cell = cell as? MatchTableViewCell {
            cell.match = matches[indexPath.row]
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "matchReported",
            let vc = segue.destination as? ReportMatchViewController {
            
            //TODO: Figure out player one and why this is not passing anything
            vc.currentPlayer = player
            vc.opponentPlayer = player
            vc.delegate = self
        }
    }
}

extension PlayerViewController: ReportMatchViewControllerDelegate {
    func passNewMatch(match: Match) {
        matches.append(match)
    }
}
