//
//  GiftNode.swift
//  Santa
//
//  Created by Grigory Bochkarev on 14.11.16.
//

import SpriteKit

class GiftNode {
    //TODO: make func addScore in GameScene with argument and call it if collision happened
    //TODO: add gift.png to assets
    //TODO: detect collision +- sevral pixels
    
    let giftSpeed : NSTimeInterval = 1 //define velocity
    //let giftBitMask : UInt32 = 0b1000 //define physics bitmask
    let distanceToFly : CGFloat = 500 //detect how many shoud gift fly
    
    
    func createGift(position: CGPoint) -> SKSpriteNode {
        let gift = SKSpriteNode(imageNamed: "gift")
        gift.name = "Gift"
        gift.setScale(1) //TODO: set scale
        gift.position = position
        gift.zPosition = 1
        gift.physicsBody = SKPhysicsBody(rectangleOfSize: gift.size)
        gift.physicsBody?.affectedByGravity = false
        gift.physicsBody?.categoryBitMask = PhysicsCategories.Gift
        gift.physicsBody?.contactTestBitMask = PhysicsCategories.House
        
        return gift //don't forget to self.addChild
    }
    
    func moveGift(positionY: CGFloat) -> SKAction {
        let moveGift =  SKAction.moveToY(positionY + distanceToFly, duration: giftSpeed)
        let deleteGift = SKAction.removeFromParent()
        let giftSequence = SKAction.sequence([moveGift,deleteGift]) //FIXME: add explosion
        return giftSequence //don't forget ro run action gift.runAction
    }
    
}
