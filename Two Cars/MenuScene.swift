//
//  MenuScene.swift
//  Two Cars
//
//  Created by Aatish Rajkarnikar on 7/4/17.
//  Copyright © 2017 aatish. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuScene: SKScene {
    
    var restart: SKLabelNode!
    var home: SKLabelNode!
    var score: SKLabelNode!
    var bestScore: SKLabelNode!
    var playerScore: Int = 0
    
    override func didMove(to view: SKView) {
        restart = childNode(withName: "Restart") as! SKLabelNode
        home  = childNode(withName: "Home") as! SKLabelNode
        score = childNode(withName: "score") as! SKLabelNode
        bestScore = childNode(withName: "best") as! SKLabelNode
        
        score.text = "SCORE: \(playerScore)"
        bestScore.text = "BEST: " + String(UserDefaults.standard.integer(forKey: "HighScore"))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "Restart" {
                let gameScene = SKScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                view?.presentScene(gameScene)
            }else if atPoint(touchLocation).name == "Home" {
                let gameScene = SKScene(fileNamed: "HomeScene")
                gameScene?.scaleMode = .aspectFill
                view?.presentScene(gameScene)
            }
        }
    }
    
}
