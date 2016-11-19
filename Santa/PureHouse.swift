//
//  pureHouse.swift
//  X-Mess
//
//  Created by Grigory Bochkarev on 19.11.16.
//  Copyright © 2016 Ilya Izmailov. All rights reserved.
//

import Foundation
import SpriteKit

class PureHouseNode {
    
    let utility = Utility()
    
    func addHouse(gameArea: CGRect, size: CGSize) -> SKSpriteNode {
        
        let randomXStart = utility.random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        let startPoint = CGPoint(x: randomXStart, y: size.height * 1.2)
        let endPoint = CGPoint(x: randomXStart, y: -size.height * 0.2)
        let ranHouseName = arc4random() % 8 + 1
        let house = SKSpriteNode(imageNamed: "house_\(ranHouseName)")
        let moveHouse = SKAction.moveTo(endPoint, duration: 3.7)
        let deleteHouse = SKAction.removeFromParent()
        let houseSequence = SKAction.sequence([moveHouse, deleteHouse])
        
        house.name = "Enemy"
        house.position = startPoint
        house.setScale(0.3)
        house.physicsBody = SKPhysicsBody(rectangleOfSize: house.size)
        house.physicsBody!.affectedByGravity = false
        house.physicsBody!.categoryBitMask = PhysicsCategories.None
        house.physicsBody!.collisionBitMask = PhysicsCategories.None
        house.physicsBody!.contactTestBitMask = PhysicsCategories.Gift
        house.zPosition = 0
        
        house.runAction(houseSequence)
        
        
        return house
    }
}
