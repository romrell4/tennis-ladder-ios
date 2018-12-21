//
//  HomeViewController.swift
//  Tennis
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation
import UIKit

private let DATE_FORMATTTER = DateFormatter.defaultDateFormat("dd/MM/yyyy")

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var ladders = [Ladder]()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        Endpoints.getLadders().response { (response: Response<[Ladder]>) in
            switch response {
            case .success(let ladders):
                self.ladders = ladders
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func tableView(_ trableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ladders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
        
        if let cell = cell as? CustomCell {
            let ladder = ladders[indexPath.row]
            cell.ladderText.text = ladder.name
            cell.dateRange.text = "\(DATE_FORMATTTER.string(from: ladder.startDate)) - \(DATE_FORMATTTER.string(from: ladder.endDate))"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "player", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedPath = sender as? IndexPath else {
            return
        }
        if segue.identifier == "player", let vc = segue.destination as? PlayerViewController {
            let selectedRow = selectedPath.row
            
            vc.ladderId = ladders[selectedRow].ladderId
        }
    }
}
