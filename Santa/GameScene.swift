import SpriteKit
import AVFoundation

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    /* VARS and CONFIGS */
        // Game vars
        let gameArea: CGRect
        var levelNumber = 0
        var livesNumber = 3
        
        // Update vars
        var lastUpdateTime: NSTimeInterval = 0
        var deltaFrameTime: NSTimeInterval = 0
        var amountToMovePerSecond: CGFloat = 600.0
        
        // On-screen objects
        let scoreLabel = SKLabelNode(text: "Score: 0")
        let livesLabel = SKLabelNode(text: "Lives: 3")
        let tapToStartLabel = SKLabelNode(text: "Tap to start")
        let newLevelLabel = SKLabelNode(text: "NEW LEVEL!")
        let player = SKSpriteNode(imageNamed: "santa_1")
        let playerAnimation: SKAction
    
        // Sounds
        var backgroundMusic: SKAudioNode!
        let startGameVoice = SKAction.playSoundFileNamed("StartGameVoice.mp3", waitForCompletion: false)
        let loseGameVoice = SKAction.playSoundFileNamed("LoseGameVoice.mp3", waitForCompletion: false)
        let bulletSound = SKAction.playSoundFileNamed("BulletSound.wav", waitForCompletion: false)
        let explosionSound = SKAction.playSoundFileNamed("ExplosionSound.wav", waitForCompletion: false)
    
    let utility = Utility()
    let bullet = Bullet()
    
    /* OVERRIDING FUNCTIONS */
        // 1
        override init(size: CGSize) {
            let maxAspectRatio: CGFloat = 16.0 / 9.0
            let playableWidth = size.height / maxAspectRatio
            let margin = (size.width - playableWidth) / 2
            
            gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
            
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
            
            
            super.init(size: size)
        }
            required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
        // 2
        override func didMoveToView(view: SKView) {
            
            /* Seamless backgrounds */
                let background_top = SKSpriteNode(imageNamed: "gameBackground")
                let background_bottom = SKSpriteNode(imageNamed: "gameBackground")
            
            /* Defining actions */
                let fadeInAction = SKAction.fadeInWithDuration(0.3)
                let moveOnToScreenAction = SKAction.moveToY(self.size.height * 0.9, duration: 0.3)
            
            /* Setting up background music */
                if let musicURL = NSBundle.mainBundle().URLForResource("GameMusic", withExtension: "mp3") {
                    backgroundMusic = SKAudioNode(URL: musicURL)
                    addChild(backgroundMusic)
                }
            
            /* Declaring initial game score */
                gameScore = 0
            
            /* Configs */
                self.physicsWorld.contactDelegate = self
                
                background_top.anchorPoint = CGPoint(x: 0.5, y: 0)
                background_top.name = "Background"
                background_top.position = CGPoint(x: self.size.width / 2, y: self.size.height)
                background_top.size = self.size
                background_top.zPosition = 0
                
                background_bottom.anchorPoint = CGPoint(x: 0.5, y: 0)
                background_bottom.name = "Background"
                background_bottom.position = CGPoint(x: self.size.width / 2, y: 0)
                background_bottom.size = self.size
                background_bottom.zPosition = 0
                
                player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
                player.physicsBody!.affectedByGravity = false
                player.physicsBody!.categoryBitMask = PhysicsCategories.Player
                player.physicsBody!.collisionBitMask = PhysicsCategories.None
                player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
                player.position = CGPoint(x: self.size.width / 2, y: 0 - player.size.height)
                player.setScale(3)
                player.zPosition = 2
            
                scoreLabel.fontColor = SKColor.whiteColor()
                scoreLabel.fontName = "HelveticaNeue"
                scoreLabel.fontSize = 70
                scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
                scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
                scoreLabel.zPosition = 100
            
                livesLabel.fontColor = SKColor.whiteColor()
                livesLabel.fontName = "HelveticaNeue"
                livesLabel.fontSize = 70
                livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
                livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height)
                livesLabel.zPosition = 100
            
                tapToStartLabel.alpha = 0
                tapToStartLabel.fontColor = SKColor.whiteColor()
                tapToStartLabel.fontName = "HelveticaNeue-Medium"
                tapToStartLabel.fontSize = 100
                tapToStartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
                tapToStartLabel.zPosition = 1
            
                newLevelLabel.alpha = 0
                newLevelLabel.fontColor = SKColor.whiteColor()
                newLevelLabel.fontName = "HelveticaNeue-Medium"
                newLevelLabel.fontSize = 100
                newLevelLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.7)
                newLevelLabel.zPosition = 1
            
            /* Inserting objects to gameplay */
                self.addChild(background_top)
                self.addChild(background_bottom)
                self.addChild(player)
                self.addChild(livesLabel)
                self.addChild(scoreLabel)
                self.addChild(tapToStartLabel)
                self.addChild(newLevelLabel)
            
            /* Running */
                scoreLabel.runAction(moveOnToScreenAction)
                livesLabel.runAction(moveOnToScreenAction)
                tapToStartLabel.runAction(fadeInAction)
            
            let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedUp(_:)))
            swipeUp.direction = .Up
            view.addGestureRecognizer(swipeUp)
            
        }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        
        //let gift = GiftNode.createGift(player.position)
       // let gift = GiftNode.createGift(player.position)
        self.removeActionForKey("fireBullets")
        self.removeActionForKey("shooting")
        let giftNode = GiftNode()
        let gift = giftNode.createGift(player.position)
        self.addChild(gift)
        gift.runAction(giftNode.moveGift(player.position.y))
    }
    
    func startSantaAnimation() {
        if player.actionForKey("animation") == nil {
            player.runAction(
                SKAction.repeatActionForever(playerAnimation),
                withKey: "animation")
        }
    }
    
        // 3
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            if currentGameState == gameState.preGame {
                startGame()
            } else if currentGameState == gameState.inGame {
                self.runAction(SKAction.repeatActionForever(SKAction.sequence([bulletSound, SKAction.waitForDuration(0.35)])), withKey: "shooting")
                self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(fireBullet), SKAction.waitForDuration(0.35)])), withKey: "fireBullets")
            }
        }
    
        // 4
        override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
            for touch: AnyObject in touches{
                let pointOfTouch = touch.locationInNode(self)
                let previousPointOfTouch = touch.previousLocationInNode(self)
                let amountDragged = pointOfTouch.x - previousPointOfTouch.x // Moving Santa
                
                if currentGameState == gameState.inGame {
                    player.position.x += amountDragged
                }
                
                if player.position.x > CGRectGetMaxX(gameArea) - player.size.width / 2 {
                    player.position.x = CGRectGetMaxX(gameArea) - player.size.width / 2
                }
                
                if player.position.x < CGRectGetMinX(gameArea) + player.size.width / 2 {
                    player.position.x = CGRectGetMinX(gameArea) + player.size.width / 2
                }
            }
        }
    
        // 5
        override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
            if currentGameState == gameState.inGame {
//                firingBullets = false
                self.removeActionForKey("fireBullets")
                self.removeActionForKey("shooting")
            }
        }
    
        // Frame updating function
        override func update(currentTime: NSTimeInterval) {
            let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
            
            if lastUpdateTime == 0 {
                lastUpdateTime = currentTime
            } else {
                deltaFrameTime = currentTime - lastUpdateTime
                lastUpdateTime = currentTime
            }
            
            self.enumerateChildNodesWithName("Background") {
                background, stop in
                
                if currentGameState == gameState.inGame {
                    background.position.y -= amountToMoveBackground
                }
                
                if background.position.y < -self.size.height {
                    background.position.y += self.size.height * 2
                }
            }
            
//            if firingBullets == true {
//                fireBullet()
//            }
        }
    
    /* Self-written functions */
        func startGame() {
            /* Defining actions */
                let fadeOutAction = SKAction.fadeOutWithDuration(0.5)
                let deleteAction = SKAction.removeFromParent();
                let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
                let moveShipOntoScreenAction = SKAction.moveToY(self.size.height * 0.2, duration: 0.5)
                let startLevelAction = SKAction.runBlock(startNewLevel)
                let startGameSequence = SKAction.sequence([startGameVoice, moveShipOntoScreenAction, startLevelAction])
            
            startSantaAnimation()
            /* Changing game state */
                currentGameState = gameState.inGame
            
            /* Running */
                tapToStartLabel.runAction(deleteSequence)
                player.runAction(startGameSequence)
        }
    
        func didBeginContact(contact: SKPhysicsContact) {
            var body1 = SKPhysicsBody()
            var body2 = SKPhysicsBody()
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                body1 = contact.bodyA
                body2 = contact.bodyB
            } else {
                body1 = contact.bodyB
                body2 = contact.bodyA
            }
            
            // Condition when the player has hit the enemy
            if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
                
                if body1.node != nil {
                    spawnExplosion(body1.node!.position)
                }
                
                if body2.node != nil {
                    spawnExplosion(body2.node!.position)
                }
                
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
                
                loseALife()
            }
            
            // Condition when the bullet has hit the enemy
            if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && body2.node?.position.y < self.size.height {
                
                if body2.node != nil {
                    spawnExplosion(body2.node!.position)
                }
                
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
                
                addScore()
            }
        }
    
        func spawnExplosion(spawnPosition: CGPoint) {
            let explosion = SKSpriteNode(imageNamed: "explosion_1")
            let scaleIn = SKAction.scaleTo(5, duration: 0.3)
            let fadeOut = SKAction.fadeOutWithDuration(0.3)
            let delete = SKAction.removeFromParent()
            let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
            
            let explosionAnimation: SKAction
            
            explosion.position = spawnPosition
            explosion.setScale(0)
            explosion.zPosition = 3
            
            self.addChild(explosion)
            
            explosion.runAction(explosionSequence)
            
            // 1
            var textures:[SKTexture] = []
            // 2
            for i in 1...7 {
                textures.append(SKTexture(imageNamed: "explosion_\(i)"))
            }
            // 3
            textures.append(textures[2])
            textures.append(textures[1])
            
            // 4
            explosionAnimation = SKAction.animateWithTextures(textures,
                                                          timePerFrame: 0.01)
            
            if explosion.actionForKey("animation") == nil {
                explosion.runAction(
                    SKAction.repeatActionForever(explosionAnimation),
                    withKey: "animation")
            }

        }

        func loseALife() {
            let scaleUp = SKAction.scaleTo(1.5, duration: 0.2)
            let scaleDown = SKAction.scaleTo(1, duration: 0.2)
            let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
            
            livesNumber -= 1
            livesLabel.text = "Lives: \(livesNumber)"
            
            livesLabel.runAction(scaleSequence)
            
            if livesNumber == 0 {
                runGameOver()
            } else {
                self.addChild(player)
            }
        }
    
        func getALife() {
            let scaleUp = SKAction.scaleTo(1.5, duration: 0.2)
            let scaleDown = SKAction.scaleTo(1, duration: 0.2)
            let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
            
            livesNumber += 1
            livesLabel.text = "Lives: \(livesNumber)"
            
            livesLabel.runAction(scaleSequence)
        }
    
        func addScore() {
            gameScore += 1
            scoreLabel.text = "Score: \(gameScore)"
            
            if gameScore == 10 || gameScore == 25 || gameScore == 50 || gameScore % 100 == 0 {
                startNewLevel()
            }
        }
        
        func runGameOver() {
            let changeSceneAction = SKAction.runBlock(changeScene)
            let waitToChangeScene = SKAction.waitForDuration(1)
            let changeSceneSequence = SKAction.sequence([loseGameVoice, waitToChangeScene, changeSceneAction])
            
            currentGameState = gameState.afterGame
            
            self.removeAllActions()
            
            self.enumerateChildNodesWithName("Bullet") {
                bullet, stop in
                bullet.removeAllActions()
            }
            
            self.enumerateChildNodesWithName("Enemy") {
                enemy, stop in
                enemy.removeAllActions()
            }
            
            
            self.runAction(changeSceneSequence)
        }
        
        func startNewLevel(){
            var levelDuration = NSTimeInterval()
            
            switch levelNumber {
                case 1: levelDuration = 1.2
                case 2: levelDuration = 1
                case 3: levelDuration = 0.8
                case 4: levelDuration = 0.5
                default: levelDuration = 0.5
                print("no level info")
            }
            
            let spawn = SKAction.runBlock(spawnEnemy)
            let waitToSpawn = SKAction.waitForDuration(levelDuration)
            let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
            let spawnForever = SKAction.repeatActionForever(spawnSequence)
            let fadeInAction = SKAction.fadeInWithDuration(0.1)
            let scaleUp = SKAction.scaleTo(1.5, duration: 0.2)
            let scaleDown = SKAction.scaleTo(1, duration: 0.2)
            let fadeOutAction = SKAction.fadeOutWithDuration(0.1)
            let newLevelAnimation = SKAction.sequence([fadeInAction, scaleUp, scaleDown, fadeOutAction])
            
            levelNumber += 1
            
            if self.actionForKey("spawningEnemies") != nil {
                self.removeActionForKey("spawningEnemies")
            }
            
            if levelNumber > 1 {
                newLevelLabel.runAction(newLevelAnimation)
                //getALife()
            }
            
            if (levelNumber > 2) {
                self.spawnBoss()
                self.removeActionForKey("spawningEnemies")
            }
            
            self.runAction(spawnForever, withKey: "spawningEnemies")
        }
    
        func changeScene() {
            let sceneToMoveTo = GameOverScene(size: self.size)
            let myTransition = SKTransition.fadeWithDuration(0.5)
            
            sceneToMoveTo.scaleMode = self.scaleMode
            
            self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        }
    
        func spawnEnemy(){
            let randomXStart = utility.random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
            let randomXEnd = utility.random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
            let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
            let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
            let enemy = SKSpriteNode(imageNamed: "enemy_1")
            let moveEnemy = SKAction.moveTo(endPoint, duration: 1.5)
            // let enemyAnimation: SKAction
            let deleteEnemy = SKAction.removeFromParent()
            let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
            let dx = endPoint.x - startPoint.x
            let dy = endPoint.y - startPoint.y
            let amountToRotate = atan2(dy, dx)
            
            let enemyAnimation: SKAction
            
            enemy.name = "Enemy"
            enemy.position = startPoint
            enemy.setScale(3)
            enemy.physicsBody = SKPhysicsBody(rectangleOfSize: enemy.size)
            enemy.physicsBody!.affectedByGravity = false
            enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
            enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
            enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
            enemy.zPosition = 2
            enemy.zRotation = amountToRotate
            
            self.addChild(enemy)
            
            if currentGameState == gameState.inGame {
                enemy.runAction(enemySequence)
            }
            
            // 1
            var textures:[SKTexture] = []
            // 2
            for i in 1...6 {
                textures.append(SKTexture(imageNamed: "enemy_\(i)"))
            }
            // 3
            textures.append(textures[2])
            textures.append(textures[1])
            
            // 4
            enemyAnimation = SKAction.animateWithTextures(textures,
                                                         timePerFrame: 0.01)
            
            if enemy.actionForKey("animation") == nil {
                enemy.runAction(
                    SKAction.repeatActionForever(enemyAnimation),
                    withKey: "animation")
            }
            
        }
    
    func spawnBoss(){
        let startPoint = CGPoint(x: self.size.width / 2, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: self.player.position.x, y: -self.size.height * 0.2)
        let boss = SKSpriteNode(imageNamed: "boss_1")
        let moveBoss = SKAction.moveTo(endPoint, duration: 0.01)
        let deleteBoss = SKAction.removeFromParent()
        let bossSequence = SKAction.sequence([moveBoss, deleteBoss])
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        
        let bossAnimation: SKAction
        
        boss.name = "Boss"
        boss.position = startPoint
        boss.setScale(3)
        boss.physicsBody = SKPhysicsBody(rectangleOfSize: boss.size)
        boss.physicsBody!.affectedByGravity = false
        boss.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        boss.physicsBody!.collisionBitMask = PhysicsCategories.None
        boss.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        boss.zPosition = 2
        boss.zRotation = amountToRotate
        
        self.addChild(boss)
        
        if currentGameState == gameState.inGame {
            boss.runAction(bossSequence)
        }
        
        // 1
        var textures:[SKTexture] = []
        // 2
        for i in 1...3 {
            textures.append(SKTexture(imageNamed: "boss_\(i)"))
        }
        // 3
        textures.append(textures[2])
        textures.append(textures[1])
        
        // 4
        bossAnimation = SKAction.animateWithTextures(textures,
                                                       timePerFrame: 0.01)
        
        if boss.actionForKey("animation") == nil {
            boss.runAction(
                SKAction.repeatActionForever(bossAnimation),
                withKey: "animation")
        }
        
    }
    
    func fireBullet(){
        self.addChild(bullet.fireBullet(player.position))
    }
}
