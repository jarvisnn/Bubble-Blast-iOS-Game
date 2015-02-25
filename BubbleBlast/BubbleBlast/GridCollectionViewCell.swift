//
//  GridCollectionViewCell.swift
//  LevelDesigner
//
//  Created by kunn on 2/1/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
    This class is to define the content of the Grid.
    At the beginning, each cell only contains an empty circle
*/
class GridCollectionViewCell: UICollectionViewCell {
    let circleView: CircleView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        circleView = CircleView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        circleView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(circleView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
