//
//  GameModel.swift
//  LevelDesigner
//
//  Created by kunn on 2/12/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
    GameEngine. Currently this class contains all the game logic.
*/
class GameEngine {
    // Some constants.
    private let worldWidth: CGFloat
    private let worldHeight: CGFloat
    private let bubbleSize: CGFloat
    private let radius: CGFloat
    private let barrier: CGFloat
    
    // Constants for velocity and accelaration
    private let velocity = CGFloat(10)
    private let accelaration = CGFloat(0.5)
    
    private let physicsEngine: PhysicsEngine
    private let gameLogic: GameLogic
    
    private var bullet: BubbleModel?
    private var nextBullet: BubbleModel?
    
    private var bubbles = Dictionary<Int, BubbleModel>()
    private var bubblesInGrid = Array<BubbleModel?>(count: Constants.numberOfCollectionCells, repeatedValue: nil)
    private var grid = Array<CGPoint>()
    private var graph = Array<Array<Int>> ()
    
    private var key: Int = 0
    private var isFiring = false
    private var isGameOver = false

    init(worldWidth: CGFloat, worldHeight:CGFloat, bubbleSize: CGFloat, bubbles: Array<BubbleModel>) {
        self.worldWidth = worldWidth
        self.worldHeight = worldHeight
        self.bubbleSize = bubbleSize
        self.radius = bubbleSize / 2
        self.barrier = worldHeight * 4 / 5
        
        self.physicsEngine = PhysicsEngine(worldWidth: worldWidth, worldHeight: worldHeight,
            bubbleSize: bubbleSize, barrier: self.barrier)
        self.gameLogic = GameLogic()
        
        setupGrid()
        setupGraph()
        setupBubbles(bubbles)
    }
    
    // calculate the coordinates of each cell in the grid.
    private func setupGrid() {
        var currentX: CGFloat = radius, currentY: CGFloat = radius;

        for (var j = 0; j < Constants.numberOfCollectionCells; j++) {
            grid.append(CGPoint(x: currentX, y: currentY))
            currentX += bubbleSize
            if currentX >= worldWidth - radius * 0.5 {
                currentY += radius * sqrt(3)
                currentX = currentX > worldWidth + radius * 0.5 ? bubbleSize : radius
            }
        }
    }
    
    // from the grid, store it as a graph.
    private func setupGraph() {
        for var i = 0; i < Constants.numberOfCollectionCells; i++ {
            graph.append(Array<Int>())
            for var j = 0; j < Constants.numberOfCollectionCells; j++ {
                if i != j && distance(grid[i], point2: grid[j]) < bubbleSize * 1.5 {
                    graph[i].append(j)
                }
            }
        }
    }
    
    // set up bubbles for an empty game.
    private func setupBubbles(bubbles: Array<BubbleModel>) {
        for item in bubbles {
            item.tag = ++key
            self.bubbles[key] = item
            physicsEngine.addBubble(item)
            reposition(item)
        }

        self.bullet = BubbleModel(coordinate: CGPoint(x: worldWidth/2, y: worldHeight-bubbleSize/2),
            type: randomColor())
        self.bullet!.tag = ++key
        self.bubbles[key] = self.bullet
        physicsEngine.addBubble(bullet!)
        
        self.nextBullet = BubbleModel(coordinate: CGPoint(x: bubbleSize/2, y: worldHeight-bubbleSize/2),
            type: randomColor())
        self.nextBullet!.tag = ++key
        self.bubbles[key] = self.nextBullet
        physicsEngine.addBubble(nextBullet!)
    }
    
    func reformatGame() {
        var removedTags = Array<Int>()
        for (index, item) in bubbles {
            let tags = checkRemoving(item)
            for tag in tags {
                removedTags.append(tag)
            }
        }
        remove(removedTags)
        notifyUpdatingToController()
    }
    
    // Random a color.
    private func randomColor() -> String {
        let x = Int(rand()) % Constants.numberOfBubbles
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
        var result = Array<BubbleModel>()
        for (key, bubble) in bubbles {
            result.append(bubble)
        }
        return result
    }
    
    // update the next scene
    func update() -> Array<Int> {
        // check the hitting bubble.
        if let bubble = physicsEngine.getHittingBubble() {
            physicsEngine.setHittingBubble(nil)
            if bubble.coordinate.y >= barrier {
                // if the bubble get over the barrier, game over
                isGameOver = true
            } else {
                // check if there is a group of same bubbles that is connected and remove it
                remove(checkRemoving(bubble))
            }
        }
        let result = physicsEngine.update()
        if let bubble = physicsEngine.getHittingBubble() {
            reposition(bubble)
        }
        
        // update done. Notify the controller.
        if result.isEmpty {
            notifyStopUpdatingToController()
            removeFalledBubbles()
        }
        return result
    }
    
