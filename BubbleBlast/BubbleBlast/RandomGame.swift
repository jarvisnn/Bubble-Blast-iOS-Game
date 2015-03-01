//
//  RandomGame.swift
//  BubbleBlast
//
//  Created by kunn on 3/1/15.
//  Copyright (c) 2015 Jarvis. All rights reserved.
//

import UIKit

class RandomGame {
    private var grid = Array<CGPoint>()
    private var graph = Array<Array<Int>> ()
    private var connectedSameColor = Array<Int>(count: Constants.numberOfCollectionCells, repeatedValue: 0)
    private var bubblesInGrid = Array<BubbleModel?>(count: Constants.numberOfCollectionCells, repeatedValue: nil)
    
    init() {
        setupGrid()
        setupGraph()
    }
    
    func create(quantity: Int, indestructible: Int, star: Int, lightning: Int, bomb: Int) -> Array<Bubble> {
        var result = Array<Bubble>()
        
        for (var u = 0; u < quantity; u++) {
            var existing = Dictionary<String, Int>()
            for v in graph[u] {
                if (v < u) {
                    if existing[bubblesInGrid[v]!.type] == nil {
                        existing[bubblesInGrid[v]!.type] = connectedSameColor[v]
                    } else {
                        existing[bubblesInGrid[v]!.type] = existing[bubblesInGrid[v]!.type]! + connectedSameColor[v]
                    }
                }
            }
            var bubbles = Array<String>()
            if existing[Constants.blueBubble] == nil || existing[Constants.blueBubble] < Constants.connectedBubbleBound - 1 {
                bubbles.append(Constants.blueBubble)
            }
            if existing[Constants.redBubble] == nil || existing[Constants.redBubble] < Constants.connectedBubbleBound - 1 {
                bubbles.append(Constants.redBubble)
            }
            if existing[Constants.orangeBubble] == nil || existing[Constants.orangeBubble] < Constants.connectedBubbleBound - 1 {
                bubbles.append(Constants.orangeBubble)
            }
            if existing[Constants.greenBubble] == nil || existing[Constants.greenBubble] < Constants.connectedBubbleBound - 1 {
                bubbles.append(Constants.greenBubble)
            }
            
            bubblesInGrid[u] = BubbleModel(coordinate: grid[u], type: bubbles[Int(rand()) % bubbles.count])
            connectedSameColor[u] = 1
            for v in graph[u] {
                if (v < u && bubblesInGrid[v]!.type == bubblesInGrid[u]!.type) {
                    connectedSameColor[u] += connectedSameColor[v]
                    if grid[v].y == grid[u].y {
                        connectedSameColor[v]++
                    }
                }
            }
        }
        
        if indestructible + star + lightning + bomb <= quantity {
            for (var i = 0; i < indestructible; i++) {
                var u: Int;
                do {
                    u = Int(rand()) % quantity
                } while (isNormalBubble(bubblesInGrid[u]!) == false || u < Int(Constants.numberOfBubbleInRow))
             bubblesInGrid[u]!.type = Constants.indestructibleBubble
            }
            for (var i = 0; i < star; i++) {
                var u: Int;
                do {
                    u = Int(rand()) % quantity
                } while isNormalBubble(bubblesInGrid[u]!) == false
                bubblesInGrid[u]!.type = Constants.starBubble
            }
            for (var i = 0; i < lightning; i++) {
                var u: Int;
                do {
                    u = Int(rand()) % quantity
                } while isNormalBubble(bubblesInGrid[u]!) == false
                bubblesInGrid[u]!.type = Constants.lightningBubble
            }
            for (var i = 0; i < bomb; i++) {
                var u: Int;
                do {
                    u = Int(rand()) % quantity
                } while isNormalBubble(bubblesInGrid[u]!) == false
                bubblesInGrid[u]!.type = Constants.bombBubble
            }
        }
        
        for var i = 0; i < quantity; i++ {
            result.append(Bubble(model: bubblesInGrid[i]!))
        }
        return result
    }
    
    // calculate the coordinates of each cell in the grid.
    private func setupGrid() {
        var currentX: CGFloat = Constants.radius, currentY: CGFloat = Constants.radius;
        
        for (var j = 0; j < Constants.numberOfCollectionCells; j++) {
            grid.append(CGPoint(x: currentX, y: currentY))
            currentX += Constants.bubbleSize
            if currentX >= Constants.ipadWidth - Constants.radius * 0.5 {
                currentY += Constants.radius * sqrt(3)
                currentX = currentX > Constants.ipadWidth + Constants.radius * 0.5
                    ? Constants.bubbleSize : Constants.radius
            }
        }
    }
    
    // from the grid, store it as a graph.
    private func setupGraph() {
        for var i = 0; i < Constants.numberOfCollectionCells; i++ {
            graph.append(Array<Int>())
            for var j = 0; j < Constants.numberOfCollectionCells; j++ {
                if i != j && distance(grid[i], point2: grid[j]) < Constants.bubbleSize * 1.5 {
                    graph[i].append(j)
                }
            }
        }
    }
    
    private func distance(point1: CGPoint, point2: CGPoint) -> CGFloat{
        return length(CGVector(dx: point1.x-point2.x, dy: point1.y-point2.y))
    }
    
    private func length(vector: CGVector) -> CGFloat {
        return sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    }
    
    private func isNormalBubble(bubble: BubbleModel) -> Bool {
        return bubble.type == Constants.redBubble
            || bubble.type == Constants.blueBubble
            || bubble.type == Constants.greenBubble
            || bubble.type == Constants.orangeBubble
    }
}
