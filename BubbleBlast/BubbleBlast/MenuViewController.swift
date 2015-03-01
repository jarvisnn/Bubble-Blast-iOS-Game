//
//  ViewController.swift
//  BubbleBlast
//
//  Created by kunn on 2/24/15.
//  Copyright (c) 2015 Jarvis. All rights reserved.
//

import UIKit
import AVFoundation

class MenuViewController: UIViewController {
    
    private var soundtrack = AVAudioPlayer()
    
    private func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        var path = NSBundle.mainBundle().pathForResource(file, ofType:type)
        var url = NSURL.fileURLWithPath(path!)
        var error: NSError?
        var audioPlayer:AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        return audioPlayer!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // setup soundtrack, hide the navigationBar
        navigationController?.navigationBarHidden = true
        soundtrack = setupAudioPlayerWithFile("soundtrack", type: "mp3")
        soundtrack.volume = 0.5;
        soundtrack.numberOfLoops = -1
        soundtrack.play()
    }
    
    override func viewDidAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}