    // Reposition a bubble, snap it to the grid's cells
    private func reposition(bubble: BubbleModel) {
        for var i = 0; i < grid.count; i++ {
            if (grid[i].x-radius <= bubble.coordinate.x && bubble.coordinate.x <= grid[i].x+radius
                    && grid[i].y-radius <= bubble.coordinate.y && bubble.coordinate.y <= grid[i].y+radius) {
                bubble.coordinate = grid[i]
                bubblesInGrid[i] = bubble
                break
            }
        }
    }
    
    // This function is to check if there is a group of > 3 bubbles that are connected and have the same color
    // and remove it.
    private func checkRemoving(bubble: BubbleModel) -> Array<Int> {
        var queue = Queue<Int>()
        var isVisited = Dictionary<Int, Bool>()
        var visitedBubbles = Array<Int>()
        
        for var i = 0; i < Constants.numberOfCollectionCells; i++ {
            if bubble.coordinate == grid[i] && bubblesInGrid[i] != nil {
                queue.enqueue(i)
                isVisited[i] = true
            }
        }
        
        // BFS using queue
        while queue.isEmpty == false {
            let u = queue.dequeue()!
            visitedBubbles.append(u)
            
            for v in graph[u] {
                if isVisited[v] == nil && bubblesInGrid[v] != nil && bubblesInGrid[u]!.type == bubblesInGrid[v]!.type {
                    queue.enqueue(v)
                    isVisited[v] = true
                }
            }
        }
        
        var removedTags = Array<Int>()
        if visitedBubbles.count >= 3 {
            // if there is a such group, delete bubbles and notify controller
            for var i = 0; i < visitedBubbles.count; i++ {
                let index = visitedBubbles[i]
                let bubble = bubblesInGrid[index]!
                removedTags.append(bubble.tag!)
                bubblesInGrid[index] = nil
            }
        }
        return removedTags
    }
    
    private func remove(removedTags: Array<Int>) {
        for tag in removedTags {
            bubbles[tag] = nil
        }
        physicsEngine.deleteBubble(removedTags)
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.removeBubbleMessage, object: removedTags)
        
        checkFalling()
    }
    
    // This function is to check if there are some bubbles that are unattached.
    private func checkFalling() {
        var queue = Queue<Int>()
        var isVisited = Dictionary<Int, Bool>()
        
        for var i = 0; i < Int(Constants.numberOfBubbleInRow); i++ {
            if bubblesInGrid[i] != nil {
                queue.enqueue(i)
                isVisited[i] = true
            }
        }
        
        // BFS using queue
        while queue.isEmpty == false {
            let u = queue.dequeue()!
            for v in graph[u] {
                if isVisited[v] == nil && bubblesInGrid[v] != nil {
                    queue.enqueue(v)
                    isVisited[v] = true
                }
            }
        }
        
        // set the direction and acceleration for these bubbles. (make it falling)
        for var i = 0; i < Constants.numberOfCollectionCells; i++ {
            if bubblesInGrid[i] != nil && isVisited[i] == nil {
                var bubble = bubblesInGrid[i]
                bubblesInGrid[i] = nil
                bubble!.direction = CGVector(dx: 0, dy: velocity)
                bubble!.distance = worldHeight - bubble!.coordinate.y + bubbleSize
                bubble!.velocity = 0
                bubble!.acceleration = self.accelaration
            }
        }
    }
    
    // remove all the bubble that falled out of the screen.
    private func removeFalledBubbles() {
        var removedTags = Array<Int>()
        for (index, bubble) in bubbles {
            if bubble.coordinate.y > worldHeight {
                removedTags.append(bubble.tag!)
            }
        }
        for tag in removedTags {
            bubbles[tag] = nil
        }
        physicsEngine.deleteBubble(removedTags)
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.removeBubbleMessage, object: removedTags)
    }
    
    func canFire(destination: CGPoint) -> Bool {
        return (isGameOver || destination.y > barrier || isFiring) == false
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
        bullet!.velocity = self.velocity
        
        // move the next bullet to the fire position (the canon later).
        nextBullet!.direction = CGVector(dx: velocity, dy: 0)
        nextBullet!.velocity = self.velocity
        nextBullet!.distance = (worldWidth - bubbleSize) / 2
        
        // make a new bullet.
        bullet = nextBullet
        nextBullet = getNewBullet()
        
        notifyUpdatingToController()
        return [nextBullet!]
    }
    
    // create a random new bubblet
    private func getNewBullet() -> BubbleModel {
        var bubble = BubbleModel(coordinate: CGPoint(x: -bubbleSize/2, y: worldHeight-bubbleSize/2),
            type: randomColor())
        bubble.direction = CGVector(dx: velocity, dy: 0)
        bubble.distance = bubbleSize
        bubble.velocity = self.velocity
        bubble.tag = ++key
        bubbles[key] = bubble
        
        physicsEngine.addBubble(bubble)
        return bubble
    }
    
    func getBullet() -> BubbleModel? {
        return bullet?
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