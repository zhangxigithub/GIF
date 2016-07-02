//
//  ViewController.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa
import Foundation


class ViewController: NSViewController,DragDropViewDelegate {
    
    @IBOutlet weak var bg: NSImageView!
    @IBOutlet weak var dragView: DragDropView!
    
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    func receivedFiles(file: String) {
        
        
        bg.image = NSImage(named: "loading")
        indicator.hidden = false
        indicator.startAnimation(nil)
        
        
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            
            
            
            let c = ZXConverter()
            
            //let info = c.info(file)
            //let width:CGFloat  = CGFloat(info["streams"][0]["width"].floatValue)
            //let height:CGFloat = CGFloat(info["streams"][0]["height"].floatValue)
            //let size = CGSizeMake(width, height)
            
            
            let success = c.convert(file, size: CGSizeZero)
            dispatch_async(dispatch_get_main_queue()) {
                
                if success
                {
                    NSWorkspace.sharedWorkspace().openFile(folderPath)
                }else
                {
                    self.showErrorFile()
                }
                self.bg.image = NSImage(named: "bg")
                self.indicator.hidden = true
                self.indicator.stopAnimation(nil)
            }
            
        })
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
        alert.messageText = "Error,only mov file can be accepted."
        alert.addButtonWithTitle("OK")
        
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil )
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dragView.delegate = self
        self.indicator.hidden = true
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

