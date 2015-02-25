//
//  Constants.swift
//  LevelDesigner
//
//  Created by kunn on 2/3/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
    This struct contains lots of constants that can be used in many class
*/
struct Constants {
    static let ipadWidth = CGFloat(768)
    static let ipadHeight = CGFloat(1024)
    static let numberOfBubbleInRow = CGFloat(12)
    static let bubbleSize = ipadWidth / numberOfBubbleInRow
    static let radius = bubbleSize / 2
    
    static let numberOfCollectionCells = 161
    
    static let numberOfBubbles = 4
    static let noState = "no state"
    static let blueBubble = "blue"
    static let redBubble = "red"
    static let orangeBubble = "orange"
    static let greenBubble = "green"
    static let burstBubble = "burst"
    static let bombBubble = "bomb"
    static let indestructibleBubble = "indestructible"
    static let lightningBubble = "lightning"
    static let starBubble = "star"
    static let eraser = "eraser"
    static let bubbleOrder = [blueBubble, redBubble, orangeBubble, greenBubble, eraser]
    
    static let blueBubbleLink = "bubble-blue.png"
    static let redBubbleLink = "bubble-red.png"
    static let orangeBubbleLink = "bubble-orange.png"
    static let greenBubbleLink = "bubble-green.png"
    static let burstBubbleLink = "bubble-burst.png"
    static let bombBubbleLink = "bubble-bomb.png"
    static let indestructibleBubbleLink = "bubble-indestructible.png"
    static let lightningBubbleLink = "bubble-lightning.png"
    static let starBubbleLink = "bubble-star.png"
    static let eraserLink = "eraser-1.png"
    static let backgroundImageLink = "background.png"
    
    static let cannonBaseLink = "cannon-base.png"
    static let cannonLink = "cannon.png"
    static let cannonBaseWidth = CGFloat(140)
    static let cannonWidth = CGFloat(130)
    static let numberOfCannonAnimations = 12
    
    static let bubbleCollisionKey = "Collision"
    static let removeBubbleMessage = "removeBubble"
    static let updateBubbleMesseage = "updateBubble"
    static let stopUpdateBubbleMessage = "stopUpdating"
    
    static let paletteBackgroundColor = UIColor(white: 0, alpha: 0.5)
    static let buttonBackgroundColor = UIColor(white:0, alpha: 0.8)
    static let tableViewColor = UIColor(white: 0, alpha: 0.5)
    static let tableCellColor = UIColor(red: 0.3, green: 0.75, blue: 0.2, alpha: 0.8)
}