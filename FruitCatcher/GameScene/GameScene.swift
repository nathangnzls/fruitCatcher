//
//  GameScene.swift
//  FruitCatcher
//
//  Created by Nathan on 18/03/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import Alamofire
class GameScene: SKScene, SKPhysicsContactDelegate {
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var URL = "https://demo2350077.mockable.io/products"
    var gameTimer:Timer!
    public var possibleProducts = [String]()
    var livesArray : [SKSpriteNode]?
    let fruitCategory:UInt32 = 0x1 << 1
    let playerCategory:UInt32 = 0x1 << 0
    let motionManger = CMMotionManager()
    var model : ProductsModel?
    var xAcceleration:CGFloat = 0
    
    struct prod{
        var product_img_url: String?
        var product_name: String?
        var product_points: Int?
    }
    var products = [prod]()
    override func didMove(to view: SKView) {
        addLives()
        getProductsToDrop()
        player = SKSpriteNode(imageNamed: "basket-1")
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height / 2 + 20)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = fruitCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 80, y: self.frame.size.height - 60)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = UIColor.white
        score = 0
        self.addChild(scoreLabel)
        
    }
    
    @objc func addLives(){
        livesArray = [SKSpriteNode]()
        
        for lives in 1...3{
            let liveNode = SKSpriteNode(imageNamed: "shuttle")
            liveNode.position = CGPoint(x: self.frame.size.width - CGFloat(4 - lives)*liveNode.size.width, y: self.frame.size.height - 60)
            self.addChild(liveNode)
            livesArray?.append(liveNode)
        }
    }
    @objc func addFruit () {
        
        //let urlStr : URL = URL(string: possibleProducts[0])!
        do{
            possibleProducts = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleProducts) as! [String]
            let url = Foundation.URL(string: possibleProducts[0])
            let defaultUrl = Foundation.URL(string: "www.google.com")
            let data = try Data(contentsOf: url ?? defaultUrl!)
            let imgTexture = SKTexture(image: UIImage(data: data)!)
            let fruit = SKSpriteNode(texture: imgTexture)
            
            
            let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
            let position = CGFloat(randomAlienPosition.nextInt())
            fruit.position = CGPoint(x: position, y: self.frame.size.height + fruit.size.height)
            fruit.physicsBody = SKPhysicsBody(rectangleOf: fruit.size)
            fruit.physicsBody?.isDynamic = true
            fruit.physicsBody?.categoryBitMask = fruitCategory
            fruit.physicsBody?.contactTestBitMask = playerCategory
            fruit.physicsBody?.collisionBitMask = 0
            self.addChild(fruit)
            let animationDuration:TimeInterval = 6
            var actionArray = [SKAction]()
            actionArray.append(SKAction.move(to: CGPoint(x: position, y: -fruit.size.height), duration: animationDuration))
            actionArray.append(SKAction.run {
                if self.livesArray?.count ?? 0 > 0 {
                    let liveNode = self.livesArray?.first
                    liveNode?.removeFromParent()
                    self.livesArray?.removeFirst()
                    
                    if self.livesArray?.count == 0{
                        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                        let gameOver = SKScene(fileNamed: "GameOver") as! GameOver
                        gameOver.score = self.score
                        self.view?.presentScene(gameOver, transition: transition)
                    }
                }
            })
            actionArray.append(SKAction.removeFromParent())
            fruit.run(SKAction.sequence(actionArray))
        }catch{
            print(error)
        }
        
     
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & playerCategory) != 0 && (secondBody.categoryBitMask & fruitCategory) != 0 {
            torpedoDidCollideWithAlien(playerNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    
    func torpedoDidCollideWithAlien (playerNode:SKSpriteNode, alienNode:SKSpriteNode) {
//        let explosion = SKEmitterNode(fileNamed: "Explosion")!
//        explosion.position = alienNode.position
//        self.addChild(explosion)
//        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
       // torpedoNode.removeFromParent()
        self.run(SKAction.wait(forDuration: 0.25)) {
            alienNode.removeFromParent()
            //explosion.removeFromParent()
        }
        
        score += 5
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func getProductsToDrop(){
        
            let params:Parameters? = [:];
            request(URL , method: .get, parameters: params, encoding: URLEncoding.httpBody , headers: nil).responseJSON(completionHandler: {
                response in
                if(response.result.isSuccess){
                    let JSON = response.result.value as? [String: Any]
                    self.model = ProductsModel.init(json: JSON?["products"] as! [[String : Any]])
                    for item in JSON?["products"] as! [[String : Any]]{
                        self.products.append(prod(product_img_url: item["product_img_url"] as? String, product_name: item["product_name"] as? String, product_points: item["product_points"] as? Int))
                        self.possibleProducts.append(item["product_img_url"] as? String ?? "")
                    }
                    self.gameTimer = Timer.scheduledTimer(timeInterval: 0.45, target: self, selector: #selector(self.addFruit), userInfo: nil, repeats: true)
                    self.motionManger.accelerometerUpdateInterval = 0.2
                    self.motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
                        if let accelerometerData = data {
                            let acceleration = accelerometerData.acceleration
                            self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
                        }
                    }
                  
                }else if(response.result.isFailure){
                    print("IRUR")
                    
                }
            })
        
    }
}
