//
//  Clouds.swift
//  Santa
//
//  Created by Alexander Fomenko on 19/11/2016.
//  Copyright © 2016 Ilya Izmailov. All rights reserved.
//

import Foundation
import SpriteKit

class Cloud {
    let utility = Utility()
    
//    func spawnCloud(){
//        let randomXStart = utility.random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
//        let randomXEnd = randomXStart
//        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
//        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
//        let randomSprite = utility.random(min: 1, max: 8)
//        let cloud = SKSpriteNode(imageNamed: "cloud_1")
//        let moveEnemy = SKAction.moveTo(endPoint, duration: 1.5)
//        // let enemyAnimation: SKAction
//        let deleteEnemy = SKAction.removeFromParent()
//        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
//        let dx = endPoint.x - startPoint.x
//        let dy = endPoint.y - startPoint.y
//        let amountToRotate = atan2(dy, dx)
//        
//        let enemyAnimation: SKAction
//        
//        enemy.name = "Enemy"
//        enemy.position = startPoint
//        enemy.setScale(3)
//        enemy.physicsBody = SKPhysicsBody(rectangleOfSize: enemy.size)
//        enemy.physicsBody!.affectedByGravity = false
//        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
//        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
//        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
//        enemy.zPosition = 2
//        enemy.zRotation = amountToRotate
//        
//        self.addChild(enemy)
//        
//        if currentGameState == gameState.inGame {
//            enemy.runAction(enemySequence)
//        }
//        
//        // 1
//        var textures:[SKTexture] = []
//        // 2
//        for i in 1...6 {
//            textures.append(SKTexture(imageNamed: "enemy_\(i)"))
//        }
//        // 3
//        textures.append(textures[2])
//        textures.append(textures[1])
//        
//        // 4
//        enemyAnimation = SKAction.animateWithTextures(textures,
//                                                      timePerFrame: 0.01)
//        
//        if enemy.actionForKey("animation") == nil {
//            enemy.runAction(
//                SKAction.repeatActionForever(enemyAnimation),
//                withKey: "animation")
//        }
//        
//    }

}
