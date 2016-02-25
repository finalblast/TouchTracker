//
//  DrawView.swift
//  TouchTracker
//
//  Created by Nam (Nick) N. HUYNH on 2/25/16.
//  Copyright (c) 2016 Enclave. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var currentLine: Line?
    var finishedLines = [Line]()

    func strokeLine(line: Line) {
        
        let path = UIBezierPath()
        path.lineWidth = 10
        path.lineCapStyle = kCGLineCapRound
        path.moveToPoint(line.begin)
        path.moveToPoint(line.end)
        path.stroke()
        
    }
    
    override func drawRect(rect: CGRect) {
        
        UIColor.blackColor().setStroke()
        for line in finishedLines {
            
            strokeLine(line)
            
        }
        
        if let line = currentLine {
            
            UIColor.redColor().setStroke()
            strokeLine(line)
            
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if let touch = touches.anyObject() as? UITouch {

            let location = touch.locationInView(self)
            currentLine = Line(begin: location, end: location)
            setNeedsDisplay()
            
        }
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if let touch = touches.anyObject() as? UITouch {
            
            let location = touch.locationInView(self)
            currentLine?.end = location
            setNeedsDisplay()
            
        }
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if var line = currentLine {
            
            let touch = touches.anyObject() as UITouch
            let location = touch.locationInView(self)
            line.end = location
            
            finishedLines.append(line)
            
        }
        
        currentLine = nil
        setNeedsDisplay()
        
    }
    
}
