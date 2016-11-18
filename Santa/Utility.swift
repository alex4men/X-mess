//
//  Utility.swift
//  Santa
//
//  Created by Grigory Bochkarev on 18.11.16.
//  Copyright © 2016 Ilya Izmailov. All rights reserved.
//

import Foundation
import SpriteKit

// Game states
enum gameState {
    case preGame
    case inGame
    case afterGame
}
// Declaring initial game state
var currentGameState = gameState.preGame

// Physics config
struct PhysicsCategories {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1 // 1
    static let Bullet: UInt32 = 0b10 // 2
    static let Enemy: UInt32 = 0b100 // 4
}

class Utility {
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }

}
