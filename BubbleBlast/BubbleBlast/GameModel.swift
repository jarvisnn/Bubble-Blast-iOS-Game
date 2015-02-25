//
//  GameModel.swift
//  LevelDesigner
//
//  Created by kunn on 2/5/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

/*
    The Game Model. Using plist to store the Game.
    All the game names will be saved in file `listOfGames`
*/
class GameModel {
    private let dataFile = "listOfGames"
    
    // Return a list of all saved games.
    func getGameList() -> NSArray {
        let path = getPath(dataFile)
        var gameList = NSArray(contentsOfFile: path)
        if gameList == nil {
            gameList = NSArray()
        }
        return gameList!
    }
    
    // Load a game with name `fileName`
    func loadGame(fileName: String) -> Array<BubbleModel> {
        let path = getPath(fileName)
        var data = NSArray(contentsOfFile: path)
        
        var bubbles = [BubbleModel]()
        for item in data as [Dictionary<String, AnyObject>] {
            let coordinate = CGPoint(x: item["xCoordinate"] as CGFloat, y: item["yCoordinate"] as CGFloat)
            let model = BubbleModel(coordinate: coordinate, type: item["type"] as String)
            bubbles.append(model)
        }
        return bubbles
    }
    
    // Save a game to `fileName`, given a list of Bubbles
    func saveGame(fileName: String, data: Array<BubbleModel>) {
        let path = getPath(fileName)
        reformat(data).writeToFile(path, atomically: true)
        updateGameList(fileName)
    }
    
    // Have saved a game and add that game to the list
    private func updateGameList(newFile: String) {
        var gameList = getGameList() as Array<String>
        let path = getPath(dataFile)
        if contains(gameList, newFile) == false {
            gameList.append(newFile)
        }
        (gameList as NSArray).writeToFile(path, atomically: true)
    }
    
    // Reformat the bubble object to NSArray, for the convenience of using plist
    private func reformat(data: Array<BubbleModel>) -> NSArray{
        var newData = [Dictionary<String, AnyObject>]()
        for bubble in data {
            var item = Dictionary<String, AnyObject>()
            item["xCoordinate"] = bubble.coordinate.x
            item["yCoordinate"] = bubble.coordinate.y
            item["type"] = bubble.type
            newData.append(item)
        }
        return NSArray(array: newData)
    }
    
    // Delete a game
    func deleteGame(fileName: String) {
        var gameList = getGameList() as Array<String>
        let path = getPath(dataFile)
        
        // Delete the game in the list
        var deletedPosition: Int?
        for var i = 0; i < gameList.count; i++ {
            if gameList[i] == fileName {
                deletedPosition = i
                break
            }
        }
        if deletedPosition != nil {
            gameList.removeAtIndex(deletedPosition!)
            (gameList as NSArray).writeToFile(path, atomically: true)
        }
        
        // Delete the game file
        let deletePath = getPath(fileName)
        var error:NSError?
        var ok:Bool = NSFileManager.defaultManager().removeItemAtPath(deletePath, error: &error)
        if error != nil {
            println(error)
        }
    }
    
    // get the true address of the plist file.
    private func getPath(fileName: String) -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as NSString
        let path = documentsDirectory.stringByAppendingPathComponent(fileName + ".plist")
        return path
    }
}
