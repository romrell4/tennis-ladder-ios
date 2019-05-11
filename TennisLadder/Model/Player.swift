//
//  Player.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation

struct Player: Codable, Equatable {
	let user: TLUser
	let ladderId: Int
	let score: Int
	let earnedPoints: Int
	let borrowedPoints: Int
    let ranking: Int
    let wins: Int
    let losses: Int
	
	static func ==(lhs: Player, rhs: Player) -> Bool {
		return lhs.user == rhs.user
	}
}
