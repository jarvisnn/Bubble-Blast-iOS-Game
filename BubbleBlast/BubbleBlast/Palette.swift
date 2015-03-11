//
//  Palette.swift
//  LevelDesigner
//
//  Created by kunn on 2/3/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
    I created a new class of 'Palette' for easier to use.
    The 'Palette' includes some views, each view is an image in the palette.
*/
class Palette {
    // Some constants
    private let halfTransparent = CGFloat(0.5)
    private let fullTransparent = CGFloat(1)
    
    private let paletteHeight = CGFloat(60)
    private let yCoordinate = Float(10)
    private let xCoordinate = Float(10)
    private let bubbleSpace = Float(80)
    private let imageSources = [Constants.blueBubbleLink, Constants.redBubbleLink,
                                Constants.orangeBubbleLink, Constants.greenBubbleLink,
                                Constants.indestructibleBubbleLink, Constants.lightningBubbleLink,
                                Constants.bombBubbleLink, Constants.starBubbleLink,
                                Constants.eraserLink]
    private let paletteOrder = [Constants.blueBubble, Constants.redBubble,
                                Constants.orangeBubble, Constants.greenBubble,
                                Constants.indestructibleBubble, Constants.lightningBubble,
                                Constants.bombBubble, Constants.starBubble,
                                Constants.eraser]
    
    private let view: [UIImageView]
    private var currentState = Constants.noState;
    
    // Init 5 views in the palette
    init() {
        view = [UIImageView](count: imageSources.count, repeatedValue: UIImageView())
        for var i = 0; i < imageSources.count; i++ {
            view[i] = createView(i, imageFile: imageSources[i], x: xCoordinate + bubbleSpace * Float(i), y: yCoordinate)
        }
    }
    
    private func createView(index: Int, imageFile: String, x: Float, y: Float) -> UIImageView {
        let image = UIImage(named: imageFile)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(CGFloat(x), CGFloat(y),
            paletteHeight * image!.size.width / image!.size.height, paletteHeight)
        imageView.alpha = halfTransparent
        return imageView
    }
    
    var views: Array<UIImageView> {
        return view
    }
    
    // return the view that is currently chosen
    var state: String {
        return currentState
    }
    
    // Handle a tap. Highlight the view chosen.
    // This function will be called from the ViewController.
    func handleTap(viewTapped: UIView?) {
        for var i = 0; i < view.count; i++ {
            if view[i] == viewTapped {
                currentState = paletteOrder[i]
                view[i].alpha = fullTransparent
            } else {
                view[i].alpha = halfTransparent
            }
        }
    }
}
