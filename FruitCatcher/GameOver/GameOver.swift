//
//  GameOver.swift
//  FruitCatcher
//
//  Created by Nathan on 18/03/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import UIKit
import GameplayKit
class GameOver: SKScene {
    var score:Int = 0
    var scoreLbl: SKLabelNode?
    var newGameBtn: SKSpriteNode?
    override func didMove(to view: SKView) {
        scoreLbl = self.childNode(withName: "lblScore") as? SKLabelNode
        scoreLbl?.text = "\(score)"
        newGameBtn = self.childNode(withName: "btnNewGame") as? SKSpriteNode
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "btnNewGame"{
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let menuScene = SKScene(fileNamed: "MenuScene") as! MenuScene
                self.view?.presentScene(menuScene, transition: transition)
            }
        }
    }
}
