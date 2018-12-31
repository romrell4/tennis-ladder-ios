//
//  Player.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation

struct Player: Codable, Equatable {
	let userId: String
	let ladderId: Int
    let name: String
	let photoUrl: String?
	let score: Int
    let ranking: Int
    let wins: Int
    let losses: Int
}
