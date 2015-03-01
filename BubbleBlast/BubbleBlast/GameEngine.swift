//
//  GameModel.swift
//  LevelDesigner
//
//  Created by kunn on 2/12/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
    GameEngine.
*/
class GameEngine {
    // Some constants.
    private let worldWidth: CGFloat
    private let worldHeight: CGFloat
    private let bubbleSize: CGFloat
    private let radius: CGFloat
    private let barrier: CGFloat
    
    private let physicsEngine: PhysicsEngine
    private let gameLogic: GameLogic
    
    private var bullet: BubbleModel?
    private var nextBullet: BubbleModel?
    
    private var key: Int = 0
    private var isFiring = false
    private var isGameOver = false

    init(worldWidth: CGFloat, worldHeight:CGFloat, bubbleSize: CGFloat, bubbles: Array<BubbleModel>) {
        self.worldWidth = worldWidth
        self.worldHeight = worldHeight
        self.bubbleSize = bubbleSize
        self.radius = bubbleSize / 2
        self.barrier = Constants.barrier
        
        self.physicsEngine = PhysicsEngine(worldWidth: worldWidth, worldHeight: worldHeight,
            bubbleSize: bubbleSize, barrier: self.barrier)
        self.gameLogic = GameLogic(worldWidth: worldWidth, worldHeight: worldHeight, bubbleSize: bubbleSize)
        
        setupBubbles(bubbles)
    }
    
    // set up bubbles for an empty game.
    private func setupBubbles(bubbles: Array<BubbleModel>) {
        for item in bubbles {
            item.tag = ++key
            physicsEngine.addBubble(item)
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.addBubbleMessage, object: item)
            gameLogic.addBubble(item, isBullet: false)
        }

