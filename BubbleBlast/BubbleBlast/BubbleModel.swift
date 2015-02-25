//
//  BubbleModel.swift
//  LevelDesigner
//
//  Created by kunn on 2/3/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
Bubble Model.
Store the coordinate, direction, distance move, velocity, acceleration, type and one additional tag.
*/
class BubbleModel {
    private var _coordinate: CGPoint
    private var _direction: CGVector
    private var _distance: CGFloat
    private var _velocity: CGFloat
    private var _acceleration: CGFloat
    private var _type: String
    private var _tag: Int?
    
    var coordinate: CGPoint {
        set(newValue) {
            _coordinate = newValue
        }
        get {
            return _coordinate
        }
    }
    
    var direction: CGVector {
        set(newValue) {
            _direction = newValue
        }
        get {
            return _direction
        }
    }
    
    var distance: CGFloat {
        set(newValue) {
            _distance = newValue
        }
        get {
            return _distance
        }
    }
    
    var velocity: CGFloat {
        set(newValue) {
            _velocity = newValue
        }
        get {
            return _velocity
        }
    }
    
    var acceleration: CGFloat {
        set(newValue) {
            _acceleration = newValue
        }
        get {
            return _acceleration
        }
    }
    
    var type: String {
        set(newValue) {
            _type = newValue
        }
        get {
            return _type
        }
    }
    
    var tag: Int? {
        set(newValue) {
            _tag = newValue
        }
        get {
            return _tag
        }
    }
    
    init(coordinate: CGPoint, type: String) {
        self._coordinate = coordinate
        self._type = type
        self._tag = nil
        self._direction = CGVector.zeroVector
        self._distance = 0
        self._velocity = 0
        self._acceleration = 0
    }
}
