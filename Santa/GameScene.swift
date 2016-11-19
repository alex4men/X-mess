import SpriteKit
import AVFoundation

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* VARS and CONFIGS */
    // Game vars
    let gameArea: CGRect
    var levelNumber = 0
    var livesNumber = 3
    var bossLifes = 10
    
    // Update vars
    var lastUpdateTime: NSTimeInterval = 0
    var deltaFrameTime: NSTimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    var backgroundMusic: SKAudioNode!
    
    let utility = Utility()
    let bullet = Bullet()
    let santaNode = Santa()
    var gameNodes : GameNodes!
    var santa : SKSpriteNode!
    
    /* OVERRIDING FUNCTIONS */
    
    // 1
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    // 2
    override func didMoveToView(view: SKView) {
        
        /* Setting up background music */
        if let musicURL = NSBundle.mainBundle().URLForResource("GameMusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(URL: musicURL)
            addChild(backgroundMusic)
        }
        
        /* Declaring initial game score */
        santa = santaNode.addSanta(size)
        gameNodes = GameNodes(size: size)
        gameScore = 0
    
        
        /* Configs */
        self.physicsWorld.contactDelegate = self
        
        /* Inserting objects to gameplay */
        self.addChild(gameNodes.background_top)
        self.addChild(gameNodes.background_bottom)
        self.addChild(santa)
        self.addChild(gameNodes.livesLabel)
        self.addChild(gameNodes.scoreLabel)
        self.addChild(gameNodes.tapToStartLabel)
        self.addChild(gameNodes.newLevelLabel)
        
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedUp(_:)))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentGameState == gameState.preGame {
            startGame()
        } else if currentGameState == gameState.inGame {
            self.runAction(SKAction.repeatActionForever(SKAction.sequence([gameNodes.bulletSound, SKAction.waitForDuration(0.35)])), withKey: "shooting")
            self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(fireBullet), SKAction.waitForDuration(0.35)])), withKey: "fireBullets")
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.locationInNode(self)
            let previousPointOfTouch = touch.previousLocationInNode(self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x // Moving Santa
            
            if currentGameState == gameState.inGame {
                santa.position.x += amountDragged
            }
            
            if santa.position.x > CGRectGetMaxX(gameArea) - santa.size.width / 2 {
                santa.position.x = CGRectGetMaxX(gameArea) - santa.size.width / 2
            }
            
            if santa.position.x < CGRectGetMinX(gameArea) + santa.size.width / 2 {
                santa.position.x = CGRectGetMinX(gameArea) + santa.size.width / 2
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentGameState == gameState.inGame {
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
    }
    
}

extension GameScene {
    
    //Swipe Up for throwing gift
    func swipedUp(sender:UISwipeGestureRecognizer){
        self.removeActionForKey("fireBullets")
        self.removeActionForKey("shooting")
        let giftNode = GiftNode()
        let gift = giftNode.createGift(santa.position)
        self.addChild(gift)
        gift.runAction(giftNode.moveGift(santa.position.y))
    }
    
    
    /* Self-written functions */
    func startGame() {
        /* Defining actions */
        let fadeOutAction = SKAction.fadeOutWithDuration(0.5)
        let deleteAction = SKAction.removeFromParent();
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        let moveShipOntoScreenAction = SKAction.moveToY(self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.runBlock(startNewLevel)
        let startGameSequence = SKAction.sequence([gameNodes.startGameVoice, moveShipOntoScreenAction, startLevelAction])
        
        santaNode.startSantaAnimation()
        /* Changing game state */
        currentGameState = gameState.inGame
        
        /* Running */
        gameNodes.tapToStartLabel.runAction(deleteSequence)
        santa.runAction(startGameSequence)
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
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Boss {
            
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
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Boss && body2.node?.position.y < self.size.height {
            
            if body2.node != nil {
                if bossLifes > 0 {
                    bossLifes -= 1
                } else {
                    spawnExplosion(body2.node!.position)
                    body2.node?.removeFromParent()
                }
            }
            
            body1.node?.removeFromParent()
            
            addScore()
        }

    }
    
    func spawnExplosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion_1")
        
        var textures:[SKTexture] = []
        for i in 1...7 {
            textures.append(SKTexture(imageNamed: "explosion_\(i)"))
        }
        let animate = SKAction.animateWithTextures(textures, timePerFrame: 0.03)
        
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([gameNodes.explosionSound, animate, delete])

        explosion.position = spawnPosition
        explosion.setScale(8)
        explosion.zPosition = 3
        
        self.addChild(explosion)
        
        explosion.runAction(explosionSequence)
        
    }
    
    
    func runGameOver() {
        let changeSceneAction = SKAction.runBlock(changeScene)
        let waitToChangeScene = SKAction.waitForDuration(1)
        let changeSceneSequence = SKAction.sequence([gameNodes.loseGameVoice, waitToChangeScene, changeSceneAction])
        
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
            gameNodes.newLevelLabel.runAction(newLevelAnimation)
            //getALife()
        }
        
        if (levelNumber == 2) {
            self.spawnBoss()
            self.removeActionForKey("spawningEnemies")
        } else {
            self.runAction(spawnForever, withKey: "spawningEnemies")
        }
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
        print("should spawn BOSS")
        let startPoint = CGPoint(x: self.size.width / 2, y: self.size.height * 1.2)
        let endPoint1 = CGPoint(x: 0, y: self.size.height / 2)
        let endPoint2 = CGPoint(x: self.size.width, y: self.size.height / 2 + 300)
        let endPoint3 = CGPoint(x: self.santa.position.x, y: -self.size.height * 0.2)
        let boss = SKSpriteNode(imageNamed: "boss_1")
        let moveBoss1 = SKAction.moveTo(endPoint1, duration: 5)
        let moveBoss2 = SKAction.moveTo(endPoint2, duration: 5)
        let moveBoss3 = SKAction.moveTo(endPoint3, duration: 5)
        let deleteBoss = SKAction.removeFromParent()
        let bossSequence = SKAction.sequence([moveBoss1,moveBoss2,moveBoss3,deleteBoss])
        let dx = endPoint3.x - startPoint.x
        let dy = endPoint3.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        
        let bossAnimation: SKAction
        
        boss.name = "Boss"
        boss.position = startPoint
        boss.setScale(3)
        boss.physicsBody = SKPhysicsBody(rectangleOfSize: boss.size)
        boss.physicsBody!.affectedByGravity = false
        boss.physicsBody!.categoryBitMask = PhysicsCategories.Boss
        boss.physicsBody!.collisionBitMask = PhysicsCategories.None
        boss.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        boss.zPosition = 1
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
    
    func loseALife() {
        let scaleUp = SKAction.scaleTo(1.5, duration: 0.2)
        let scaleDown = SKAction.scaleTo(1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
        
        livesNumber -= 1
        gameNodes.livesLabel.text = "Lives: \(livesNumber)"
        
        gameNodes.livesLabel.runAction(scaleSequence)
        
        if livesNumber == 0 {
            runGameOver()
        } else {
            self.addChild(santa)
        }
    }
    
    //    func getALife() {
    //        let scaleUp = SKAction.scaleTo(1.5, duration: 0.2)
    //        let scaleDown = SKAction.scaleTo(1, duration: 0.2)
    //        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
    //
    //        livesNumber += 1
    //        livesLabel.text = "Lives: \(livesNumber)"
    //
    //        livesLabel.runAction(scaleSequence)
    //    }
    
    func addScore() {
        gameScore += 1
        gameNodes.scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 || gameScore % 100 == 0 {
            startNewLevel()
        }
    }
    
    func fireBullet(){
        self.addChild(bullet.fireBullet(santa.position))
    }
}
