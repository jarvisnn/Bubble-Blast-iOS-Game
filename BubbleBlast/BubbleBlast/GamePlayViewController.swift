//
//  ViewController.swift
//  GameEngine
//
//  Created by kunn on 2/12/15.
//  Copyright (c) 2015 Jarvis. All rights reserved.
//

import UIKit
import AVFoundation

/*
    GamePlay screen.
*/
class GamePlayViewController: UIViewController {
    
    @IBOutlet var gameArea: UIView!
    
    private var bubbles = Dictionary<Int, Bubble>()
    private var gameEngine : GameEngine?
    private var timer: NSTimer?
    
    private var isRotating = false
    private var lastTouchedPoint = CGPoint(x: Constants.ipadWidth / 2, y: 0)
    
    private var cannonAnimations = Array<UIImage>()
    private var burstingAnimations = Array<UIImage>()
    private var background = UIImageView()
    private var cannon = UIImageView()
    private var base = UIImageView()
    private var laserBullet = UIImageView()
    private var barrier = UIImageView()
    private var lasers = Array<UIImageView?>(count: Constants.maxLasers, repeatedValue: nil)
    
    private var rotationPoint = CGPoint(x: 0, y: 0)
    
    private var dataForGame = Array<Bubble>()
    
    private var soundBubbleBursting = AVAudioPlayer()
    private var soundBubbleHitting = AVAudioPlayer()
    private var soundCannonFiring = AVAudioPlayer()
    
    func setData(data: Array<Bubble>) {
        self.dataForGame = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setupSounds()
        setupBackground()
        setupCannon()
        setupBase()
        setupBarrier()
        setupLaser()
        setupOrder()
        extractBubbleBurstAnimation()
        setupNotification()
        setupHandler()
        setupGame(dataForGame)
    }
    
    // we need some animation at the beginning so we start the game in viewDidAppear.
    override func viewDidAppear(animated: Bool) {
        gameEngine!.reformat()
    }
    
    // setup sound for sound animations.
    private func setupSounds() {
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
    }
    
    private func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        var path = NSBundle.mainBundle().pathForResource(file, ofType:type)
        var url = NSURL.fileURLWithPath(path!)
        var error: NSError?
        var audioPlayer:AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        return audioPlayer!
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
    
    // setup cannon
    private func setupCannon() {
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        
        // extract cannon shot in the big photo.
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
        
        // setup anchorPoint for rotating.
        rotationPoint = CGPoint(x: gameArea.frame.width / 2, y: gameArea.frame.height - Constants.radius)
        let anchorPoint =  CGPointMake((rotationPoint.x-cannon.frame.origin.x)/cannon.frame.width,
            (rotationPoint.y-cannon.frame.origin.y)/cannon.frame.height)
        cannon.layer.anchorPoint = anchorPoint;
        cannon.layer.position = rotationPoint;
    }
    
    // setup Base of the cannon
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
    
    // setup the barrier that divide the screen.
    private func setupBarrier() {
        let barrierImage = UIImage(named: Constants.barrierLink)
        barrier = UIImageView(image: barrierImage)
        barrier.frame = CGRectMake(0, Constants.barrier + 18, Constants.ipadWidth, 30)
        self.gameArea.addSubview(barrier)
    }
    
    // setup laser.
    private func setupLaser() {
        let laserBulletImage = UIImage(named: Constants.laserBullet)
        laserBullet = UIImageView(image: laserBulletImage)
        laserBullet.frame = CGRectMake(0, 0, Constants.bubbleSize / 2, Constants.bubbleSize / 2)
        laserBullet.hidden = true
        self.gameArea.addSubview(laserBullet)
    }
    
    // setup necessary orders of the view
    private func setupOrder() {
        self.gameArea.bringSubviewToFront(cannon)
        self.gameArea.bringSubviewToFront(base)
    }
    
