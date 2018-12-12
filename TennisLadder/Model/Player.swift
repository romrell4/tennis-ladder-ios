//
//  Player.swift
//  Tennis
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation

struct Player {
    let name : String
    let ranking : Int
    let points : Int
    let wins : Int
    let losses : Int
}

struct Match {
    let pointsScored : Int
    let pointsGiven : Int
}
