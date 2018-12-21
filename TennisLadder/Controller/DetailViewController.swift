//
//  DetailViewController.swift
//  Tennis
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation
import UIKit

private let DATE_FORMATTTER = DateFormatter.defaultDateFormat("dd/MM/yyyy")

class DetailViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var playerImage: UIImageView!
    @IBOutlet var currentRankingLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var reportMatchBarButton: UIBarButtonItem!
    @IBOutlet var matchTableView: UITableView!
    @IBOutlet var matchReport: UIToolbar!
    
    //Data from previous VC
    var player: Player!
    var matches = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViews()
        
        Endpoints.getMatches(player.ladderId, player.userId).response { (response: Response<[Match]>) in
            switch response {
            case .success(let matches):
                self.players = matches
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
        
        matches = [Match(
            matchId: 3,
            ladderId: 1,
            matchDate: Date(),
            winner: Player(userId: "abcdef", ladderId: 1, name: "Kobe Bryant", photoUrl: nil, score: 50, ranking: 5, wins: 30, losses: 20),
            loser: Player(userId: "abcdef", ladderId: 1, name: "Kobe Bryant", photoUrl: nil, score: 50, ranking: 5, wins: 30, losses: 20),
            winnerSet1Score: 40,
            loserSet1Score: 30,
            winnerSet2Score: 0,
            loserSet2Score: 40,
            winnerSet3Score: nil,
            loserSet3Score: nil)]
    }
    
    func loadViews() {
        playerImage = image
        currentRankingLabel.text = "# \(String(currentRanking))"
        scoreLabel.text = String("\(wins) - \(losses)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = matchTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        
        if let cell = cell as? DetailCell {
            let match = matches[indexPath.row]
            cell.matchLabel.text = "\(match.matchId)"
            cell.setScoresLabel.text = "\(match.winnerSet1Score)-\(match.loserSet1Score), \(match.winnerSet2Score)-\(match.loserSet2Score)"
        }
        
        return cell
    }
}
