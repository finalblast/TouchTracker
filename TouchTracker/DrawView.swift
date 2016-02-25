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
    
}