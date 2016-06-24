//
//  ViewController.swift
//  STControl
//
//  Created by Eric Dolecki on 6/24/16.
//  Copyright © 2016 Eric Dolecki. All rights reserved.
//

import UIKit

/*
 
 This project does not include Bonjour Discovery. It currently
 uses a hardcoded IP address. You can find the IP of your speaker
 by using the Bose Controller Application, go to Settings > About.
 
 Or you can find it by pressing 5 and - on the presets cluster for
 five seconds and navigating the screens on the front of your speaker
 if it in fact has a screen. Use that IP address and note that it 
 could potentially change over time.
 
 Make sure the iDevice you're using is on the same Wi-Fi network as
 your speaker to make sure your calls to the speaker go through.
 
 */
class ViewController: UIViewController {

    var ipLabel: UILabel!
    var speakerIP: String = "192.168.1.170"
    var port: String = "8090"
    var powerButton: UIButton!
    var oneButton: UIButton!
    var twoButton: UIButton!
    var threeButton: UIButton!
    var volumeUpButton: UIButton!
    var volumeDownButton: UIButton!
    
    // We need to fetch this volume first.
    var speakerVolume: Int = 50
    var xmlParser:NSXMLParser?
    
    var POWER: String = "power"
    var PRESET_1: String = "string_1"
    var PRESET_2: String = "string_2"
    var PRESET_3: String = "string_3"
    var VOLUME_UP: String = "volume_up"
    var VOLUME_DOWN: String = "volume_down"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        getSpeakerVolume()
        
        ipLabel = UILabel(frame: CGRect(x: 0, y: 60, width: self.view.frame.width, height: 60))
        ipLabel.textAlignment = .Center
        ipLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 36.0)
        ipLabel.text = speakerIP
        ipLabel.textColor = UIColor.darkGrayColor()
        
        powerButton = UIButton(frame: CGRect(x: 40, y: 160, width: 60, height: 60))
        powerButton.setBackgroundImage(UIImage(named: "power.png"), forState: .Normal)
        powerButton.setBackgroundImage(UIImage(named: "power_press.png"), forState: .Highlighted)
        powerButton.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
        
        oneButton = UIButton(frame: CGRect(x: 120, y: 160, width: 60, height: 60))
        oneButton.setBackgroundImage(UIImage(named: "one.png"), forState: .Normal)
        oneButton.setBackgroundImage(UIImage(named: "one_press.png"), forState: .Highlighted)
        oneButton.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
        
        twoButton = UIButton(frame: CGRect(x: 210, y: 160, width: 60, height: 60))
        twoButton.setBackgroundImage(UIImage(named: "two.png"), forState: .Normal)
        twoButton.setBackgroundImage(UIImage(named: "two_press.png"), forState: .Highlighted)
        twoButton.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
        
        threeButton = UIButton(frame: CGRect(x: 300, y: 160, width: 60, height: 60))
        threeButton.setBackgroundImage(UIImage(named: "three.png"), forState: .Normal)
        threeButton.setBackgroundImage(UIImage(named: "three_press.png"), forState: .Highlighted)
        threeButton.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
        
        volumeUpButton = UIButton(frame: CGRect(x: 40, y: 240, width: 60, height: 60))
        volumeUpButton.setBackgroundImage(UIImage(named: "volup.png"), forState: .Normal)
        volumeUpButton.setBackgroundImage(UIImage(named: "volup_press.png"), forState: .Highlighted)
        volumeUpButton.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
        
        volumeDownButton = UIButton(frame: CGRect(x: 120, y: 240, width: 60, height: 60))
        volumeDownButton.setBackgroundImage(UIImage(named: "voldown.png"), forState: .Normal)
        volumeDownButton.setBackgroundImage(UIImage(named: "voldown_press.png"), forState: .Highlighted)
        volumeDownButton.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(ipLabel)
        self.view.addSubview(powerButton)
        self.view.addSubview(oneButton)
        self.view.addSubview(twoButton)
        self.view.addSubview(threeButton)
        self.view.addSubview(volumeUpButton)
        self.view.addSubview(volumeDownButton)
    }

    func buttonPressed(sender: UIButton)
    {
        if sender == powerButton {
            sendCommand(POWER)
        } else if sender == oneButton {
            sendCommand(PRESET_1)
        } else if sender == twoButton {
            sendCommand(PRESET_2)
        } else if sender == threeButton {
            sendCommand(PRESET_3)
        } else if sender == volumeUpButton {
            sendCommand(VOLUME_UP)
        } else if sender == volumeDownButton {
            sendCommand(VOLUME_DOWN)
        }
    }
    
    func sendCommand(param: String)
    {
        let url = NSURL(string:"http://\(speakerIP):\(port)/key")
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        var paramString = ""
        
        if param == POWER {
            paramString = "<key state=\"press\" sender=\"Gabbo\">POWER</key>"
        } else if param == PRESET_1 {
            paramString = "<key state=\"release\" sender=\"Gabbo\">PRESET_1</key>"
        } else if param == PRESET_2 {
            paramString = "<key state=\"release\" sender=\"Gabbo\">PRESET_2</key>"
        } else if param == PRESET_3 {
            paramString = "<key state=\"release\" sender=\"Gabbo\">PRESET_3</key>"
        } else if param == VOLUME_UP {
            paramString = "<key state=\"release\" sender=\"Gabbo\">VOLUME_UP</key>"
        } else if param == VOLUME_DOWN {
            paramString = "<key state=\"release\" sender=\"Gabbo\">VOLUME_DOWN</key>"
        }
    
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("dataString: '\(dataString!)'")
        }
        task.resume()
    }
    
    // A GET example to retreive data from the speaker.
    
    func getSpeakerVolume(){
        let url : String = "http://\(speakerIP):\(port)/volume"
        let thisURL = NSURL(string: url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(thisURL!) {(data, response, error) in
            let xmlString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            let xml = SWXMLHash.parse(xmlString as String)
            let val = xml["volume"]["actualvolume"].element?.text
            self.speakerVolume = Int(val!)!
            print(self.speakerVolume)
            print(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

