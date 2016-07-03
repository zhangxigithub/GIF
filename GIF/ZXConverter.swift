//
//  ZXConverter.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa
import Foundation

class GIF: NSObject
{
    var path : String!
    var thumb : [String]!
    var duration:NSTimeInterval!
    var width:CGFloat!
    var height:CGFloat!
    
}


class ZXConverter: NSObject {
    
    let ffmpeg  = NSBundle.mainBundle().pathForResource("ffmpeg", ofType: "")!
    let ffprobe = NSBundle.mainBundle().pathForResource("ffprobe", ofType: "")!
    
    func convert(path:String,complete:(success:Bool,path:String?)->Void)
    {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            
            var component = (path as NSString).lastPathComponent.componentsSeparatedByString(".")
            let fileName = String(format: "%@.gif",component[0])
            
            let filePath = String(format: "%@/%@",folderPath,fileName)
            let fm = NSFileManager.defaultManager()
            do{
                try fm.removeItemAtPath(filePath)
                try fm.removeItemAtPath(palettePath)
            }catch{}

            /*
             
             -i $1 -vf "fps=15,scale=320:-1:flags=lanczos,palettegen=stats_mode=diff" -y $palette2
             -i $1 -i $palette2 -lavfi "fps=15,scale=320:-1:flags=lanczos [x]; [x][1:v] paletteuse" -gifflags +transdiff -y 3$2

             //scale=320:-1:flags=lanczos

             
             low quality:
             ./ffmpeg -i $1 -lavfi "fps=15" -gifflags +transdiff -y 5$2
             
             */
            let a = shell(self.ffmpeg,arguments:["-i",path,"-vf","fps=12,scale=320:-1:flags=lanczos,palettegen=stats_mode=diff","-y",palettePath])
            
            let b = shell(self.ffmpeg,arguments:["-i",path,"-i",palettePath,"-lavfi","fps=12,scale=320:-1:flags=lanczos  [x]; [x][1:v] paletteuse","-gifflags","+transdiff","-y",filePath])
            
            //print(palettePath)
            //print(a)
            //print(".......")
            //print(a.containsString("Invalid data found when processing input"))
            
            dispatch_async(dispatch_get_main_queue()) {
                
                
                if a.containsString("Invalid data found when processing input") == true ||
                    b.containsString("Invalid data found when processing input") == true
                {
                    //print("false!!!!")
                    complete(success: false,path: nil)
                }
                else
                {
                    //print("true!!!!")
                    complete(success: true,path:filePath)
                }
            }
            
        })
    }
    
    

    
    
    func debug(path:String)
    {
        //let arguments = ["-i",path,"-pix_fmt"]
        //let result = shell(ffmpeg,arguments:arguments)
        //print(result)

    }
    
    func loadGIF(path:String,complete:(gif:GIF?,err:String)->Void)
    {
        /*
         http://stackoverflow.com/questions/7708373/get-ffmpeg-information-in-friendly-way
         */
        
        
        let fm = NSFileManager.defaultManager()
        if let dir = try? fm.attributesOfItemAtPath(path)
        {
            let size = (dir[NSFileSize] as! NSNumber).floatValue/(1024*1024)
            print(size)
            if size > 100
            {
                complete(gif: nil, err: "GIF Works can only convert file less than 100MB.")
                return
            }
        }
        
        /*
         NSArray *attributes = [NSArray arrayWithObjects:NSURLFileSizeKey,NSURLContentModificationDateKey,nil];
         
         //获得返回的结果
         //anURL是一个NSURL对象，想要了解的文件（夹）
         //这里不关心出错信息
         NSDictionary *attributesDictionary = [anURL resourceValuesForKeys:attributes error:nil];
         */
        
        
        
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            
            let arguments = ["-v","quiet","-print_format","json","-show_format","-show_streams",path]
            let result = shell(self.ffprobe,arguments:arguments)
            let data = try? NSJSONSerialization.JSONObjectWithData(result.dataUsingEncoding(NSUTF8StringEncoding)!, options:.AllowFragments)
            
            if data != nil
            {
                let gif = GIF()
                let json = JSON(data!)
                
                print(json)
                
                gif.path = path
                gif.width    = CGFloat(json["streams"][0]["width"].floatValue)
                gif.height   = CGFloat(json["streams"][0]["height"].floatValue)
                gif.duration = json["format"]["duration"].doubleValue
                
                //542 309
                
                var scale = ""
                if gif.width/542 <  gif.height/309
                {
                    scale = "scale=-1:309"
                }else
                {
                    scale = "scale=542:-1"
                }
                
                
                
                
                let fm = NSFileManager.defaultManager()
                let _ = try? fm.removeItemAtPath(thumbPath)
                let _ = try? fm.createDirectoryAtPath(thumbPath, withIntermediateDirectories: true, attributes: nil)
                
                
                var r = 36/gif.duration
                r = min(r,6)
                r = max(r,1)
                let arguments =  ["-i",path,"-r",String(format:"%.0d",Int(r)),"-vf",scale,thumbPath.stringByAppendingString("/t%5d.jpg")]
                shell(self.ffmpeg,arguments:arguments)
                
                var files = [String]()
                do{
                    if let a = try? fm.contentsOfDirectoryAtPath(thumbPath)
                    {
                        for item in a
                        {
                            files.append(String(format:"%@/%@",thumbPath,item))
                        }
                    }
                }
                gif.thumb = files
                
                dispatch_async(dispatch_get_main_queue()) {
                    complete(gif: gif, err: "")
                }
                
            }else
            {
                dispatch_async(dispatch_get_main_queue()) {
                    complete(gif: nil, err: "convert error.")
                }
            }
        })

    }
    
    
    
    
    func thumb(path:String,complete:(dir:[String]?)->Void)
    {
        //./ffmpeg -i 1.mp3 -vf scale=100:-1 example.%d.jpg
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            
            let fm = NSFileManager.defaultManager()
            do{
                try fm.removeItemAtPath(thumbPath)
                try fm.createDirectoryAtPath(thumbPath, withIntermediateDirectories: true, attributes: nil)
            }catch{}
            
            
            
            let arguments =  ["-i",path,"-r","6","-vf","scale=200:-1",thumbPath.stringByAppendingString("/t%5d.jpg")]
            let _ = shell(self.ffmpeg,arguments:arguments)
            //print(result)
            
            var files = [String]()
            do{
                if let a = try? fm.contentsOfDirectoryAtPath(thumbPath)
                {
                    for item in a
                {
                    files.append(String(format:"%@/%@",thumbPath,item))
                }
                }
            }
            


            dispatch_async(dispatch_get_main_queue()) {
                complete(dir: files)
            }
            
        })

    }
    
    
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

/*
 
 
 dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
 

 dispatch_async(dispatch_get_main_queue()) {

 }
 
 })
 
 */



