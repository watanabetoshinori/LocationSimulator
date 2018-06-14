//
//  NSView+Extension.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 6/11/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import Cocoa

extension NSView {

    func setAnchorPoint(_ anchorPoint: CGPoint) {
        guard let layer = self.layer else {
            return
        }

        var newPoint = NSPoint(x: bounds.size.width * anchorPoint.x, y: bounds.size.height * anchorPoint.y)
        var oldPoint = NSPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(layer.affineTransform())
        oldPoint = oldPoint.applying(layer.affineTransform())

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = anchorPoint
    }

}
