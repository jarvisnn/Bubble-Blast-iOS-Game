//
//  CollectionViewCustomLayout.swift
//  LevelDesigner
//
//  Created by kunn on 2/1/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
    This class is to define the layout of the Grid.
    In other words, it just calculates the position of each cell.
*/
class CollectionViewCustomLayout: UICollectionViewLayout {

    override func collectionViewContentSize() -> CGSize {
        return self.collectionView!.frame.size
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject] {
        var allAttributesInRect = [UICollectionViewLayoutAttributes]()
        
        let cellSize = rect.size.width / CGFloat(Constants.numberOfBubbleInRow);
        let radius = cellSize / 2;
        let eps: CGFloat = 0.0001
        var currentX: CGFloat = 0, currentY: CGFloat = 0;
        
        for (var i = 0; i < self.collectionView?.numberOfSections(); i++) {
            for (var j = 0; j < self.collectionView?.numberOfItemsInSection(i); j++) {
                var cellFrame = CGRectMake(currentX, currentY, cellSize, cellSize)
                
                var indexPath = NSIndexPath(forRow: j, inSection: i)
                var attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attr.frame = cellFrame
                allAttributesInRect.append(attr)
                
                // Calculate the position of the cell.
                currentX += cellSize
                if currentX > rect.size.width - radius - eps {
                    currentY += radius * sqrt(3)
                    currentX = currentX > rect.size.width - radius / 2 ? radius : 0
                }
            }
        }
    
        return allAttributesInRect
    }
}