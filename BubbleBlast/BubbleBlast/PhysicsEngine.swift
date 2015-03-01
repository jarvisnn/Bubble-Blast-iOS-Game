//
//  PhysicsEngine.swift
//  GameEngine
//
//  Created by kunn on 2/12/15.
//  Copyright (c) 2015 Jarvis. All rights reserved.
//

import UIKit

/*
    This class simulates a real bubble world
*/
class PhysicsEngine {
    private let worldWidth: CGFloat
    private let worldHeight: CGFloat
    private let bubbleSize: CGFloat
    private let barrier: CGFloat
    private let radius: CGFloat
    private var bubbles: Dictionary<Int, BubbleModel>
    private var hittingBubble: BubbleModel?
    
    // init the bubble world
    init(worldWidth: CGFloat, worldHeight:CGFloat, bubbleSize: CGFloat, barrier: CGFloat) {
        self.bubbleSize = bubbleSize
        self.radius = bubbleSize / 2
        self.worldWidth = worldWidth
        self.worldHeight = worldHeight
        self.barrier = barrier
        self.bubbles = Dictionary<Int, BubbleModel>()
    }
    
    // add new bubble to the world
    func addBubble(bubble: BubbleModel) {
        if bubble.tag != nil {
            bubbles[bubble.tag!] = bubble
        }
    }
    
    // delete some bubbles from the world
    func deleteBubble(tags: Array<Int>) {
        for tag in tags {
            bubbles[tag] = nil
        }  
    }
    
    // remove bubbles that are outside the world
    func removeFalledBubbles() -> Array<Int> {
        var tags = Array<Int>()
        for (key, item) in bubbles {
            if item.coordinate.y > worldHeight {
                tags.append(item.tag!)
            }
        }
        deleteBubble(tags)
        return tags
    }
    
    func getBubbles() -> Array<BubbleModel> {
        var result = Array<BubbleModel> ()
        for (key, item) in bubbles {
            result.append(item)
        }
        return result
    }

    // move bubbles, update the scene.
    func update() -> Array<Int> {
        var tags = Array<Int>()
        for (key, bubble) in bubbles {
            if bubble.direction != CGVector.zeroVector && bubble.distance > 0 {
                if isMovingHorizontally(bubble) || isFalling(bubble) {
                    // if the bubble is a bullet/ it is falling -> do not consider the collision
                    moveBubble(bubble)
                    tags.append(bubble.tag!)
                } else if isColliding(bubble) {
                    // get collision
                    bubble.direction = CGVector.zeroVector
                    setHittingBubble(bubble)
                    tags.append(bubble.tag!)
                } else {
                    // move the bubble
                    checkHittingWall(bubble)
                    moveBubble(bubble)
                    tags.append(bubble.tag!)
                }
            } else if bubble.distance <= 0 {
                bubble.direction = CGVector.zeroVector
            }
        }
        return tags
    }

    private func isMovingHorizontally(bubble: BubbleModel) -> Bool {
        return bubble.direction.dy == 0 && bubble.direction.dx != 0
    }
    
    private func isFalling(bubble: BubbleModel) -> Bool {
        return bubble.direction.dy > 0
    }
    
    // check if the bubble get collision
    private func isColliding(bubble: BubbleModel) -> Bool {
        if bubble.coordinate.y <= radius {
            return true
        }
        for (key, item) in bubbles{
            if item.tag != bubble.tag && areCollided(bubble, bubble2: item) {
                // calculate the exact collision point.
                let newStartPoint = CGPoint(x: bubble.coordinate.x - bubble.direction.dx * 100, y: bubble.coordinate.y - bubble.direction.dy * 100)
                bubble.coordinate = calculateBubbleHittingLocation(newStartPoint, vt: bubble.direction, bubble: item)
                return true
            }
        }
        return false
    }
    
    // check if 2 bubbles are collided
    private func areCollided(bubble1: BubbleModel, bubble2: BubbleModel) -> Bool {
        var vec = CGVector(dx: bubble1.coordinate.x - bubble2.coordinate.x,
                           dy: bubble1.coordinate.y - bubble2.coordinate.y)
        return length(vec) < bubbleSize
    }
    
    // check if a bubble hit the wall
    private func checkHittingWall(bubble: BubbleModel) {
        if bubble.coordinate.x - radius <= 0 || bubble.coordinate.x + radius >= worldWidth {
            bubble.direction.dx = -bubble.direction.dx
        }
    }
    
    // move bubble according to its direction, velocity, etc.
    private func moveBubble(bubble: BubbleModel) {
        // Calculate the current velocity
        var moveLength = min(bubble.distance, bubble.acceleration/2+bubble.velocity)
        bubble.velocity += bubble.acceleration
        bubble.distance -= moveLength
        
        // next position
        let scale =  moveLength / length(bubble.direction)
        var newX = bubble.direction.dx * scale + bubble.coordinate.x
        var newY = bubble.direction.dy * scale + bubble.coordinate.y
        
        // make sure the bubble not get out of the world.
        newY = max(newY, radius)
        if newX < radius && newY <= worldHeight - bubbleSize {
            newX = radius
        }
        if newX > worldWidth - radius && newY <= worldHeight - bubbleSize {
            newX = worldWidth - radius
        }
        bubble.coordinate = CGPoint(x: newX, y: newY)
    }
    
    // set the hitting bubble to notify the GameEngine.
    func setHittingBubble(bubble: BubbleModel?) {
        hittingBubble = bubble
    }
    
    func getHittingBubble() -> BubbleModel? {
        return hittingBubble
    }
    
    // return the collision point.
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
    
    // help function
    private func distance(point1: CGPoint, point2: CGPoint) -> CGFloat{
        return length(CGVector(dx: point1.x-point2.x, dy: point1.y-point2.y))
    }
    
    // help function
    private func length(vector: CGVector) -> CGFloat {
        return sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    }
}