    // extract shots for bursting animation.
    private func extractBubbleBurstAnimation() {
        let burstings = UIImage(named: Constants.bubbleBurstLink)!
        for var i = 0; i < 4; i++ {
            let cropRect = CGRectMake(burstings.size.width / 4 * CGFloat(i), 0,
                burstings.size.width / 2, burstings.size.height)
            let imageRef = CGImageCreateWithImageInRect(burstings.CGImage, cropRect)
            burstingAnimations.append(UIImage(CGImage: imageRef)!)
        }
    }
    
    // setup game
    func setupGame(data: Array<Bubble>) {
        var models = Array<BubbleModel>()
        for item in data {
            models.append(item.getModel())
        }
        gameEngine = GameEngine(worldWidth: gameArea.frame.width, worldHeight: gameArea.frame.height,
            bubbleSize: Constants.bubbleSize, bubbles: models)
    }
    
    // set up notifications
    private func setupNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bubbleHitting:", name: Constants.bubbleHitting, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bubbleBursting:", name: Constants.bubbleBursting, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameOver:", name: Constants.gameOverMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addBubbles:", name: Constants.addBubbleMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeBubbles:", name: Constants.removeBubbleMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startUpdating:", name: Constants.updateBubbleMesseage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopUpdating:", name: Constants.stopUpdateBubbleMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cannonFiring:", name: Constants.cannonFiring, object: nil)
    }
    
    func bubbleHitting(sender: NSNotification) {
        soundBubbleHitting = setupAudioPlayerWithFile("bubble-hitting", type: "wav")
        soundBubbleHitting.volume = 1
        soundBubbleHitting.play()
    }
    
    func bubbleBursting(sender: NSNotification) {
        soundBubbleBursting = setupAudioPlayerWithFile("bubble-pop", type: "wav")
        soundBubbleBursting.volume = 1
        soundBubbleBursting.play()
    }
    
    func gameOver(sender: NSNotification) {
        var alert = UIAlertController(title: "Game Over !!!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addBubbles(sender: NSNotification) {
        var data = sender.object as BubbleModel
        bubbles[data.tag!] = Bubble(model: data)
        self.gameArea.addSubview(bubbles[data.tag!]!.getView())
    }
    
    // get notifications and remove some bubbles with tags.
    func removeBubbles(sender: NSNotification) {
        let tags = sender.object as Array<Int>
        for var i = 0; i < tags.count; i++ {
            var subview = bubbles[tags[i]]!.getView()
            
            subview.image = UIImage(named: Constants.transparentImage)
            subview.animationImages = burstingAnimations
            subview.animationDuration = 0.4
            subview.animationRepeatCount = 1
            subview.startAnimating()

            bubbles[tags[i]] = nil
        }
    }
    
    func cannonFiring(sender: NSNotification) {
        self.cannon.animationImages = cannonAnimations
        self.cannon.animationDuration = 0.5
        self.cannon.animationRepeatCount = 1
        self.cannon.startAnimating()
        
        soundCannonFiring = setupAudioPlayerWithFile("cannon-firing", type: "wav")
        soundCannonFiring.volume = 1
        soundCannonFiring.play()
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
        self.updateLaser()
        for (index, bubble) in bubbles {
            if bubble.getModel().coordinate.y > Constants.barrier
                    && bubble.getModel().coordinate.y < Constants.ipadHeight - Constants.bubbleSize {
                gameEngine!.setGameOver()
            }
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
        
        let panGesture = UIPanGestureRecognizer(target: self, action:Selector("panHandler:"))
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(panGesture)
    }
    
    // tap handler
    func tapHandler(sender: UITapGestureRecognizer) {
        let destination = sender.locationInView(sender.view)
        lastTouchedPoint = destination
        let vt = CGVector(dx: destination.x - rotationPoint.x, dy: destination.y - rotationPoint.y)
        let angle = calculateAngle(vt)
        
        if gameEngine!.canFire(destination) && isRotating == false {
            isRotating = true
            let laserPath = gameEngine!.getLaserPath(rotationPoint, vt: vt)
            removeLasers()
            UIView.animateWithDuration(0.3,
                delay: 0, options: .CurveLinear,
                animations: {
                    self.cannon.transform = CGAffineTransformMakeRotation(angle)
                }, completion: { finished in
                    self.fire(destination)
                    self.isRotating = false
                    self.lastTouchedPoint = destination
                    self.updateLaser()
                }
            )
        }
    }
    
    // drag handler
    func panHandler(sender: UIPanGestureRecognizer) {
        let touchedPoint = sender.locationInView(self.view)
        let p = CGPoint(x: touchedPoint.x, y: min(touchedPoint.y, Constants.barrier+Constants.radius))
        lastTouchedPoint = p
        let vt = CGVector(dx: p.x - rotationPoint.x, dy: p.y - rotationPoint.y)
        let angle = calculateAngle(vt)
        
        switch sender.state {
        case .Ended:
            self.updateLaser()
            self.cannon.transform = CGAffineTransformMakeRotation(angle)
            if gameEngine!.canFire(p) {
                self.fire(p)
            }
        default:
            self.updateLaser()
            self.cannon.transform = CGAffineTransformMakeRotation(angle)
        }
    }
    
    // remove lasers
    private func removeLasers() {
        laserBullet.hidden = true
        for var i = 0; i < Constants.maxLasers; i++ {
            if lasers[i] != nil {
                lasers[i]?.removeFromSuperview()
            }
        }
    }
    
    // update lasers
    private func updateLaser() {
        let vt = CGVector(dx: lastTouchedPoint.x-rotationPoint.x, dy: lastTouchedPoint.y-rotationPoint.y)
        let points = gameEngine!.getLaserPath(rotationPoint, vt: vt)
        createLasers(points)
    }
    
    // create lasers and add to view.
    private func createLasers(points: Array<CGPoint>) {
        removeLasers()
        
        for var i = 0; i < points.count - 2; i++ {
            let laserWidth = CGFloat(5)
            let laserImage = UIImage(named: Constants.laserLink)
            let laserLeng = distance(points[i], point2: points[i+1])
            
            lasers[i] = UIImageView(image: laserImage)
            lasers[i]!.frame = CGRectMake(points[i].x, points[i].y - laserLeng, laserWidth, laserLeng)
            
            let angle = calculateAngle(CGVector(dx: points[i+1].x-points[i].x, dy: points[i+1].y-points[i].y))
            let rotationPoint = points[i]
            let anchorPoint = CGPointMake((rotationPoint.x-lasers[i]!.frame.origin.x)/lasers[i]!.frame.width,
                (rotationPoint.y-lasers[i]!.frame.origin.y)/lasers[i]!.frame.height)
            lasers[i]!.layer.anchorPoint = anchorPoint
            lasers[i]!.layer.position = rotationPoint
            lasers[i]!.transform = CGAffineTransformMakeRotation(angle)
            
            self.gameArea.addSubview(lasers[i]!)
            self.gameArea.sendSubviewToBack(lasers[i]!)
            self.gameArea.sendSubviewToBack(background)
        }
        
        laserBullet.frame = CGRectMake(points[points.count - 1].x - Constants.bubbleSize/2, points[points.count - 1].y - Constants.bubbleSize/2,
            Constants.bubbleSize, Constants.bubbleSize)
        laserBullet.hidden = false
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
    
    // prepare the bullet to fire
    private func prepareBullet() {
        if let bullet = gameEngine?.getBullet() {
            let bulletView = bubbles[bullet.tag!]?.getView()
            self.gameArea.sendSubviewToBack(bulletView!)
            self.gameArea.sendSubviewToBack(laserBullet)
            self.gameArea.sendSubviewToBack(barrier)
            self.gameArea.sendSubviewToBack(background)
        }
    }
    
    // help functions
    private func calculateAngle(vt: CGVector) -> CGFloat{
        let v1 = CGVector(dx: 0, dy: -10)
        let v2 = vt
       return atan2(v1.dx, v1.dy) - atan2(v2.dx, v2.dy)
    }
    
    private func distance(point1: CGPoint, point2: CGPoint) -> CGFloat{
        return length(CGVector(dx: point1.x-point2.x, dy: point1.y-point2.y))
    }
    
    private func length(vector: CGVector) -> CGFloat {
        return sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}