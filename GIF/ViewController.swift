//
//  ViewController.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa
import Foundation


class ViewController: NSViewController,DragDropViewDelegate,RangeSliderDelegate {
    
    @IBOutlet weak var preview: Priview!
    @IBOutlet weak var bg: NSImageView!
    @IBOutlet weak var dragView: DragDropView!
    
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var slider: NSSlider!
    
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    //var thumb:[String]!
    
    //var gifFile:String?
    
    var lock:Bool = true{
        didSet{
            self.lockButton.image = NSImage(named: (lock == true) ? "lock" : "unlock")
        }
    }
    
    
    @IBOutlet weak var lockButton: NSButton!
    
    @IBAction func clickLock(sender: NSButton) {
        self.lock = !self.lock
    }
    @IBAction func create(sender: AnyObject) {
        
        bg.image = NSImage(named: "loading")
        indicator.hidden = false
        indicator.startAnimation(nil)
        
        
        let c = ZXConverter()
        
        c.convert(gif!.path, complete: { (success,path) in
            
            if success
            {
                self.save(path!)
            }else
            {
                self.showErrorFile()
            }
            self.stopLoading()
        })
        
        
    }
    
    var gif : GIF?
    
    func receivedFiles(file: String) {
        
        
        self.startLoading()

        let c = ZXConverter()
        

        c.loadGIF(file) { (gif,error) in
            print(gif)
            
            if gif != nil
            {
                self.gif = gif
                self.startLoading()
                self.showPreview(gif!)
            }else
            {
                self.showError(error)
            }
        }
        
    }
    
    func showPreview(gif:GIF)
    {
        self.preview.hidden = false
        self.preview.images = gif.thumb
        
        
        
        
        self.rangeSlider.durationTime = gif.duration
        self.rangeSlider.frames = gif.thumb.count - 1
        self.rangeSlider.reset()
        
        
    }
    
    func startLoading()
    {
        bg.image = NSImage(named: "loading")
        indicator.hidden = false
        indicator.startAnimation(nil)
    }
    func stopLoading()
    {
        self.bg.image = NSImage(named: "bg")
        self.indicator.hidden = true
        self.indicator.stopAnimation(nil)
    }

    

    func showError(msg:String)
    {
        let alert = NSAlert()
        alert.messageText = msg
        alert.addButtonWithTitle("OK")
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil )
    }
    func showErrorFile()
    {
        let alert = NSAlert()
        alert.messageText = "Error,only mov file can be accepted."
        alert.addButtonWithTitle("OK")
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil )
    }
    func receivedErrorType(file:String)
    {
        let alert = NSAlert()
        alert.messageText = "Error,only video file can be accepted."
        alert.addButtonWithTitle("OK")
        
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil )
    }
    
    func save(file:String)
    {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = (file as NSString).lastPathComponent
        panel.beginWithCompletionHandler { (result) in
            
            if result == NSFileHandlingPanelOKButton
            {
                let fm  = NSFileManager.defaultManager()
                if let url = panel.URL
                {
                    if let path = url.path
                    {
                        do {
                        try fm.copyItemAtPath(file, toPath: path)
                        }catch{}
                    }
                }
                
            }
        }
    }

    
    
    
    func didSelectRange(start: Int, end: Int) {
        print("\(start)  ...   \(end)")
    }
    func didSelectFrame(index: Int) {
        self.preview.frameIndex = index
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dragView.delegate = self
        self.indicator.hidden = true
        self.rangeSlider.delegate = self
        self.preview.hidden = true
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
            
        }
    }
    
    
}

