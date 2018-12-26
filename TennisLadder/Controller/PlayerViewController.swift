//
//  DetailViewController.swift
//  Tennis
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation
import UIKit
import moa

private let DATE_FORMATTTER = DateFormatter.defaultDateFormat("dd/MM/yyyy")

class PlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Public Properties
    var player: Player!
    
    //MARK: Private Properties
    private var matches = [Match]()
    
    //MARK: Outlets
    @IBOutlet var playerImage: UIImageView!
    @IBOutlet var currentRankingLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var reportMatchBarButton: UIBarButtonItem!
    @IBOutlet var matchTableView: UITableView!
    @IBOutlet var matchReport: UIToolbar!
    
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
    
    func loadViews() {
        playerImage.moa.url = player.photoUrl
        currentRankingLabel.text = "# \(String(player.ranking))"
        scoreLabel.text = String("\(player.wins) - \(player.losses)")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playerSelected",
            let vc = segue.destination as? ReportMatchViewController {
            
            //TODO: Figure out player one and why this is not passing anything
            vc.playerTwo = player
            vc.playerOne = player
        }
    }
}
