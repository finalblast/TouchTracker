//
//  DrawView.swift
//  TouchTracker
//
//  Created by Nam (Nick) N. HUYNH on 2/25/16.
//  Copyright (c) 2016 Enclave. All rights reserved.
//

import UIKit

class DrawView: UIView, UIGestureRecognizerDelegate {
    
    var currentLines = [NSValue: Line]()
    var finishedLines = [Line]()
    var moveRecognizer: UIPanGestureRecognizer!
    var selectedLineIndex: Int? {
        
        didSet {
            
            if selectedLineIndex == nil {
                
                let menu = UIMenuController.sharedMenuController()
                menu.setMenuVisible(false, animated: true)
                
            }
            
        }
        
    }

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
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        let doubleTap = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        addGestureRecognizer(doubleTap)
        
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        tap.delaysTouchesBegan = true
        tap.requireGestureRecognizerToFail(doubleTap)
        addGestureRecognizer(tap)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: "longPress:")
        addGestureRecognizer(longGesture)
        
        moveRecognizer = UIPanGestureRecognizer(target: self, action: "moveLine:")
        moveRecognizer.cancelsTouchesInView = false
        moveRecognizer.requireGestureRecognizerToFail(tap)
        moveRecognizer.delegate = self
        addGestureRecognizer(moveRecognizer)
        
    }
    
    func doubleTap(gestureRecognizer: UIGestureRecognizer) {
        
        selectedLineIndex = nil
        currentLines.removeAll(keepCapacity: false)
        finishedLines.removeAll(keepCapacity: false)
        
        setNeedsDisplay()
        
    }
    
    func tap(gestureRecognizer: UIGestureRecognizer) {
        
        let point = gestureRecognizer.locationInView(self)
        selectedLineIndex = indexOfLineAtPoint(point)
        
        let menu = UIMenuController.sharedMenuController()
        if selectedLineIndex != nil {
            
            becomeFirstResponder()
            let deleteItem = UIMenuItem(title: "Delete", action: "deleteLine:")
            menu.menuItems = [deleteItem]
            menu.setTargetRect(CGRect(x: point.x, y: point.y, width: 2, height: 2), inView: self)
            menu.setMenuVisible(true, animated: true)
            
        } else {
            
            menu.setMenuVisible(false, animated: true)
            
        }
        
        setNeedsDisplay()
        
    }
    
    func deleteLine(sender: AnyObject) {
        
        if let index = selectedLineIndex {
            
            finishedLines.removeAtIndex(index)
            selectedLineIndex = nil
            setNeedsDisplay()
            
        }
        
    }
    
    func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let point = gestureRecognizer.locationInView(self)
            selectedLineIndex = indexOfLineAtPoint(point)
            
            if selectedLineIndex != nil {
                
                currentLines.removeAll(keepCapacity: false)
                
            }
            
        } else if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            
            selectedLineIndex = nil
            
        }
        
        setNeedsDisplay()
        
    }
    
    func moveLine(gestureRecognizer: UIPanGestureRecognizer) {
        
        println("Moving")
        
        if let index = selectedLineIndex {
            
            if gestureRecognizer.state == UIGestureRecognizerState.Changed {
                
                let translation = gestureRecognizer.translationInView(self)
                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y
                
                gestureRecognizer.setTranslation(CGPointZero, inView: self)
                
                setNeedsDisplay()
                
            }
            
        } else {
            
            return
            
        }
        
    }
    
    func strokeLine(line: Line) {

        let path = UIBezierPath()
        path.lineWidth = CGFloat(line.thickness)
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
        
        if let index = selectedLineIndex {
            
            UIColor.greenColor().setStroke()
            let selectedLine = finishedLines[index]
            strokeLine(selectedLine)
            
        }
        
    }
    
    func indexOfLineAtPoint(point: CGPoint) -> Int? {
        
        for(index, line) in enumerate(finishedLines) {
            
            let begin = line.begin
            let end = line.end
            
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                if hypot(x - point.x, y - point.y) < 20.0 {
                    
                    return index
                    
                }
                
            }
            
        }
        
        return nil
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        
        return true
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        selectedLineIndex = nil
        
        for touch in touches {
            
            let location = touch.locationInView(self)
            let newLine = Line(begin: location, end: location, thickness: 5.0)
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
            
        }
        
        setNeedsDisplay()
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        for touch in touches {
            
            let velocity = moveRecognizer.velocityInView(self)
            let lineWidth = hypotf(Float(velocity.x), Float(velocity.y)) / 50;
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.thickness = lineWidth
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
    
    // MARK: GestureRecognizer Delegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == moveRecognizer {
            
            return true
            
        }
        
        return false
        
    }
    
    // MARK: Override method from UIResponderStandardEditActions
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        
        if action == "copy:" {
            
            return false
            
        } else {
            
            return super.canPerformAction(action, withSender: sender)
            
        }
        
    }
    
}
