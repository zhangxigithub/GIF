//
//  ViewController.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa
import Foundation


class ViewController: GIFViewController,DragDropViewDelegate,RangeSliderDelegate,NSTextFieldDelegate,PriviewDelegate {
    
    @IBOutlet weak var tipLabel: NSTextField!
    @IBOutlet weak var preview: Priview!
    @IBOutlet weak var bg: NSImageView!
    @IBOutlet weak var dragView: DragDropView!
    
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var slider: NSSlider!
    
    
    @IBOutlet weak var quality: NSPopUpButton!
    @IBOutlet weak var fps: NSPopUpButton!
    
    @IBOutlet weak var convertButton: NSButton!
    
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    
    @IBOutlet weak var widthLabel: NSTextField!
    @IBOutlet var heightLabel: NSTextField!
    
    
    var converter = ZXConverter()
    
    
    
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
    @IBAction func create(sender: NSButton) {
        
        if gif == nil
        {
            return
        }
        if sender.tag == 1
        {
            
        }else
        {
            return
        }
        sender.tag = 2
        sender.title = "Converting ..."
        
        
        
        gif!.fps = fps.selectedItem!.tag
       
        let minV = min(self.rangeSlider.startTime,self.rangeSlider.endTime)
        let maxV = max(self.rangeSlider.startTime,self.rangeSlider.endTime)
        let t   = maxV - minV
        
        gif!.range = (ss:String(format: "%.2f",minV),t:String(format: "%.2f",t))
        
        let qualityArray = [Quality.VeryLow,Quality.Low,Quality.Normal,Quality.High,Quality.VeryHigh]
        let index = self.quality.selectedItem!.tag-1
        gif!.quality = qualityArray[index]


        
        
        self.indicator.hidden = false
        self.indicator.startAnimation(nil)
        
        converter.convert(gif!, complete: {[unowned self]  (success,path) in
            

            self.indicator.hidden = true
            self.indicator.stopAnimation(nil)
            
            Swift.print(self.gif)
            
            if success
            {
                self.save(path!)
            }else
            {
                self.showErrorFile()
            }
            self.stopLoading()
            sender.tag = 1
            sender.title = "Convert To GIF"
        })
        
        
    }
    
    var gif : GIF?
    
    func loadFile(file: String)
    {
        
        
        self.startLoading()
        
        converter.loadGIF(file) { [unowned self] (gif,error) in
            

            
            print(gif)
            self.stopLoading()
            self.configOption(true)
            let info = gif.valid()
            if info.valid
            {
                self.gif = gif
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
        didClose()
        
        
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
        panel.beginWithCompletionHandler { [unowned self] (result) in
            
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
    
    func didClose() {
        preview.hidden = true
        convertButton.title = "Convert To GIF"
        convertButton.tag = 1
        self.indicator.stopAnimation(nil)
        self.converter.stop()
        self.converter = ZXConverter()
        self.gif = nil
        configOption(false)
    }

    func startLoading()
    {
        bg.image = NSImage(named: "bg_empty")
        indicator.hidden = false
        indicator.startAnimation(nil)
        
        self.tipLabel.stringValue = "loading"
    }
    func stopLoading()
    {
        self.bg.image = NSImage(named: "bg")
        self.indicator.hidden = true
        self.indicator.stopAnimation(nil)
        
        self.tipLabel.stringValue = ""
    }
    
    
    func didSelectRange(start: Int, end: Int) {
        print("\(start)  ...   \(end)")
    }
    func didSelectFrame(index: Int) {
        self.preview.frameIndex = index
    }
    
    func configOption(enable:Bool)
    {
        if enable
        {
            self.rangeSlider.enabled = true
            self.widthLabel.enabled = true
            self.heightLabel.enabled = true
            self.quality.enabled = true
            self.fps.enabled = true
        }else
        {
            self.rangeSlider.enabled = false
            self.widthLabel.enabled = false
            self.heightLabel.enabled = false
            self.quality.enabled = false
            self.fps.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        self.configOption(false)
        
        self.tipLabel.stringValue = ""
        
        self.dragView.delegate = self
        self.indicator.hidden = true
        self.rangeSlider.delegate = self
        self.preview.hidden = true
        self.preview.delegate = self
        
        self.fps.selectItemWithTag(12)
        self.quality.selectItemWithTag(1)

    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
            
        }
    }
    
    
}

