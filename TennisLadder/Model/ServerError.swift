//
//  ServerError.swift
//  TennisLadder
//
//  Created by Eric Romrell on 1/8/19.
//  Copyright © 2019 Z Tai. All rights reserved.
//

import Foundation

struct ServerError: Error, Codable {
	let error: String?
}
