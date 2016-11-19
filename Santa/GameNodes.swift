//
//  GameNodes.swift
//  Santa
//
//  Created by Grigory Bochkarev on 18.11.16.
//  Copyright © 2016 Ilya Izmailov. All rights reserved.
//

import Foundation
import SpriteKit

class GameNodes {
    // On-screen objects
    let scoreLabel = SKLabelNode(text: "Score: 0")
    let livesLabel = SKLabelNode(text: "Lives: 3")
    let tapToStartLabel = SKLabelNode(text: "Tap to start")
    let newLevelLabel = SKLabelNode(text: "NEW LEVEL!")
    
    /* Seamless backgrounds */
    let background_top = SKSpriteNode(imageNamed: "gameBackground2")
    let background_bottom = SKSpriteNode(imageNamed: "gameBackground1")
    
    // Sounds
    let startGameVoice = SKAction.playSoundFileNamed("StartGameVoice.mp3", waitForCompletion: false)
    let loseGameVoice = SKAction.playSoundFileNamed("LoseGameVoice.mp3", waitForCompletion: false)
    let bulletSound = SKAction.playSoundFileNamed("BulletSound.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("ExplosionSound.wav", waitForCompletion: false)
    
    init(size: CGSize) {
        
        /* Defining actions */
        let fadeInAction = SKAction.fadeInWithDuration(0.3)
        let moveOnToScreenAction = SKAction.moveToY(size.height * 0.9, duration: 0.3)
        
        background_top.anchorPoint = CGPoint(x: 0.5, y: 0)
        background_top.name = "Background"
        background_top.position = CGPoint(x: size.width / 2, y: size.height)
        background_top.size = size
        background_top.zPosition = -1
        
        background_bottom.anchorPoint = CGPoint(x: 0.5, y: 0)
        background_bottom.name = "Background"
        background_bottom.position = CGPoint(x: size.width / 2, y: 0)
        background_bottom.size = size
        background_bottom.zPosition = -1
        
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.fontName = "SnowtopCaps"
        scoreLabel.fontSize = 70
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.position = CGPoint(x: size.width * 0.15, y: size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        
        livesLabel.fontColor = SKColor.whiteColor()
        livesLabel.fontName = "SnowtopCaps"
        livesLabel.fontSize = 70
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        livesLabel.position = CGPoint(x: size.width * 0.85, y: size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        
        tapToStartLabel.alpha = 0
        tapToStartLabel.fontColor = SKColor.whiteColor()
        tapToStartLabel.fontName = "SnowtopCaps"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        tapToStartLabel.zPosition = 1
        
        newLevelLabel.alpha = 0
        newLevelLabel.fontColor = SKColor.whiteColor()
        newLevelLabel.fontName = "SnowtopCaps"
        newLevelLabel.fontSize = 100
        newLevelLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        newLevelLabel.zPosition = 1
        
        /* Running */
        scoreLabel.runAction(moveOnToScreenAction)
        livesLabel.runAction(moveOnToScreenAction)
        tapToStartLabel.runAction(fadeInAction)
        
    }
}
