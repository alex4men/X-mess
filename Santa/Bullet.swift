//
//  Bullet.swift
//  Santa
//
//  Created by Grigory Bochkarev on 18.11.16.
//  Copyright © 2016 Ilya Izmailov. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet {
    
    var bulletSpeed: NSTimeInterval = 2
    
    func fireBullet(position: CGPoint) -> SKSpriteNode {
        
        let bullet = SKSpriteNode(imageNamed: "bullet_1")
        let bulletAnimation: SKAction
        
        bullet.name = "Bullet"
        bullet.setScale(5)
        bullet.position = position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        //self.addChild(bullet)
        
        let moveBullet = SKAction.moveToY(2048 + bullet.size.height, duration: bulletSpeed)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])
        bullet.runAction(bulletSequence)
        
        // 1
        var textures:[SKTexture] = []
        // 2
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "bullet_\(i)"))
        }
        // 3
        textures.append(textures[2])
        textures.append(textures[1])
        
        // 4
        bulletAnimation = SKAction.animateWithTextures(textures,
                                                       timePerFrame: 0.3)
        
        if bullet.actionForKey("animation") == nil {
            bullet.runAction(
                SKAction.repeatActionForever(bulletAnimation),
                withKey: "animation")
        }
        
        return bullet
    }

}
