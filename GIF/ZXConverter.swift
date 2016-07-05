//
//  ZXConverter.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa
import Foundation

enum Quality {
    case VeryLow
    case Low
    case Normal
    case High
    case VeryHigh
    
    func lossy() -> String{
        switch self {
        case VeryLow:
            return ""
        case Low:
            return "80"
        case Normal:
            return "30"
        case High:
            return "10"
        case VeryHigh:
            return ""
        }
    }
    
    func needCompress() -> Bool
    {
        return ((self != .VeryLow ) && (self != .VeryHigh))
    }
    
}

class GIF: NSObject
{
    var range : (ss:String,to:String)? = nil
    var quality : Quality = .Normal
    var fps:Int = 12
    
    
    
    var palettePath : String!
    var gifFileName : String!
    var gifPath : String!
    var comporesGifPath : String!
    var fileName : String!
    var path : String!{
        didSet{
            self.fileName         = (path as NSString).lastPathComponent
            self.gifFileName      = String(format: "%@.gif",NSUUID().UUIDString)
            self.gifPath          = String(format: "%@/%@",folderPath,gifFileName)
            self.comporesGifPath  = String(format: "%@/c_%@",folderPath,gifFileName)
            self.palettePath      = String(format: "%@/p_%@",folderPath,gifFileName)
        }
    }
    var thumb : [String]!
    var duration:NSTimeInterval!
    
    
    var size:CGSize!{
        didSet{
            wantSize = size
        }
    }
    var wantSize:CGSize?
    
    
    override var description: String
        {
        get{
            return "=====================\npath:\(path)\nfileName:\(fileName)\ngifFileName:\(gifFileName)\nduration:\(duration)\nvideoSize:\(size)\nwantSize:\(wantSize)\nframes:\(thumb?.count)\n\n====================="
        }
    }
    func  valid() -> (valid:Bool,error:String) {

        if path == nil
        {
            return  (valid:false,error:"Can't get the file.")
        }
        
        if thumb == nil
        {
            return  (valid:false,error:"Can't create thumbnails.")
        }
        if duration == nil
        {
            return  (valid:false,error:"Can't get duration info.")
        }
        if wantSize == nil
        {
            return  (valid:false,error:"Can't get video width.")
        }

        if size == nil
        {
            return  (valid:false,error:"Can't get video height.")
        }
        return (valid:true,error:"Sucess")
    }
    func clean()
    {
        let fm  = NSFileManager.defaultManager()
        do{
            try fm.removeItemAtPath(gifPath)
            try fm.removeItemAtPath(comporesGifPath)
            try fm.removeItemAtPath(palettePath)
        }catch{}
    }
}

/*
 http://blog.csdn.net/stone_wzf/article/details/45570021


 
 -i $1 -vf "fps=15,scale=320:-1:flags=lanczos,palettegen=stats_mode=diff" -y $palette2
 -i $1 -i $palette2 -lavfi "fps=15,scale=320:-1:flags=lanczos [x]; [x][1:v] paletteuse" -gifflags +transdiff -y 3$2
 
 //scale=320:-1:flags=lanczos
 
 
 low quality:
 ./ffmpeg -i $1 -lavfi "fps=15" -gifflags +transdiff -y 5$2
 
 */
class ZXConverter: NSObject {
    
