//
//  MenuScene.swift
//  FruitCatcher
//
//  Created by Nathan on 18/03/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import UIKit
import GameplayKit
class MenuScene: SKScene {

    var startGameBtn: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        startGameBtn = self.childNode(withName: "startGameBtn") as? SKSpriteNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "startGameBtn"{
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
    
    
}
