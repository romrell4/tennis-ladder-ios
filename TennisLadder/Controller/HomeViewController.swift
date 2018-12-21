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
    var cells = [Ladder]()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
		
//		Endpoints.getLadders().response { (response: Response<[Ladder]>) in
//			switch response {
//			case .success(let ladders):
//				self.cells = ladders
//				self.tableView.reloadData()
//			case .failure(let error):
//				print(error)
//			}
//		}
		
        cells = [Ladder(ladderId: 1, name: "Alex's Ladder", startDate: Date(), endDate: Date())]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "player", let vc = segue.destination as? PlayerViewController {
            //pass data
        }
    }
    
    func tableView(_ trableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
        
        if let cell = cell as? CustomCell {
            let ladder = cells[indexPath.row]
            cell.ladderText.text = ladder.name
            cell.dateRange.text = "\(DATE_FORMATTTER.string(from: ladder.startDate)) - \(DATE_FORMATTTER.string(from: ladder.endDate))"
        }
        
        return cell
    }
    
    
}
