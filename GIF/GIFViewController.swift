//
//  ViewController.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa
import Foundation


class GIFViewController: NSViewController {
    
    
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
}

