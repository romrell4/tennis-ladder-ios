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
	let name: String
	let email: String
	let phoneNumber: String?
	let photoUrl: String?
}
