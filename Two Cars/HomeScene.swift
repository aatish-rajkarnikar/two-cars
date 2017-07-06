//
//  HomeScene.swift
//  Two Cars
//
//  Created by Aatish Rajkarnikar on 7/6/17.
//  Copyright © 2017 aatish. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds

class HomeScene: SKScene {
    
    var startLabel: SKLabelNode!
    var bannerView: GADBannerView!
    var parentViewController: UIViewController{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return (appDelegate.window?.rootViewController)!
    }

    override func didMove(to view: SKView) {
        startLabel = childNode(withName: "start") as! SKLabelNode
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        
        var frame = bannerView.frame
        frame.origin.y = self.view!.frame.height - frame.height
        bannerView.frame = frame
        
        bannerView.adUnitID = "ca-app-pub-5492969470059595/1605692663"
        bannerView.rootViewController = parentViewController
        view.addSubview(bannerView)
        let request = GADRequest()
        //request.testDevices = ["30d37e84cbe7a1dc22a989559596b3b5"]
        bannerView.load(request)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "start" {
                let gameScene = SKScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                view?.presentScene(gameScene)
            }
        }
    }
}
