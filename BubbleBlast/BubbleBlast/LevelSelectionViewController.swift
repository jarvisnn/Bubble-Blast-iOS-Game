//
//  LevelSelectionViewController.swift
//  BubbleBlast
//
//  Created by kunn on 2/28/15.
//  Copyright (c) 2015 Jarvis. All rights reserved.
//

import UIKit

/*
    This class is to display game prepared as well as game designed in Design mode.
*/
class LevelSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let gameModel = GameModel()
    private let randomGame = RandomGame()
    private var listOfGames: Array<String>?
    private var bubbles = Array<Bubble>()
    private let rowHeight = CGFloat(25)
    
    @IBOutlet var selectionArea: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSelectionArea()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // setup TableView
    private func setupSelectionArea() {
        listOfGames = gameModel.getGameList() as? Array<String>
        
        self.selectionArea.dataSource = self
        self.selectionArea.delegate = self
        self.selectionArea.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.selectionArea.backgroundColor = Constants.tableViewColor
        self.selectionArea!.rowHeight = rowHeight
        self.selectionArea!.hidden = true
    }
    
    // table view setup
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // table view setup
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfGames!.count
    }
    
    // table view cell setup
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        cell.textLabel?.text = listOfGames![indexPath.row]
        return cell
    }
    
    // handler for deleting a game.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.gameModel.deleteGame(listOfGames![indexPath.row])
            self.listOfGames!.removeAtIndex(indexPath.row)
            self.selectionArea.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // handler for loading a game.
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        selectionArea.hidden = true
        loadGame(listOfGames![indexPath.row])
    }
    
    // load a game.
    private func loadGame(game: String) {
        // get the bubbles in the model
        let data = gameModel.loadGame(game)
        bubbles = Array<Bubble> ()
        for item in data {
            bubbles.append(Bubble(model: item))
        }
        activateSegue()
    }
    
    // move to GamePlay screen
    private func activateSegue() {
        performSegueWithIdentifier("selectionDone", sender: nil)
    }
    
    // prepare for the game
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "selectionDone") {
            var gameplay = segue.destinationViewController as GamePlayViewController;
            gameplay.setData(bubbles)
        }
    }
    
    // create level "easy"
    @IBAction func easyGameClicked(sender: UIButton) {
        bubbles = randomGame.create(58, indestructible: 0, star: 3, lightning: 3, bomb: 3)
        activateSegue()
        self.selectionArea!.hidden = true
    }

    // create level "medium"
    @IBAction func mediumGameClicked(sender: UIButton) {
        bubbles = randomGame.create(69, indestructible: 5, star: 2, lightning: 2, bomb: 2)
        activateSegue()
        self.selectionArea!.hidden = true
    }

    // create level "hard"
    @IBAction func hardGameClicked(sender: UIButton) {
        bubbles = randomGame.create(92, indestructible: 15, star: 2, lightning: 2, bomb: 2)
        activateSegue()
        self.selectionArea!.hidden = true        
    }
    
    @IBAction func designedLevelsClicked(sender: UIButton) {
        selectionArea!.hidden = !selectionArea!.hidden
    }
    
    // go back menu
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
