//
//  PushButton.swift
//  IngemarFinder
//
//  Created by Magnus Kraepelien on 2018-05-15.
//  Copyright © 2018 Magnus Kraepelien. All rights reserved.
//
import UIKit
@IBDesignable

class PushButton: UIButton {
    
    @IBInspectable var fillColor: UIColor = UIColor.green
    @IBInspectable var isAddButton: Bool = true
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(ovalIn: rect)
        fillColor.setFill()
        path.fill()
        
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * Constants.plusButtonScale
        let halfPlusWidth = plusWidth / 2
        
        
        
        let plusPath = UIBezierPath()
        
        plusPath.lineWidth = Constants.plusLineWidth
        
        if isAddButton {
            plusPath.move(to: CGPoint(
                x: halfHeight + Constants.halfPointShift,
                y: halfWidth - halfPlusWidth + Constants.halfPointShift
            ))
            
            plusPath.addLine(to: CGPoint(
                x: halfHeight + Constants.halfPointShift,
                y: halfWidth + halfPlusWidth + Constants.halfPointShift
                
            ))
        }
        plusPath.move(to: CGPoint(
            x: halfWidth - halfPlusWidth + Constants.halfPointShift,
            y: halfHeight + Constants.halfPointShift
        ))
        
        plusPath.addLine(to: CGPoint(
            x: halfWidth + halfPlusWidth + Constants.halfPointShift,
            y: halfHeight + Constants.halfPointShift
        ))
        
        
        UIColor.white.setStroke()
        
        plusPath.stroke()
    }
    private struct Constants {
        static let plusLineWidth: CGFloat = 3.0
        static let plusButtonScale: CGFloat = 0.5
        static let halfPointShift: CGFloat = 0.5
    }
    
    private var halfWidth: CGFloat {
        return bounds.width / 2
    }
    
    private var halfHeight: CGFloat {
        return bounds.height / 2
    }
}
