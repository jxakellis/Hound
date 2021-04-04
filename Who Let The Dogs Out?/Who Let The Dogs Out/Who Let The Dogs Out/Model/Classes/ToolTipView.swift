//
//  ToolTipView.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 3/31/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ToolTipPosition: Int {
     case left
     case right
     case middle
 }

class ToolTipView: UIView {
    
    private var toolTipLabelBackground:CGRect!
    
    ///Inset of text from edge of rounded rectangle background, its value is applied to both the left and right side so total inset will be 2x
    private var toolTipLabelWidthInset : CGFloat = 8.0
    
    ///Inset of text from edge of rounded rectangle background, its value is applied to both the left and right side so total inset will be 2x
    private var toolTipLabelHeightInset : CGFloat = 8.0
    
    ///Offset of the rectangle from the sourceView (aka button)
    private var toolTipOffset: CGFloat  = 10.0
    
    private var toolTipPosition : ToolTipPosition = .middle
    
    convenience init(sourceView: UIView, message: String, toolTipPosition: ToolTipPosition){
       
        self.init()
        
        let messageBounds = message.withBounded()
        
        let sourceCenter = sourceView.center
        
        let frameNeeded = CGRect(x: (sourceCenter.x - (messageBounds.width/2) - toolTipLabelWidthInset), y: sourceView.frame.origin.y - messageBounds.height - (toolTipLabelHeightInset * 2) - toolTipOffset, width: messageBounds.width + (toolTipLabelWidthInset * 2), height: messageBounds.height + (toolTipLabelHeightInset * 2) + toolTipOffset)
        
        self.frame = frameNeeded
        
       self.toolTipPosition = toolTipPosition
        
        createLabel(message)
    }
    
    override func draw(_ rect: CGRect) {
       super.draw(rect)
        
       drawToolTip(rect)
    }
    
    private func drawToolTip(_ rect : CGRect){
       toolTipLabelBackground = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - toolTipOffset)
       let toolTipLabelBackgroundBez = UIBezierPath(roundedRect: toolTipLabelBackground, cornerRadius: 5.0)
       let shape = createShapeLayer(toolTipLabelBackgroundBez.cgPath)
       self.layer.insertSublayer(shape, at: 0)
    }
    
    private func createShapeLayer(_ path : CGPath) -> CAShapeLayer{
       let shape = CAShapeLayer()
       shape.path = path
        //shape.fillColor = UIColor.systemGray5.cgColor
        shape.fillColor = UIColor.link.cgColor
       shape.shadowColor = UIColor.black.withAlphaComponent(0.60).cgColor
       shape.shadowOffset = CGSize(width: 0, height: 2)
       shape.shadowRadius = 5.0
       shape.shadowOpacity = 0.8
       return shape
    }
    
    private func createLabel(_ text : String){
       let label = UILabel(frame: CGRect(x: toolTipLabelWidthInset, y: toolTipLabelHeightInset, width: frame.width - (2 * toolTipLabelWidthInset), height: frame.height - toolTipOffset - (2 * toolTipLabelHeightInset)))
       label.text = text
       // label.textColor = .black
       label.textColor = .white
       label.textAlignment = .center
       label.numberOfLines = 0
       label.lineBreakMode = .byWordWrapping
       addSubview(label)
    }

}

protocol ToolTipable {
    ///Creates and shows a tool tip for a given button
    func showToolTip(sourceButton: UIButton, message: String)
    
    ///Does the animation to show the tool tip popping up
    func performToolTipShow(sourceButton: UIButton, _ v: UIView?)
    
    ///Hides the tool tip
    func hideToolTip(sourceButton: UIButton?)
}

extension ToolTipable {
    func performToolTipShow(sourceButton: UIButton, _ v: UIView?){
        v?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
            v?.transform = .identity
        }) { finished in
            sourceButton.isUserInteractionEnabled = true
        }
    }
}
