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
    //let ffprobe = NSBundle.mainBundle().pathForResource("ffprobe", ofType: "")!
    
    func convert(path:String,size:CGSize) -> Bool
    {
        var component = (path as NSString).lastPathComponent.componentsSeparatedByString(".")
        let fileName = String(format: "%@.gif",component[0])
        
        let filePath = String(format: "%@/%@",folderPath,fileName)
        let fm = NSFileManager.defaultManager()
        do{
            try fm.removeItemAtPath(filePath)
        }catch{}
        
        /*
         ./ffmpeg -i in.mov -s 360x640 -pix_fmt rgb24 -r 12 -f gif - | gifsicle --optimize=3
         */
        
        //print(ffmpeg)
        //"-v","warning",
        let a = shell(ffmpeg,arguments:["-i",path,"-vf","fps=15,palettegen=stats_mode=diff","-y",palettePath])
        let b = shell(ffmpeg,arguments:["-i",path,"-i",palettePath,"-lavfi","fps=15 [x]; [x][1:v] paletteuse","-y",filePath])
        
        //print("======")
        //print(a)
        //print(".......")
        //print(a.containsString("Invalid data found when processing input"))
       if a.containsString("Invalid data found when processing input") == true ||
          b.containsString("Invalid data found when processing input") == true
       {
        //print("false!!!!")
        return false
        }
        else
       {
        //print("true!!!!")
        return true
        }
    }
    func debug(path:String)
    {
        //let arguments = ["-i",path,"-pix_fmt"]
        //let result = shell(ffmpeg,arguments:arguments)
        //print(result)

    }
    
//    func info(path:String) -> JSON
//    {
//        /*
//         http://stackoverflow.com/questions/7708373/get-ffmpeg-information-in-friendly-way
//         */
//        
//        let arguments = ["-v","quiet","-print_format","json","-show_format","-show_streams",path]
//        let result = shell(ffprobe,arguments:arguments)
//        
//        
//        let data = try? NSJSONSerialization.JSONObjectWithData(result.dataUsingEncoding(NSUTF8StringEncoding)!, options:.AllowFragments)
//        
//        return JSON(data!)
//    }
    
    
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
    task.standardError  = pipe
    task.launch()
    
    let data   = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
    
    //dup2(pipe.fileHandleForReading.fileDescriptor, <#T##Int32#>)
    
    
    /*
     NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
     dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
     */
    
    return output
}




