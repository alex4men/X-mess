import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    let restartLabel = SKLabelNode(text: "Restart")
    
    override func didMoveToView(view: SKView) {
        let backgroundMusic: SKAudioNode!
        let defaults = NSUserDefaults()
        let background = SKSpriteNode(imageNamed: "gameBackground")
        let gameOverLabel = SKLabelNode(text: "Game over")
        let scoreLabel = SKLabelNode(text: "Score: \(gameScore)")
        let highScoreLabel = SKLabelNode()
        
        if let musicURL = NSBundle.mainBundle().URLForResource("MainMenuMusic", withExtension: "wav") {
            backgroundMusic = SKAudioNode(URL: musicURL)
            addChild(backgroundMusic)
        }
        
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.size = self.size
        background.zPosition = 0
        
        gameOverLabel.fontColor = SKColor.whiteColor()
        gameOverLabel.fontName = "HelveticaNeue-Medium"
        gameOverLabel.fontSize = 200
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.fontName = "HelveticaNeue"
        scoreLabel.fontSize = 125
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        
        var highScoreNumber = defaults.integerForKey("highScoreSaved")
        
        if gameScore > highScoreNumber {
            highScoreNumber = gameScore
            defaults.setInteger(highScoreNumber, forKey: "highScoreSaved")
        }
        
        highScoreLabel.text = "High Score: \(highScoreNumber)"
        highScoreLabel.fontColor = SKColor.whiteColor()
        highScoreLabel.fontName = "HelveticaNeue"
        highScoreLabel.fontSize = 125
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
        highScoreLabel.zPosition = 1
        
        restartLabel.fontColor = SKColor.whiteColor()
        restartLabel.fontName = "HelveticaNeue-Medium"
        restartLabel.fontSize = 90
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        restartLabel.zPosition = 1
        
        self.addChild(background)
        self.addChild(gameOverLabel)
        self.addChild(scoreLabel)
        self.addChild(highScoreLabel)
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.locationInNode(self)
            
            if restartLabel.containsPoint(pointOfTouch) {
                let sceneToMoveTo = GameScene(size: self.size)
                let myTransition = SKTransition.fadeWithDuration(0.5)
                
                sceneToMoveTo.scaleMode = self.scaleMode
                
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }
    }
}