        self.bullet = createNewBullet(worldWidth/2, y: worldHeight-bubbleSize/2)
        self.nextBullet = createNewBullet(bubbleSize/2, y: worldHeight-bubbleSize/2)
    }
    
    func reformat() {
        let tags = gameLogic.reformat()
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.removeBubbleMessage, object: tags)
        if tags.isEmpty == false {
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.bubbleBursting, object: nil)
        }
        physicsEngine.deleteBubble(tags)
        gameLogic.checkFalling()
        notifyUpdatingToController()
    }
    
    // making the new bullet
    private func createNewBullet(x: CGFloat, y: CGFloat) -> BubbleModel {
        var bullet = BubbleModel(coordinate: CGPoint(x: x, y: y), type: randomColor())
        bullet.tag = ++key
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.addBubbleMessage, object: bullet)
        physicsEngine.addBubble(bullet)
        return bullet
    }
    
    private func randomColor() -> String {
        let x = Int(rand()) % 4
        if x == 0 {
            return Constants.blueBubble
        } else if x == 1 {
            return Constants.redBubble
        } else if x == 2 {
            return Constants.greenBubble
        } else {
            return Constants.orangeBubble
        }
    }
    
    // return a list of current bubble datas
    func getCurrentBubble() -> Array<BubbleModel> {
        return physicsEngine.getBubbles()
    }
    
    func setGameOver() {
        isGameOver = true
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.gameOverMessage, object: nil)
    }
    
    // update the next scene
    func update() -> Array<Int> {
        // check the hitting bubble.
        if let bubble = physicsEngine.getHittingBubble() {
            physicsEngine.setHittingBubble(nil)
            let tags = gameLogic.addBubble(bubble, isBullet: true)
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.removeBubbleMessage, object: tags)
            if tags.isEmpty == false {
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.bubbleBursting, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.bubbleHitting, object: nil)
            }
            physicsEngine.deleteBubble(tags)
            gameLogic.checkFalling()
        }
        let result = physicsEngine.update()
        if let bubble = physicsEngine.getHittingBubble() {
            gameLogic.reposition(bubble)
        }
        
        // update done. Notify the controller.
        if result.isEmpty {
            notifyStopUpdatingToController()
            let tags = physicsEngine.removeFalledBubbles()
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.removeBubbleMessage, object: tags)
        }
        return result
    }

    // check if can fire to destination
    func canFire(destination: CGPoint) -> Bool {
        return (isGameOver || destination.y > barrier + Constants.radius || isFiring) == false
    }
    
    // fire a bubble, add the new bubble for the next firing
    func fire(destination: CGPoint) -> Array<BubbleModel> {
        if canFire(destination) == false {
            return Array<BubbleModel>()
        }
        
        // set attributes to fire the bubble (bullet)
        bullet!.direction = CGVector(dx: destination.x-bullet!.coordinate.x,
            dy: destination.y-bullet!.coordinate.y)
        bullet!.distance = worldHeight * worldWidth
        bullet!.velocity = Constants.velocity
        
        // move the next bullet to the fire position (the canon later).
        nextBullet!.direction = CGVector(dx: Constants.velocity, dy: 0)
        nextBullet!.velocity = Constants.velocity
        nextBullet!.distance = (worldWidth - bubbleSize) / 2
        
        // make a new bullet.
        bullet = nextBullet
        nextBullet = getNewBullet()
        
        notifyUpdatingToController()
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.cannonFiring, object: nil)
        return [nextBullet!]
    }
    
    // create a random new bubblet and make it move
    private func getNewBullet() -> BubbleModel {
        var bubble = BubbleModel(coordinate: CGPoint(x: -bubbleSize/2, y: worldHeight-bubbleSize/2),
            type: randomColor())
        bubble.direction = CGVector(dx: Constants.velocity, dy: 0)
        bubble.distance = bubbleSize
        bubble.velocity = Constants.velocity
        bubble.tag = ++key
        
        physicsEngine.addBubble(bubble)
        return bubble
    }
    
    
    func getBullet() -> BubbleModel? {
        return bullet?
    }
    
    // get the Path for the lasers.
    func getLaserPath(u: CGPoint, vt: CGVector) -> Array<CGPoint> {
        
        let v = CGPoint(x: u.x+vt.dx, y: u.y+vt.dy)
        let bubblesInGrid = gameLogic.getBubbles()
        let grid = gameLogic.getGrid()
        var wallHitPoint = calculateWallHittingLocation(u, vt: vt)
        var bubbleHitPoint = calculateBubbleHittingLocation(u, vt: vt, bubble: nil)
        
        // find the bubble that collides with the laser
        for (var i = Constants.numberOfCollectionCells - 1; i >= 0; i--) {
            if (bubblesInGrid[i] != nil && distanceFromPoint(grid[i], toLineSegment: u, and: v) <= Constants.bubbleSize) {
                let point = calculateBubbleHittingLocation(u, vt:vt, bubble: bubblesInGrid[i]!)
                if point.y > bubbleHitPoint.y {
                    bubbleHitPoint = point
                }
            }
        }
        
        var result = Array<CGPoint>()
        
        if wallHitPoint == nil || bubbleHitPoint.y >= wallHitPoint!.y {
            // laser hitted bubble or top wall.
            let point = bubbleHitPoint
            result = [u, point]
            for var i = 0; i < grid.count ; i++ {
                if (bubblesInGrid[i] == nil
                        && grid[i].x-radius <= point.x && point.x <= grid[i].x+radius
                        && grid[i].y-radius <= point.y && point.y <= grid[i].y+radius) {
                    result.append(grid[i])
                    break
                }
            }
        } else {
            // laser hitted side walls
            let list = getLaserPath(wallHitPoint!, vt: CGVector(dx: -vt.dx, dy: vt.dy))
            result = [u]
            for point in list {
                result.append(point)
            }
        }
        
        return result
    }
    
    // calculate the exact collision point with bubble / top wall
    private func calculateWallHittingLocation(u: CGPoint, vt: CGVector) -> CGPoint? {
        if vt.dx == 0 {
            return nil
        } else if vt.dx < 0 {
            let angle = atan2(-vt.dy, -vt.dx)
            let distance = (u.x - radius) / cos(angle)
            let result = endPoint(u, vt: vt, leng: distance)
            return result.y > radius ? result : nil
        } else {
            let angle = atan2(-vt.dy, vt.dx)
            let distance = (worldWidth - u.x - radius) / cos(angle)
            let result = endPoint(u, vt: vt, leng: distance)
            return result.y > radius ? result : nil
        }
    }

    // calculate the exact collision point with side walls
    private func calculateBubbleHittingLocation(u: CGPoint, vt: CGVector, bubble: BubbleModel?) -> CGPoint {
        if bubble == nil {
            var leng: CGFloat
            if vt.dx == 0 {
                leng = u.y - radius
            } else {
                let angle = atan2(abs(vt.dx), -vt.dy)
                leng = (u.y - radius) / cos(angle)
            }
            return endPoint(u, vt: vt, leng: leng)
        }
        let v = CGPoint(x: u.x+vt.dx, y: u.y+vt.dy)
        let lengToLine = distanceFromPoint(bubble!.coordinate, toLineSegment: u, and: v)
        let dis = distance(u, point2: bubble!.coordinate)
        let totalLeng = sqrt(dis * dis - lengToLine * lengToLine)
        let leng1 = sqrt(bubbleSize * bubbleSize - lengToLine * lengToLine)
        let leng = totalLeng - leng1;
        return endPoint(u, vt: vt, leng: leng)
    }
    
    private func endPoint(u: CGPoint, vt: CGVector, leng: CGFloat) -> CGPoint{
        let vecLeng = length(vt)
        return CGPoint(x: u.x+vt.dx/vecLeng*leng, y: u.y+vt.dy/vecLeng*leng)
    }
    
    // help function, calculate distance from point p to line vw
    private func distanceFromPoint(p: CGPoint, toLineSegment v: CGPoint, and w: CGPoint) -> CGFloat {
        let a = v.y-w.y
        let b = w.x-v.x
        let c = (v.x-w.x)*v.y + (w.y-v.y)*v.x
        return abs(a*p.x + b*p.y + c) / sqrt(a*a + b*b)
    }
    
    // notification setup
    private func notifyUpdatingToController() {
        isFiring = true
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.updateBubbleMesseage, object: nil)
    }
    
    // notification setup
    private func notifyStopUpdatingToController() {
        isFiring = false
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.stopUpdateBubbleMessage, object: nil)
    }

    // help function
    private func distance(point1: CGPoint, point2: CGPoint) -> CGFloat{
        return length(CGVector(dx: point1.x-point2.x, dy: point1.y-point2.y))
    }
    
    // help function
    private func length(vector: CGVector) -> CGFloat {
        return sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    }
}