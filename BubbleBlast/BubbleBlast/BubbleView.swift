//
//  BubbleView.swift
//  LevelDesigner
//
//  Created by kunn on 2/3/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
    Bubble View. Given some information and return an UIImageView.
*/
class BubbleView {
    private var view = UIImageView()
    
    func setView(image: String) {
        view.image = UIImage(named: image)
    }
    
    func setView(image: String, xCoordinate: CGFloat, yCoordinate: CGFloat, width: CGFloat, height: CGFloat) {
        view.image = UIImage(named: image)
        view.frame = CGRectMake(xCoordinate, yCoordinate, width, height)
    }
    
    func getView() -> UIImageView {
        return view
    }
}