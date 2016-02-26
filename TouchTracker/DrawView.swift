//
//  DrawView.swift
//  TouchTracker
//
//  Created by Nam (Nick) N. HUYNH on 2/25/16.
//  Copyright (c) 2016 Enclave. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var currentLines = [NSValue: Line]()
    var finishedLines = [Line]()

    @IBInspectable var currentLineColor: UIColor = UIColor.redColor() {
        
        didSet {
            
            setNeedsDisplay()
            
        }
        
    }
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.blackColor() {
        
        didSet {
            
            setNeedsDisplay()
            
        }
        
    }
    
    @IBInspectable var lineThickness: CGFloat = 10 {
        
        didSet {
            
            setNeedsDisplay()
            
        }
        
    }
    
    
    func strokeLine(line: Line) {

        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = kCGLineCapRound
        path.moveToPoint(line.begin)
        path.addLineToPoint(line.end)
        path.stroke()
        
    }
    
    override func drawRect(rect: CGRect) {
        
        finishedLineColor.setStroke()
        for line in finishedLines {
            
            strokeLine(line)
            
        }
        
        currentLineColor.setStroke()
        for (_, line) in currentLines {
            
            strokeLine(line)
            
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch in touches {
            
            let location = touch.locationInView(self)
            let newLine = Line(begin: location, end: location)
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
            
        }
        
        setNeedsDisplay()
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        for touch in touches {
            
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.locationInView(self)
            
        }
        
        setNeedsDisplay()
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        for touch in touches {
            
            let key = NSValue(nonretainedObject: touch)
            if var line = currentLines[key] {
                
                line.end = touch.locationInView(self)
                finishedLines.append(line)
                currentLines.removeValueForKey(key)
                
            }
            
        }

        setNeedsDisplay()
        
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        
        currentLines.removeAll()
        setNeedsDisplay()
        
    }
    
}
