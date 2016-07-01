//
//  ZXConverter.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa
import Foundation

class ZXConverter: NSObject {
    
    let ffmpeg  = NSBundle.mainBundle().pathForResource("ffmpeg", ofType: "")!
    let ffprobe = NSBundle.mainBundle().pathForResource("ffprobe", ofType: "")!
    
    func convert(path:String,size:CGSize) -> String
    {
        /*
         ./ffmpeg -i in.mov -s 360x640 -pix_fmt rgb24 -r 12 -f gif - | gifsicle --optimize=3
         */
        
        
        let size = String(format:"%dx%d",Int(size.width),Int(size.height))
        let out  = NSHomeDirectory().stringByAppendingString("/Desktop/out.gif")
        
    
        let arguments = ["-i",path,"-s",size,"-pix_fmt","rgb8","-r","12","-f","gif",out]
      
        let result = shell(ffmpeg,arguments:arguments)
        
        
        return result
    }
    func info(path:String) -> JSON
    {
        /*
         http://stackoverflow.com/questions/7708373/get-ffmpeg-information-in-friendly-way
         */
        
        let arguments = ["-v","quiet","-print_format","json","-show_format","-show_streams",path]
        let result = shell(ffprobe,arguments:arguments)
        
        
        let data = try? NSJSONSerialization.JSONObjectWithData(result.dataUsingEncoding(NSUTF8StringEncoding)!, options:.AllowFragments)
        
        return JSON(data!)
    }
    
    func shell(launchPath: String, arguments: [String]? = nil) -> String
    {
        let task = NSTask()
        task.launchPath = launchPath
        if arguments == nil
        {
            task.arguments = [String]()
        }else
        {
            task.arguments = arguments
        }
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        
        let data   = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
        
        return output
    }
    
    
}
