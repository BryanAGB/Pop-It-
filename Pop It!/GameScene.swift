//
//  GameScene.swift
//  Pop It!
//
//  Created by Bryan on 08/03/2020.
//  Copyright © 2020 Bryan Mansell. All rights reserved.
//

import SpriteKit
import CoreMotion

class Ball : SKSpriteNode { }

class GameScene: SKScene {
    
    //var balls = ["bear","chicken","cow","monkey","penguin"]
    var balls = ["ballBlue", "ballGreen", "ballPurple", "ballRed", "ballYellow"]
    var motionManager : CMMotionManager?
    let scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    var matchedBalls = Set<Ball>()
    
    var score = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "Score: \(formattedScore)"
            
        }
    }
    override func didMove(to view: SKView) {

        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)

        scoreLabel.fontSize = 72
        scoreLabel.position = CGPoint(x: 20, y: 20)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        let ball = SKSpriteNode(imageNamed: "ballBlue")
        //ball.scale(to: CGSize(width: ball.frame.height/2, height: ball.size.width/2))
        let ballRadius = ball.frame.width / 2.0

        for i in stride(from: ballRadius, to: view.bounds.width - ballRadius, by: ball.frame.width) {
            for j in stride(from: 100, to: view.bounds.height - ballRadius, by: ball.frame.height) {
                let ballType = balls.randomElement()!
                let ball = Ball(imageNamed: ballType)
                ball.position = CGPoint(x: i, y: j)
                ball.zPosition = 0
                ball.name = ballType
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
                //ball.physicsBody = SKPhysicsBody(texture: ball.texture!,size: ball.texture!.size())
                ball.physicsBody?.allowsRotation = true
                ball.physicsBody?.friction = 0
                ball.physicsBody?.restitution = 0.3
               // ball.scale(to: CGSize(width: ball.frame.height/2, height: ball.size.width/2))
                addChild(ball)
            }
        }

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)))
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()

    }

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
    }
    
//    func getMatches(from node: Ball) {
//        for body in node.physicsBody!.allContactedBodies() {
//            guard let ball = body.node as? Ball else { continue }
//            guard ball.name == node.name else { continue }
//
//            if !matchedBalls.contains(ball) {
//                matchedBalls.insert(ball)
//                getMatches(from: ball)
//            }
//        }
//    }
    
    func getMatches(from startBall: Ball) {
        let matchWidth = startBall.frame.width * startBall.frame.width * 1.1
        
        for node in children {
            guard let ball = node as? Ball else { continue }
            guard ball.name == startBall.name else { continue }
            
            let dist = distance(from: startBall, to: ball)
            
            guard dist < matchWidth else { continue }
            
            if !matchedBalls.contains(ball) {
                matchedBalls.insert(ball)
                getMatches(from: ball)
            }
        }
        
    }
    
    func distance(from: Ball, to: Ball) -> CGFloat {
        return (from.position.x - to.position.x) * (from.position.x - to.position.x) + (from.position.y - to.position.y) * (from.position.y - to.position.y)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let position = touches.first?.location(in: self) else { return }
        guard let tappedBall = nodes(at: position).first(where: { $0 is Ball}) as? Ball
            else { return}
                
        matchedBalls.removeAll(keepingCapacity: true)
        getMatches(from: tappedBall)
        
        if matchedBalls.count >= 3 {
            for ball in matchedBalls {
                ball.removeFromParent()
            }
        }
    }
    
}
