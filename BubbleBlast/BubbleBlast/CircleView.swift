//
//  CircleView.swift
//  LevelDesigner
//
//  Created by kunn on 2/1/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
    This class is to draw a cycle.
    It is subclassed from UIView.
*/
class CircleView: UIView {    
    override func drawRect(rect: CGRect) {
        // Get the Graphics Context
        var context = UIGraphicsGetCurrentContext();
        var circleRect = CGRectInset(rect, 1, 1);
        
        // Set the circle outerline-width
        CGContextSetLineWidth(context, 1);
        
        // Set color
        CGContextSetRGBFillColor(context, 255, 255, 255, 0.2);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
        
        // Drawing
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
    }
}