    let ffmpeg   = NSBundle.mainBundle().pathForResource("ffmpeg", ofType: "")!
    let ffprobe  = NSBundle.mainBundle().pathForResource("ffprobe", ofType: "")!
    let gifsicle = NSBundle.mainBundle().pathForResource("gifsicle", ofType: "")!
    let fm       = NSFileManager.defaultManager()
  
    
    func convert(gif:GIF,complete:(success:Bool,path:String?)->Void)
    {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            
            print(gif.description)
            gif.clean()
            
            var result = ""
            let size = gif.wantSize ?? gif.size
            
            if gif.quality == .VeryLow
            {
                 var arguments = [String]()
                arguments += ["-i",gif.path,"-lavfi"]
                if size != nil
                {
                    arguments.append(String(format: "fps=%d,scale=%d:%d:flags=lanczos",Int(gif.fps),Int(size!.width),Int(size!.height)))
                }else
                {
                    arguments.append(String(format: "fps=%d",Int(gif.fps)))
                }
                
                if gif.range != nil
                {
                    arguments  = ["-ss",gif.range!.ss] + arguments //+ ["to",gif.range!.to]
                    arguments  = arguments + ["to",gif.range!.to]
                }else
                {
                }
                
                arguments += ["-gifflags","+transdiff","-y",gif.gifPath]

                result = result + shell(self.ffmpeg,arguments:arguments)
            }else
            {
                var vf    = ""
                var lavfi = ""
                
                if size != nil
                {
                    vf = String(format: "fps=%d,scale=%d:%d:flags=lanczos,palettegen=stats_mode=diff",Int(gif.fps),Int(size!.width),Int(size!.height))
                    lavfi = String(format: "fps=%d,scale=%d:%d:flags=lanczos  [x]; [x][1:v] paletteuse=dither=floyd_steinberg",Int(gif.fps),Int(size!.width),Int(size!.height))
                }else{
                    vf = String(format: "fps=%d,palettegen=stats_mode=diff",Int(gif.fps))
                    lavfi = String(format: "fps=%d [x]; [x][1:v] paletteuse=dither=floyd_steinberg",Int(gif.fps))
                }

                if gif.range == nil
                {
                    result = result + shell(self.ffmpeg,arguments:["-i",gif.path,"-vf",vf,"-y",gif.palettePath])
                    result = result + shell(self.ffmpeg,arguments:["-i",gif.path,"-i",gif.palettePath,"-lavfi",lavfi,"-gifflags","+transdiff","-y",gif.gifPath])
                }else
                {
                    result = result + shell(self.ffmpeg,arguments:["-ss",gif.range!.ss,"-i",gif.path,"-to",gif.range!.to,"-vf",vf,"-y",gif.palettePath])
                    result = result + shell(self.ffmpeg,arguments:["-ss",gif.range!.ss,"-i",gif.path,"-to",gif.range!.to,"-i",gif.palettePath,"-lavfi",lavfi,"-gifflags","+transdiff","-y",gif.gifPath])
                }
                
                

            
            }
            
            if gif.quality.needCompress()
            {
                self.compress(gif)
            }
            
            



            dispatch_async(dispatch_get_main_queue()) {
            
                let path = (gif.quality.needCompress()) ? gif.comporesGifPath : gif.gifPath
                
                if self.fm.fileExistsAtPath(path)
                {
                    complete(success: true,path: path)
                }else
                {
                    complete(success: false,path: nil)
                }
                
            }//end main
        
        })//end background
    }

    
    /*
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


            let a = shell(self.ffmpeg,arguments:["-i",path,"-vf","fps=12,scale=320:-1:flags=lanczos,palettegen=stats_mode=diff","-y",palettePath])
            
            let b = shell(self.ffmpeg,arguments:["-i",path,"-i",palettePath,"-lavfi","fps=12,scale=320:-1:flags=lanczos  [x]; [x][1:v] paletteuse","-gifflags","+transdiff","-y",filePath])
            
            
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
    */
    

    
    
    func compress(gif:GIF)
    {
        print("start compress")
        let q = String(format:"--lossy=%@",gif.quality.lossy())
        let result = shell(gifsicle,arguments:["-O3",q,"-o",gif.comporesGifPath,gif.gifPath])
        print(result)
    }
    
    func loadGIF(path:String,complete:(gif:GIF,err:String)->Void)
    {
        /*
         http://stackoverflow.com/questions/7708373/get-ffmpeg-information-in-friendly-way
         */
        
        let gif = GIF()
        
        let fm = NSFileManager.defaultManager()
        
        if let dir = try? fm.attributesOfItemAtPath(path)
        {
            let size = (dir[NSFileSize] as! NSNumber).floatValue/(1024*1024)
            print(size)
            if size > 100
            {
                complete(gif: gif, err: "GIF Works can only convert file less than 100MB.")
                return
            }
        }
        

        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            //"-show_streams"
            //"-show_format"
            //let arguments = ["-v","quiet","-print_format","json","-select_streams","v:0","-show_format","-show_entries","stream=height,width,r_frame_rate",path]
                        let arguments = ["-v","quiet","-print_format","json","-select_streams","v:0","-show_format","-show_streams",path]
            let result = shell(self.ffprobe,arguments:arguments)
            let data = try? NSJSONSerialization.JSONObjectWithData(result.dataUsingEncoding(NSUTF8StringEncoding)!, options:.AllowFragments)
            
            if data != nil
            {
                let json = JSON(data!)
                
                print(json)
                
                gif.path = path
                gif.size = CGSizeMake(CGFloat(json["streams"][0]["width"].floatValue), CGFloat(json["streams"][0]["height"].floatValue))
                gif.duration = json["format"]["duration"].doubleValue
                
                //400 225
                //print(gif)
                
                var scale = ""
                if gif.size.width/400 <  gif.size.height/225
                {
                    scale = "scale=-1:225"
                }else
                {
                    scale = "scale=400:-1"
                }
                
                
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
                    complete(gif: gif, err: "get video file error.")
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
    
    print("shell:")
    print(launchPath)
    print(arguments)
    print("========================")
    
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
    

    
    return output
}

/*
 
 
 dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
 

 dispatch_async(dispatch_get_main_queue()) {

 }
 
 })
 
 */



