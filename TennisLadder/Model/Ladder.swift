//
//  Models.swift
//  Tennis
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation

struct Ladder: Codable {
    let ladderId: Int
    let name: String
    let startDate: Date
    let endDate: Date
}
