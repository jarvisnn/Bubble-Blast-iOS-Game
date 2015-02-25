//
//  PhysicsEngine.swift
//  GameEngine
//
//  Created by kunn on 2/12/15.
//  Copyright (c) 2015 Jarvis. All rights reserved.
//

import UIKit

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
    
    // This func is for only testing. It has been used in other class.
    func getBubbles() -> Array<Int> {
        var result = Array<Int>()
        for (key, bubble) in bubbles {
            result.append(bubble.tag!)
        }
        result.sort{$0 < $1}
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
        if newX < radius && newY <= barrier + radius {
            newX = radius
        }
        if newX > worldWidth - radius && newY <= barrier + radius {
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
    
    // help function
    private func length(vector: CGVector) -> CGFloat {
        return sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    }
}