import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        
        let backgroundMusic: SKAudioNode!
        let santaSpeech = SKAction.playSoundFileNamed("MainMenuVoice.mp3", waitForCompletion: false)
        let background = SKSpriteNode(imageNamed: "mainMenuBackground")
        let gameBy = SKLabelNode(text: "Innopolis University")
        let gameName = SKLabelNode(text: "X-MESS")
        let startGame = SKLabelNode(text: "Start Game")
        
        if let musicURL = NSBundle.mainBundle().URLForResource("MainMenuMusic", withExtension: "wav") {
            backgroundMusic = SKAudioNode(URL: musicURL)
            addChild(backgroundMusic)
        }
        
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        
        gameBy.fontColor = SKColor.whiteColor()
        gameBy.fontName = "SnowtopCaps"
        gameBy.fontSize = 80
        gameBy.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.8)
        gameBy.zPosition = 1
        
        gameName.fontColor = SKColor.whiteColor()
        gameName.fontName = "SnowtopCaps"
        gameName.fontSize = 225
        gameName.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameName.zPosition = 1
        
        startGame.fontColor = SKColor.whiteColor()
        startGame.fontName = "SnowtopCaps"
        startGame.fontSize = 150
        startGame.name = "startButton"
        startGame.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.2)
        startGame.zPosition = 1
        
        self.addChild(background)
        self.addChild(gameBy)
        self.addChild(gameName)
        self.addChild(startGame)
        
        self.runAction(santaSpeech)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.locationInNode(self)
            let nodeTapped = nodeAtPoint(pointOfTouch)
            
            if nodeTapped.name == "startButton" {
                
                let sceneToMoveTo = GameScene(size: self.size)
                let myTransition = SKTransition.fadeWithDuration(0.5)
                
                sceneToMoveTo.scaleMode = self.scaleMode
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                
            }
        }
    }
}
