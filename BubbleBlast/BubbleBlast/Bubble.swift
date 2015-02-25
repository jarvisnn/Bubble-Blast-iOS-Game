//
//  Bubble.swift
//  LevelDesigner
//
//  Created by kunn on 2/3/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
Bubble object controller, it contains a model and a view.
*/
class Bubble {
    private var view = BubbleView()
    private var model: BubbleModel
    
    init(model: BubbleModel) {
        self.model = model
        view.setView(getBubbleImage(model.type),
            xCoordinate: model.coordinate.x - Constants.bubbleSize/2,
            yCoordinate: model.coordinate.y - Constants.bubbleSize/2,
            width: Constants.bubbleSize, height: Constants.bubbleSize)
    }
    
    func updateView() {
        view.setView(getBubbleImage(model.type),
            xCoordinate: model.coordinate.x - Constants.bubbleSize/2,
            yCoordinate: model.coordinate.y - Constants.bubbleSize/2,
            width: Constants.bubbleSize, height: Constants.bubbleSize)
    }
    
    func getView() -> UIImageView {
        return view.getView()
    }
    
    func getModel() -> BubbleModel {
        return model
    }
    
    func changeToNextBubble() {
        let bubbleType = model.type
        if bubbleType == Constants.blueBubble {
            updateBubble(Constants.redBubble)
        } else if bubbleType == Constants.redBubble {
            updateBubble(Constants.orangeBubble)
        } else if bubbleType == Constants.orangeBubble {
            updateBubble(Constants.greenBubble)
        } else if bubbleType == Constants.greenBubble {
            updateBubble(Constants.indestructibleBubble)
        } else if bubbleType == Constants.indestructibleBubble {
            updateBubble(Constants.lightningBubble)
        } else if bubbleType == Constants.lightningBubble {
            updateBubble(Constants.bombBubble)
        } else if bubbleType == Constants.bombBubble {
            updateBubble(Constants.starBubble)
        } else if bubbleType == Constants.starBubble {
            updateBubble(Constants.blueBubble)
        }
    }
    
    func updateBubble(type: String) {
        model.type = type
        view.setView(getBubbleImage(type))
    }
    
    private func getBubbleImage(type: String) -> String {
        var image: String?
        if type == Constants.blueBubble {
            image = Constants.blueBubbleLink
        } else if type == Constants.redBubble {
            image = Constants.redBubbleLink
        } else if type == Constants.orangeBubble {
            image = Constants.orangeBubbleLink
        } else if type == Constants.greenBubble {
            image = Constants.greenBubbleLink
        } else if type == Constants.indestructibleBubble {
            image = Constants.indestructibleBubbleLink
        } else if type == Constants.lightningBubble {
            image = Constants.lightningBubbleLink
        } else if type == Constants.bombBubble {
            image = Constants.bombBubbleLink
        } else if type == Constants.starBubble {
            image = Constants.starBubbleLink
        }
        return image!
    }
}