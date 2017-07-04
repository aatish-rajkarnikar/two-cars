//
//  GameScene.swift
//  Two Cars
//
//  Created by Aatish Rajkarnikar on 7/3/17.
//  Copyright © 2017 aatish. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds

struct PhysicCategory{
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1
    static let other: UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var parentViewController: UIViewController{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return (appDelegate.window?.rootViewController)!
    }
    
    var leftCar: SKSpriteNode!
    var rightCar: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var moveLeftCarToRight = false
    var moveRightCarToLeft = false
    
    var play = true
    var score = 0{
        didSet{
            if score%10 == 0 {
                roadStripTimeInterval -= 0.05
                roadItemTimeInterval -= 0.05
                scoreTimeInterval -= 0.05
                roadStripSpaceTravel += 2
                roadItemSpaceTravel += 2
                stopTimers()
                startTimers()
            }
        }
    }
    
    
    var roadStripTimer: Timer?
    var roadItemTimer: Timer?
    var scoreTimer: Timer?
    
    var roadStripTimeInterval = 0.3
    var roadItemTimeInterval = 0.8
    var scoreTimeInterval = 1.0
    
    var roadStripSpaceTravel = 30.0
    var roadItemSpaceTravel = 15.0
    
    override func didMove(to view: SKView) {
        bannerView = GADBannerView(adSize: kGADAdSizeFullBanner)
        
        var frame = bannerView.frame
        frame.origin.y = self.view!.frame.height - frame.height
        bannerView.frame = frame
        
        bannerView.adUnitID = "ca-app-pub-5492969470059595/1605692663"
        bannerView.rootViewController = parentViewController
        view.addSubview(bannerView)
        let request = GADRequest()
        request.testDevices = ["30d37e84cbe7a1dc22a989559596b3b5"]
        bannerView.load(request)
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-5492969470059595/5198287462")
        interstitial.load(request)
        
        physicsWorld.contactDelegate = self
        
        leftCar = childNode(withName: "LeftCar") as! SKSpriteNode
        rightCar = childNode(withName: "RightCar") as! SKSpriteNode
        scoreLabel = childNode(withName: "score") as! SKLabelNode
        
        leftCar.physicsBody = SKPhysicsBody(rectangleOf: leftCar.size)
        leftCar.physicsBody?.categoryBitMask = PhysicCategory.player
        leftCar.physicsBody?.contactTestBitMask = PhysicCategory.other
        leftCar.physicsBody?.collisionBitMask = PhysicCategory.none
        
        rightCar.physicsBody = SKPhysicsBody(rectangleOf: rightCar.size)
        rightCar.physicsBody?.categoryBitMask = PhysicCategory.player
        rightCar.physicsBody?.contactTestBitMask = PhysicCategory.other
        rightCar.physicsBody?.collisionBitMask = PhysicCategory.none
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)

        startTimers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.stopTimers), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.startTimers), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if touchLocation.x > 0 {
                moveRightCarToLeft = !moveRightCarToLeft
            }else {
                moveLeftCarToRight = !moveLeftCarToRight
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if play {
            showRoadStrip()
            moveLeftCar()
            moveRightCar()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("collision")
        play = false
        saveHighscore()
        stopGame()
        if interstitial.isReady {
            interstitial.present(fromRootViewController: parentViewController)
        }
    }
    
    func createRoadStrip(){
        let height = self.frame.size.height
        let width = self.frame.size.width
        
        let rightRoadStrip = SKSpriteNode(color: UIColor.white, size: CGSize(width: 10, height: 60))
        rightRoadStrip.name = "RoadStrip"
        rightRoadStrip.zPosition = 10
        rightRoadStrip.position.x = width/4
        rightRoadStrip.position.y = height/2
        addChild(rightRoadStrip)
        
        let leftRoadStrip = SKSpriteNode(color: UIColor.white, size: CGSize(width: 10, height: 60))
        leftRoadStrip.name = "RoadStrip"
        leftRoadStrip.zPosition = 10
        leftRoadStrip.position.x = -width/4
        leftRoadStrip.position.y = height/2
        addChild(leftRoadStrip)
    }
    
    func populateRoad(){
        createRoadItem(side: 0)
        createRoadItem(side: 1)
    }
    
    func createRoadItem(side:Int){
        let height = self.frame.size.height
        let width = self.frame.size.width
        
        let car = arc4random_uniform(3)
        var carName:String
        switch car {
        case 0:
            carName = "RedCar"
        case 1:
            carName = "YellowCar"
        case 2:
            carName = "BlueCar"
        case 3:
            carName = "GreenCar"
        default:
            carName = "RedCar"
        }
        
        let position = arc4random_uniform(2)
        let item = SKSpriteNode(imageNamed: carName)
        item.name = "RoadItem"
        item.physicsBody = SKPhysicsBody(rectangleOf: item.size)
        item.physicsBody?.categoryBitMask = PhysicCategory.other
        item.physicsBody?.collisionBitMask = PhysicCategory.none
        item.position.y = height/2 + item.size.height + CGFloat(arc4random_uniform(100))
        let xPosition = position == 0 ? width/8 : 3 * width/8
        item.position.x  = side == 0 ? xPosition : -xPosition
        addChild(item)
        
    }
    
    func showRoadStrip(){
        enumerateChildNodes(withName: "RoadStrip") { (rightRoadStrip, stop) in
            rightRoadStrip.position.y -= CGFloat(self.roadStripSpaceTravel)
        }
        
        enumerateChildNodes(withName: "RoadItem") { (item, stop) in
            item.position.y -= CGFloat(self.roadItemSpaceTravel)
        }
    }
    
    func stopGame(){
        let menuScene = SKScene(fileNamed: "MenuScene")! as! MenuScene
        menuScene.playerScore = score
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene)
    }
    
    func removeItems(){
        for child in children{
            if child.position.y < -self.frame.size.height/2{
                child.removeFromParent()
            }
        }
    }
    
    func moveLeftCar(){
        let width = self.frame.size.width/4
        if moveLeftCarToRight {
            if leftCar.position.x < -width/2 {
                leftCar.position.x += 20
            }
        }else{
            if leftCar.position.x > -(width + width/2) {
                leftCar.position.x -= 20
            }
        }
    }
    
    func moveRightCar(){
        let width = self.frame.size.width/4
        if moveRightCarToLeft {
            if rightCar.position.x > width/2 {
                rightCar.position.x -= 20
            }
        }else{
            if rightCar.position.x < (width + width/2) {
                rightCar.position.x += 20
            }
        }
    }
    
    func increaseScore(){
        if play {
            score += 1
            scoreLabel.text = String(score)
        }
    }
    
    func startTimers(){
        roadStripTimer = Timer.scheduledTimer(timeInterval: roadStripTimeInterval, target: self, selector: #selector(GameScene.createRoadStrip), userInfo: nil, repeats: true)
        roadItemTimer = Timer.scheduledTimer(timeInterval: roadItemTimeInterval, target: self, selector: #selector(GameScene.populateRoad), userInfo: nil, repeats: true)
        scoreTimer = Timer.scheduledTimer(timeInterval: scoreTimeInterval, target: self, selector: #selector(GameScene.increaseScore), userInfo: nil, repeats: true)
    }
    
    func stopTimers(){
        roadStripTimer?.invalidate()
        roadItemTimer?.invalidate()
        scoreTimer?.invalidate()
    }
    
    func saveHighscore(){
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
    }
}
