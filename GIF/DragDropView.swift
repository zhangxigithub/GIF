//
//  DragDropView.swift
//  GIF
//
//  Created by zhangxi on 7/1/16.
//  Copyright © 2016 zhangxi.me. All rights reserved.
//

import Cocoa

protocol DragDropViewDelegate : NSObjectProtocol {
    func receivedFiles(file:String)
    func receivedErrorType(file:String)
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
                
                if let suffix = (path as NSString).lastPathComponent.componentsSeparatedByString(".").last
            {
                if suffix.lowercaseString == "vob"
                {
                    self.delegate?.receivedErrorType(path)
                }
            }
                self.delegate?.receivedFiles(path)
                return true
//                if let suffix = (path as NSString).lastPathComponent.componentsSeparatedByString(".").last
//                {
//                    self.delegate?.receivedFiles(path)
//                    return true
//                    if suffix == "mov" || suffix == "MOV"
//                    {
//                        self.delegate?.receivedFiles(path)
//                        return true
//                    }else
//                    {
//                        self.delegate?.receivedErrorType(path)
//                    }
//                }
            }
        }
        
        
        
        return false
    }
    
}
