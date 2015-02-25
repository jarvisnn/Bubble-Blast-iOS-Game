//
//  ViewController.swift
//  LevelDesigner
//
//  Created by YangShun on 26/1/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

class LevelDesignerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet var gameArea: UIView!
    @IBOutlet var paletteArea: UIView!
    @IBOutlet var buttonArea: UIView!
    @IBOutlet var loadArea: UITableView!
    private var gridArea: UICollectionView!
    
    private let palette = Palette()
    private let gameModel = GameModel()
    
    private var bubbleInCell = [Bubble?](count: Constants.numberOfCollectionCells, repeatedValue: nil)
    private var listOfGames = Array<String>()
    private var currentGame: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupBackground()
        setupPalette()
        setupGrid()
        setupButton()
        setupLoadArea()
        setupOrder()
    }
    
    // set up the background.
    private func setupBackground() {
        let backgroundImage = UIImage(named: Constants.backgroundImageLink)
        let background = UIImageView(image: backgroundImage)
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        background.frame = CGRectMake(0, 0, gameViewWidth, gameViewHeight)
        self.gameArea.addSubview(background)
    }
    
    // set up palette, add its views to the main view.
    private func setupPalette() {
        self.paletteArea.backgroundColor = Constants.paletteBackgroundColor
        for view in palette.views {
            // add tapping handle
            let tapGesture = UITapGestureRecognizer(target: self, action:Selector("paletteTapped:"))
            view.userInteractionEnabled = true
            view.addGestureRecognizer(tapGesture)
            
            // add to the mainview
            self.paletteArea.addSubview(view)
        }
    }
    
    // set up the grid
    private func setupGrid() {
        let layout: CollectionViewCustomLayout = CollectionViewCustomLayout()
        
        self.gridArea = UICollectionView(frame: gameArea.frame, collectionViewLayout: layout)
        self.gridArea.dataSource = self
        self.gridArea.delegate = self
        self.gridArea.registerClass(GridCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.gridArea.backgroundColor = UIColor.clearColor()
        self.view.addSubview(gridArea!)
        
        // add dragging handle.
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("cellDragging:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        gridArea.addGestureRecognizer(panGesture)
    }
    
    // These following 2 function is for setting up Grid, adapt UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.numberOfCollectionCells
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as GridCollectionViewCell
        cell.tag = indexPath.row
        
        // add tapping handler for each cell in the grid
        var tapRecgonizer = UITapGestureRecognizer(target: self, action: "cellTapped:")
        cell.addGestureRecognizer(tapRecgonizer)
        
        // add long pressing handle for each cell in the grid
        var longPressRecgonizer = UILongPressGestureRecognizer(target: self, action: "cellLongPressed:")
        cell.addGestureRecognizer(longPressRecgonizer)
        return cell
    }
    
    // setup button area
    private func setupButton() {
        self.buttonArea.backgroundColor = Constants.buttonBackgroundColor
    }
    
    // set up load area as a table view.
    private func setupLoadArea() {
        listOfGames = gameModel.getGameList() as Array<String>
        
        self.loadArea.dataSource = self
        self.loadArea.delegate = self
        self.loadArea.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.loadArea.backgroundColor = Constants.tableViewColor
    }
    
    // table view setup
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // table view setup
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfGames.count
    }
    
    // table view cell setup
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var bgColorView = UIView()
        bgColorView.backgroundColor = Constants.tableCellColor
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = Constants.tableCellColor
        cell.textLabel?.text = listOfGames[indexPath.row]
        
        return cell
    }
    
    // handler for deleting a game.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.gameModel.deleteGame(listOfGames[indexPath.row])
            self.listOfGames.removeAtIndex(indexPath.row)
            self.currentGame = nil
            self.loadArea.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // handler for loading a game.
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        loadArea.hidden = true
        loadGame(listOfGames[indexPath.row])
    }
    
    // load a game.
    private func loadGame(game: String) {
        // get the bubbles in the model
        let bubbleModels = gameModel.loadGame(game)
        
        // reset the grid
        reset();
        
        // add bubbles to the view
        for data in bubbleModels {
            let bubble = Bubble(model: data)
            if let path = gridArea.indexPathForItemAtPoint(data.coordinate) {
                let cell = gridArea.cellForItemAtIndexPath(path)!
                gridArea.addSubview(bubble.getView())
                bubbleInCell[path.row] = bubble
            }
        }
        currentGame = game;
    }
    
    // this function is to set up the subview's order.
    private func setupOrder() {
        self.view.bringSubviewToFront(gridArea)
        self.view.bringSubviewToFront(paletteArea)
        self.view.bringSubviewToFront(buttonArea)
        self.view.sendSubviewToBack(gameArea)
        self.view.bringSubviewToFront(loadArea)
        loadArea.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "start game") {
            var gameplay = segue.destinationViewController as LevelSelectionViewController;
            var bubbles = Array<Bubble>()
            for bubble in bubbleInCell {
                if bubble != nil {
                    bubbles.append(bubble!)
                }
            }
            gameplay.newGame(bubbles)
        }
    }

    // palette tap handler
    func paletteTapped(recognizer: UITapGestureRecognizer) {
        loadArea.hidden = true
        palette.handleTap(recognizer.view)
    }
    
    // cell long press handler
    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        loadArea.hidden = true
        
        let cell = recognizer.view as UICollectionViewCell
        let index = cell.tag
        
        // if the cell is not empty, remove the bubble
        if bubbleInCell[index] != nil {
            bubbleInCell[index]?.getView().removeFromSuperview()
            bubbleInCell[index] = nil
        }
    }
    
    // cell tap handler
    func cellTapped(recognizer: UITapGestureRecognizer) {
        loadArea.hidden = true
        
        let cell = recognizer.view as UICollectionViewCell
        let index = cell.tag
        
        if bubbleInCell[index] != nil {
            // if the cell is not empty, change to the next color in the cycle
            bubbleInCell[index]!.changeToNextBubble()
        } else {
            // if the cell is empty, create a new bubble for it.
            updateCell(cell)
        }
    }
    
    // cell dragging handler
    func cellDragging(recognizer: UIPanGestureRecognizer) {
        loadArea.hidden = true
        
        let point = recognizer.locationInView(self.view)
        let path = gridArea?.indexPathForItemAtPoint(point)
        
        // if the cell is valid, update it.
        if path != nil {
            let cell = gridArea?.cellForItemAtIndexPath(path!)
            updateCell(cell!)
        }
    }
    
    // update a cell with the current color in the palette
    private func updateCell(cell: UICollectionViewCell) {
        let index = cell.tag
        
        if bubbleInCell[index] == nil {
            // case cell is empty, create a new bubble object of the palette is not eraser.
            if palette.state != Constants.noState && palette.state != Constants.eraser {
                let coordinate = CGPoint(x: cell.frame.origin.x + Constants.radius, y: cell.frame.origin.y + Constants.radius)
                let model = BubbleModel(coordinate: coordinate, type: palette.state)
                let bubble = Bubble(model: model)
                gridArea.addSubview(bubble.getView())
                bubbleInCell[index] = bubble
            }
        } else {
            // case cell is not empty
            if palette.state == Constants.eraser {
                // remove the bubble
                bubbleInCell[index]?.getView().removeFromSuperview()
                bubbleInCell[index] = nil
            } else if palette.state != Constants.noState {
                // change the color
                bubbleInCell[index]!.updateBubble(palette.state)
            }
        }
    }
    
    // Save the current game. Alert is used
    @IBAction func saveButtonPressed(sender: UIButton) {
        loadArea.hidden = true
        
        var alert = UIAlertController(title: "Save game", message: "Enter your game's name!", preferredStyle: UIAlertControllerStyle.Alert)
        
        // and Save action
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) {
            action -> Void in
            let gameList = self.gameModel.getGameList() as Array<String>
            let fileName = (alert.textFields?.first as UITextField).text
            
            if fileName == "" || fileName == nil {
                // check if the game name is not valid, pop up the alert again
                alert.message = "The name is empty!"
                self.presentViewController(alert, animated: true, completion: nil)
            } else if contains(gameList, fileName) {
                // check if the game name has existed, pop up the alert again
                alert.message = "The name has existed!"
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                // the game name is ok, save the game to model
                var data = Array<BubbleModel>()
                for item in self.bubbleInCell {
                    if item != nil {
                        data.append(item!.getModel())
                    }
                }
                self.gameModel.saveGame(fileName, data: data)
                self.currentGame = fileName
                
                // reload the load Area. We have to use dispatch_async to avoid the clashing
                self.listOfGames = self.gameModel.getGameList() as Array<String>
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.loadArea.reloadData()
                })
            }
            })
        
        // if the current game was saved, add Resave action
        if currentGame != nil {
            alert.addAction(UIAlertAction(title: "Resave", style: UIAlertActionStyle.Default) {
                action -> Void in
                var data = Array<BubbleModel>()
                for item in self.bubbleInCell {
                    if item != nil {
                        data.append(item!.getModel())
                    }
                }
                self.gameModel.saveGame(self.currentGame!, data: data)
            })
        }
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        // textfield to get the game name
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter name"
            textField.secureTextEntry = false
        })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // LoadButton pressed, just show / hide the loadArea
    @IBAction func loadButtonPressed(sender: UIButton) {
        if loadArea.hidden {
            loadArea.hidden = false
        } else {
            loadArea.hidden = true
        }
    }
    
    // Reset a game, delete all bubble objects
    @IBAction func resetButtonPressed(sender: UIButton) {
        loadArea.hidden = true
        reset()
    }
    
    private func reset() {
        for var i=0; i < bubbleInCell.count; i++ {
            if  bubbleInCell[i] != nil {
                bubbleInCell[i]!.getView().removeFromSuperview()
                bubbleInCell[i] = nil
            }
        }
    }
}