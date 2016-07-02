//
//  AppDelegate.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa

let folderPath  = NSHomeDirectory().stringByAppendingString("/gif")
let palettePath = NSHomeDirectory().stringByAppendingString("/palette.png")

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        
        let fm   = NSFileManager.defaultManager()
        
        do{
            try fm.createDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes: nil)
        }catch
        {
        }
        
        /*
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *appGroupName = @"Z123456789.com.example.app-group"; /* For example */
        
        NSURL *groupContainerURL = [fm containerURLForSecurityApplicationGroupIdentifier:appGroupName];
        NSError* theError = nil;
        if (![fm createDirectoryAtURL: groupContainerURL withIntermediateDirectories:YES attributes:nil error:&theError]) {
            // Handle the error.
        }
        
        */
    }
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false{
            
            for window in sender.windows{
                    window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }
    

    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

