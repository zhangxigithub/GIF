//
//  ViewController.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa
import Foundation


class ViewController: GIFViewController,DragDropViewDelegate,RangeSliderDelegate,NSTextFieldDelegate {
    
    @IBOutlet weak var preview: Priview!
    @IBOutlet weak var bg: NSImageView!
    @IBOutlet weak var dragView: DragDropView!
    
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var slider: NSSlider!
    
    
    @IBOutlet weak var quality: NSPopUpButton!
    @IBOutlet weak var fps: NSPopUpButton!
    
    
    
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    
    @IBOutlet weak var widthLabel: NSTextField!
    @IBOutlet var heightLabel: NSTextField!
    
    
    
    override func controlTextDidChange(obj: NSNotification) {
        
        if gif == nil
        {
            return
        }
        
        if let textField = obj.object as? NSTextField
        {
            let value = CGFloat(textField.floatValue)
            print(value)
            
            
            if lock
            {
                if textField == widthLabel
                {
                    heightLabel.integerValue = Int(value * gif!.size.height / gif!.size.width)
                }else
                {
                    widthLabel.integerValue  = Int(value * gif!.size.width / gif!.size.height)
                }
            }
            
            gif?.wantSize = CGSizeMake(CGFloat(widthLabel.floatValue), CGFloat(heightLabel.floatValue))
            
    
            
        }
    }
    
    
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
        
        if gif == nil
        {
            return
        }
        
        gif!.fps = fps.selectedItem!.tag
        
        
        gif!.range = (ss:String(format: "%.2f",min(self.rangeSlider.startTime,self.rangeSlider.endTime)),to:String(format: "%.2f",max(self.rangeSlider.startTime,self.rangeSlider.endTime)))
        

        switch self.quality.selectedItem?.tag ?? 0{
        case 1: gif!.quality = Quality.VeryLow
        case 2: gif!.quality = Quality.Low
        case 3: gif!.quality = Quality.Normal
        case 4: gif!.quality = Quality.High
        case 5: gif!.quality = Quality.VeryHigh
        default: break
        }
        bg.image = NSImage(named: "loading")
        indicator.hidden = false
        indicator.startAnimation(nil)
        
        Swift.print(fps.selectedItem)
        
        let c = ZXConverter()
        
        c.convert(gif!, complete: { (success,path) in
            
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
    
    func loadFile(file: String)
    {
        
        let c = ZXConverter()
        
        self.startLoading()
        
        c.loadGIF(file) { (gif,error) in
            
            print(gif)
            
            let info = gif.valid()
            if info.valid
            {
                self.gif = gif
                self.startLoading()
                self.showPreview(gif)
                self.configOptions(gif)
            }else
            {
                self.showError(info.error)
            }
        }
        
    }

    
    func receivedFiles(file: String)
    {
        self.loadFile(file)
    }
    
    func configOptions(gif:GIF)
    {
        self.widthLabel.stringValue = String(format:"%0.f",gif.size.width   ?? 0)
        self.heightLabel.stringValue = String(format:"%0.f",gif.size.height ?? 0)
    }
    
    func showPreview(gif:GIF)
    {
        self.preview.hidden = false
        self.preview.images = gif.thumb
        

        self.rangeSlider.durationTime = gif.duration
        self.rangeSlider.frames = gif.thumb.count - 1
        self.rangeSlider.reset()
        
    }
    

    
    
    func save(file:String)
    {
        Swift.print(file)
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
        
        self.fps.selectItemWithTag(12)
        self.quality.selectItemWithTag(1)

    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
            
        }
    }
    
    
}

