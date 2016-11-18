//
//  Santa.swift
//  Santa
//
//  Created by Grigory Bochkarev on 18.11.16.
//  Copyright © 2016 Ilya Izmailov. All rights reserved.
//

import Foundation
import SpriteKit

class Santa  {
    let player = SKSpriteNode(imageNamed: "santa_1")
    let playerAnimation: SKAction
    
    init() {
        //1
        var textures:[SKTexture] = []
        // 2
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "santa_\(i)"))
        }
        // 3
        textures.append(textures[2])
        textures.append(textures[1])
        
        // 4
        playerAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
    }
    
    func addSanta(size: CGSize)  -> SKSpriteNode {
        
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        player.position = CGPoint(x: size.width / 2, y: 0 - player.size.height)
        player.setScale(3)
        player.zPosition = 2
        
        return player
    }
    
    func startSantaAnimation() {
        if player.actionForKey("animation") == nil {
            player.runAction(
                SKAction.repeatActionForever(playerAnimation),
                withKey: "animation")
        }
    }
}
