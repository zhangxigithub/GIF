//
//  DragDropView.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa

protocol DragDropViewDelegate : NSObjectProtocol {
    func receivedFiles(fils:Array<String>)
}


class DragDropView: NSView {

    weak var delegate:DragDropViewDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //enableDragDrop()
    }
    
    
    override func awakeFromNib() {
        
        
        registerForDraggedTypes([NSFilenamesPboardType])
    }


    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
      
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        
        if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
            if sourceDragMask.rawValue & NSDragOperation.Generic.rawValue != 0 {
                return NSDragOperation.Link
            }
        }
        
        return NSDragOperation.None
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        
        if let pasteboard = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as? NSArray {
            if let path = pasteboard[0] as? String {
                
                Swift.print("filePath: \(path)")
                let c = ZXConverter()
                let info = c.info(path)
                
                
                let width:CGFloat  = CGFloat(info["streams"][0]["width"].floatValue)
                let height:CGFloat = CGFloat(info["streams"][0]["height"].floatValue)
                
                let size = CGSizeMake(width, height)
                
                Swift.print(info)
                let result = c.convert(path, size: size)
                
                Swift.print(NSHomeDirectory())
                Swift.print(result)
                
                return true
            }
        }
        
        
        
        return false
    }
    
}
