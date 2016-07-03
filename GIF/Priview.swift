//
//  Priview.swift
//  GIF
//
//  Created by 张玺 on 7/2/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa

class Priview: NSView {

    var images:[String]!
        {
        didSet{
            self.frameIndex = 0
        }
    }
    var frameIndex:Int = 0
        {
        didSet{
            if frameIndex < self.images.count
            {
                Swift.print(frameIndex)
                Swift.print(self.images[frameIndex])
                previewImage.image = NSImage(contentsOfFile: self.images[frameIndex])
            }
        }
    }
    
    var previewImage:NSImageView!
    
    var backView = NSView(frame:NSMakeRect(0,0,0,0))
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
     
        //backView.layer?.backgroundColor = NSColor.blackColor().CGColor
        //backView.frame = self.bounds
        //self.addSubview(backView)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.blackColor().CGColor
        
        previewImage = NSImageView(frame: self.bounds)
        previewImage.wantsLayer = true
        self.addSubview(previewImage)
        
        let frame = NSMakeRect(self.bounds.size.width - 50,self.bounds.size.height - 50,40,40)
        let close = NSButton(frame: frame)
        close.bezelStyle = .DisclosureBezelStyle
        close.bordered = false
        //close.layer?.backgroundColor = NSColor.clearColor().CGColor
        close.image = NSImage(named: "close")
        //close.wantsLayer = true
        close.target = self
        close.action = #selector(self.close)
        self.addSubview(close)
        
    }
    func close()
    {
        self.hidden = true
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
