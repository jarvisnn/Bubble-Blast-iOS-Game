//
//  GameLogic.swift
//  BubbleBlast
//
//  Created by kunn on 2/26/15.
//  Copyright (c) 2015 Jarvis. All rights reserved.
//

import UIKit

/*
    This class defines all game logics.
*/
class GameLogic {
    private let worldWidth: CGFloat
    private let worldHeight: CGFloat
    private let bubbleSize: CGFloat
    private let radius: CGFloat
    
    private var grid = Array<CGPoint>()
    private var graph = Array<Array<Int>> ()
    
    private var bubblesInGrid = Array<BubbleModel?>(count: Constants.numberOfCollectionCells, repeatedValue: nil)
    
    init(worldWidth: CGFloat, worldHeight:CGFloat, bubbleSize: CGFloat) {
        self.worldWidth = worldWidth
        self.worldHeight = worldHeight
        self.bubbleSize = bubbleSize
        self.radius = bubbleSize / 2
        
        setupGrid()
        setupGraph()
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
    
    // Reposition a bubble, snap it to the grid's cells
    func reposition(bubble: BubbleModel) {
        for var i = 0; i < grid.count ; i++ {
            if (grid[i].x-radius <= bubble.coordinate.x && bubble.coordinate.x <= grid[i].x+radius
                && grid[i].y-radius <= bubble.coordinate.y && bubble.coordinate.y <= grid[i].y+radius) {
                    bubble.coordinate = grid[i]
                    bubblesInGrid[i] = bubble
                    break
            }
        }
    }
    
    // add a new bubble and check it
    func addBubble(bubble: BubbleModel, isBullet: Bool) -> Array<Int>{
        reposition(bubble)
        return isBullet ? checkRemoving(bubble) : Array<Int>()
    }
    
    // return bubbles in grid
    func getBubbles() -> Array<BubbleModel?> {
        return bubblesInGrid
    }
    
    // return the whole grid
    func getGrid() -> Array<CGPoint> {
        return grid
    }
    
    // This function is to check if there is a group of > 3 bubbles that are connected and have the same color
    // and remove it.
    private func checkRemoving(bubble: BubbleModel) -> Array<Int> {
        var queue = Queue<Int>()
        var isVisited = Dictionary<Int, Bool>()
        var visitedBubbles = Array<Int>()
        var bulletPosition = 0
        
        for var i = 0; i < Constants.numberOfCollectionCells; i++ {
            if bubble.coordinate == grid[i] && bubblesInGrid[i] != nil {
                queue.enqueue(i)
                isVisited[i] = true
                bulletPosition = i
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
        
        var tags = checkSpecialBubble(bulletPosition, bullet: bubble)
        for tag in tags {
            removedTags.append(tag)
        }
        return removedTags
    }
    
    // check special bubbles and activate it.
    private func checkSpecialBubble(u: Int, bullet: BubbleModel) -> Array<Int> {
        var tags = Array<Int>()
        var actionQueue = Queue<(String, Int)>()
        for v in graph[u] {
            if bubblesInGrid[v] != nil && isNormalBubble(bubblesInGrid[v]!) == false {
                if bubblesInGrid[v]!.type == Constants.lightningBubble {
                    actionQueue.enqueue("lightning", v)
                } else if bubblesInGrid[v]!.type == Constants.bombBubble {
                    actionQueue.enqueue("bomb", v)
                } else if bubblesInGrid[v]!.type == Constants.starBubble {
                    actionQueue.enqueue("star", v)
                }
            }
        }
        
        while actionQueue.isEmpty == false {
            let action = actionQueue.dequeue()!
            if (action.0 == "lightning") {
                for tag in activateLightning(action.1) {
                    tags.append(tag)
                }
            } else if (action.0 == "bomb") {
                for tag in activateBomb(action.1) {
                    tags.append(tag)
                }
            } else if (action.0 == "star") {
                for tag in activateStar(action.1, bullet: bullet) {
                    tags.append(tag)
                }
            }
            if (bubblesInGrid[action.1] != nil) {
                tags.append(bubblesInGrid[action.1]!.tag!)
                bubblesInGrid[action.1] = nil
            }
        }
        return tags
    }
    
    private func activateLightning(u: Int) -> Array<Int> {
        var tags = Array<Int>()
        let row = bubblesInGrid[u]!.coordinate.y
        
        for var i = 0; i < Constants.numberOfCollectionCells; i++ {
            if bubblesInGrid[i] != nil && bubblesInGrid[i]!.coordinate.y == row && i != u
                    && bubblesInGrid[i]!.type != Constants.indestructibleBubble {
                tags.append(bubblesInGrid[i]!.tag!)
                bubblesInGrid[i] = nil
            }
        }
        return tags
    }
    
    private func activateBomb(u: Int) -> Array<Int> {
        var tags = Array<Int>()
        for v in graph[u] {
            if bubblesInGrid[v] != nil && bubblesInGrid[v]!.type != Constants.indestructibleBubble {
                tags.append(bubblesInGrid[v]!.tag!)
                bubblesInGrid[v] = nil
            }
        }
        return tags
    }
    
    private func activateStar(u: Int, bullet: BubbleModel) -> Array<Int> {
        var tags = Array<Int>()
        for var i = 0; i < Constants.numberOfCollectionCells; i++ {
            if bubblesInGrid[i] != nil && bubblesInGrid[i]!.type == bullet.type
                    && bubblesInGrid[i]!.type != Constants.indestructibleBubble {
                tags.append(bubblesInGrid[i]!.tag!)
                bubblesInGrid[i] = nil
            }
        }
        return tags
    }
    
    // reformat a game, at the beginning.
    func reformat() -> Array<Int> {
        var queue = Queue<Int>()
        var isVisited = Dictionary<Int, Bool>()
        var removedTags = Array<Int>()
        while true {
            queue = Queue<Int>()
            for var i = 0; i < Constants.numberOfCollectionCells; i++ {
                if bubblesInGrid[i] != nil && isVisited[i] == nil {
                    queue.enqueue(i)
                    isVisited[i] = true
                    break
                }
            }
            if queue.isEmpty {
                break
            }
            
            var visitedBubbles = Array<Int>()
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
            
            if visitedBubbles.count >= 3 && isNormalBubble(bubblesInGrid[visitedBubbles[0]]!) {
                // if there is a such group, delete bubbles and notify controller
                for var i = 0; i < visitedBubbles.count; i++ {
                    let index = visitedBubbles[i]
                    let bubble = bubblesInGrid[index]!
                    removedTags.append(bubble.tag!)
                    bubblesInGrid[index] = nil
                }
            }
        }
        return removedTags
    }
    
    // This function is to check if there are some bubbles that are unattached.
    func checkFalling() {
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
                bubble!.direction = CGVector(dx: 0, dy: Constants.velocity)
                bubble!.distance = worldHeight - bubble!.coordinate.y + bubbleSize
                bubble!.velocity = 0
                bubble!.acceleration = Constants.accelaration
            }
        }
    }
    
    private func isNormalBubble(bubble: BubbleModel) -> Bool {
        return bubble.type == Constants.redBubble
            || bubble.type == Constants.blueBubble
            || bubble.type == Constants.greenBubble
            || bubble.type == Constants.orangeBubble
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
