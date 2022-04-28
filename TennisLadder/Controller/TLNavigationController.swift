//
//  TLNavigationViewController.swift
//  TennisLadder
//
//  Created by Eric Romrell on 4/28/22.
//  Copyright © 2022 Z Tai. All rights reserved.
//

import Foundation
import UIKit

class TLNavigationController : UINavigationController {
    override func viewDidLoad() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "Primary")
        appearance.shadowColor = UIColor.clear
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
}
