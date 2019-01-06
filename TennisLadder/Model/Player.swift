//
//  Player.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation

struct Player: Codable, Equatable {
	let user: PlayerUser
	let ladderId: Int
	let score: Int
    let ranking: Int
    let wins: Int
    let losses: Int
}

struct PlayerUser: Codable, Equatable {
	let userId: String
	let name: String
	let email: String
	let phoneNumber: String?
	let photoUrl: String?
}
