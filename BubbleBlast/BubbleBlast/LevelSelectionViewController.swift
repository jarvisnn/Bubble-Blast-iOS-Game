//
//  ViewController.swift
//  GameEngine
//
//  Created by kunn on 2/12/15.
//  Copyright (c) 2015 Jarvis. All rights reserved.
//

import UIKit

class LevelSelectionViewController: UIViewController {
    
    @IBOutlet var gameArea: UIView!
    
    private var bubbles = Dictionary<Int, Bubble>()
    private var gameEngine : GameEngine?
    private var timer: NSTimer?
    
    private var cannonAnimations = Array<UIImage>()
    private var background = UIImageView()
    private var cannon = UIImageView()
    private var base = UIImageView()
    private var isRotating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupBackground()
        setupCannon()
        setupBase()
        setupGame(Array<Bubble>())
        setupNotification()
        setupHandler()
    }
    
    // set up the background.
    private func setupBackground() {
        let backgroundImage = UIImage(named: Constants.backgroundImageLink)
        background = UIImageView(image: backgroundImage)
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        background.frame = CGRectMake(0, 0, gameViewWidth, gameViewHeight)
        self.gameArea.addSubview(background)
    }
    
    private func setupCannon() {
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        
        let cannons = UIImage(named: Constants.cannonLink)!
        for var i = 0; i < Constants.numberOfCannonAnimations; i++ {
            let cropRect = CGRectMake(cannons.size.width / 6 * CGFloat(i % 6),
                i < 6 ? 0 : cannons.size.height / 2, cannons.size.width / 6, cannons.size.height / 2)
            let imageRef = CGImageCreateWithImageInRect(cannons.CGImage, cropRect)
            cannonAnimations.append(UIImage(CGImage: imageRef)!)
        }
        
        cannon = UIImageView(image: cannonAnimations[0])
        let cannonWidth = Constants.cannonWidth
        let cannonHeight = cannon.frame.height / cannon.frame.width * Constants.cannonWidth
        cannon.frame = CGRectMake(gameViewWidth / 2 - cannonWidth / 2, gameViewHeight - cannonHeight, cannonWidth, cannonHeight)
        self.gameArea.addSubview(cannon)
        
        let rotationPoint = CGPoint(x: gameArea.frame.width / 2, y: gameArea.frame.height - Constants.radius)
        let anchorPoint =  CGPointMake((rotationPoint.x-cannon.frame.origin.x)/cannon.frame.width,
            (rotationPoint.y-cannon.frame.origin.y)/cannon.frame.height)
        cannon.layer.anchorPoint = anchorPoint;
        cannon.layer.position = rotationPoint;
        
      
    }
    
    private func setupBase() {
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        
        let baseImage = UIImage(named: Constants.cannonBaseLink)
        base = UIImageView(image: baseImage)
        let baseWidth = Constants.cannonBaseWidth
        let baseHeight = base.frame.height / base.frame.width * Constants.cannonBaseWidth
        base.frame = CGRectMake(gameViewWidth / 2 - baseWidth / 2, gameViewHeight - baseHeight, baseWidth, baseHeight)
        self.gameArea.addSubview(base)
    }
    
    private func setupGame(data: Array<Bubble>) {
        var models = Array<BubbleModel>()
        for item in data {
            models.append(item.getModel())
        }
        gameEngine = GameEngine(worldWidth: gameArea.frame.width, worldHeight: gameArea.frame.height,
            bubbleSize: Constants.bubbleSize, bubbles: models)
        
        var list = gameEngine!.getCurrentBubble()
        bubbles = Dictionary<Int, Bubble>()
        for bubbleData in list {
            bubbles[bubbleData.tag!] = Bubble(model: bubbleData)
            self.gameArea.addSubview(bubbles[bubbleData.tag!]!.getView())
        }
    }
    
    // set up notifications
    private func setupNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeBubbles:", name: Constants.removeBubbleMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startUpdating:", name: Constants.updateBubbleMesseage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopUpdating:", name: Constants.stopUpdateBubbleMessage, object: nil)
    }
    
    // get notifications and remove some bubbles with tags.
    func removeBubbles(sender: NSNotification) {
        let tags = sender.object as Array<Int>
        
        for tag in tags {
            var subview = bubbles[tag]!.getView()
            UIView.animateWithDuration(0.75, delay: 0, options:UIViewAnimationOptions.CurveEaseOut, animations: {() in
                subview.alpha = 0.0
            }, completion: nil)
            
            bubbles[tag] = nil
        }
    }
    
    // there is something to update. Call GameEngine each 1/60s to update
    func startUpdating(sender: NSNotification) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1/60, target: self,
            selector: Selector("update"), userInfo: nil, repeats: true);
    }
    
    // done updating. Stop until the next updating
    func stopUpdating(sender: NSNotification) {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    // Call GameEngine to update, get a list of updated bubbles.
    func update() {
        var list = gameEngine!.update()
        for tag in list {
            bubbles[tag]?.updateView()
        }
    }
    
    // set up tap handler.
    private func setupHandler() {
        let tapGesture = UITapGestureRecognizer(target: self, action:Selector("tapHandler:"))
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapHandler(sender: UITapGestureRecognizer) {
        let destination = sender.locationInView(sender.view)
        let angle = calculateAngle(destination)
        
        if gameEngine!.canFire(destination) && isRotating == false {
            isRotating = true
            UIView.animateWithDuration(0.6,
                delay: 0, options: .CurveLinear,
                animations: {
                    self.cannon.transform = CGAffineTransformMakeRotation(angle)
                }, completion: { finished in
                    self.fire(destination)
                    self.isRotating = false
                }
            )
        }
    }
    
    // fire the bubble.
    private func fire(destination: CGPoint) {
        prepareBullet()
        var newBubbles = gameEngine!.fire(destination)
        for bubbleData in newBubbles {
            bubbles[bubbleData.tag!] = Bubble(model: bubbleData)
            self.gameArea.addSubview(bubbles[bubbleData.tag!]!.getView())
        }
    }
    
    private func prepareBullet() {
        if let bullet = gameEngine?.getBullet() {
            let bulletView = bubbles[bullet.tag!]?.getView()
            self.gameArea.sendSubviewToBack(bulletView!)
            self.gameArea.sendSubviewToBack(background)
        }
    }
    
    private func calculateAngle(point: CGPoint) -> CGFloat{
        let v1 = CGVector(dx: 0, dy: -10)
        let v2 = CGVector(dx: point.x - gameArea.frame.width / 2,
            dy: point.y - gameArea.frame.height + Constants.radius)
       return atan2(v1.dx, v1.dy) - atan2(v2.dx, v2.dy)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}