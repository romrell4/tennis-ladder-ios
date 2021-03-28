//
//  TLUser.swift
//  TennisLadder
//
//  Created by Eric Romrell on 1/13/19.
//  Copyright © 2019 Z Tai. All rights reserved.
//

import Foundation

struct TLUser: Codable, Equatable {
	let userId: String
	var name: String
	var email: String
	var phoneNumber: String?
	var photoUrl: String?
	var availabilityText: String?
    let admin: Bool
	
	static func ==(lhs: TLUser, rhs: TLUser) -> Bool {
		return lhs.userId == rhs.userId
	}
}
