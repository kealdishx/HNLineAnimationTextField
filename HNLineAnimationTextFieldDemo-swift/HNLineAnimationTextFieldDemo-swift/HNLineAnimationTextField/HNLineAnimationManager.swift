//
//  HNLineAnimationManager.swift
//  HNLineAnimationTextFieldDemo-swift
//
//  Created by zakariyyaSv on 16/4/26.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

import UIKit

public class HNLineAnimationManager: NSObject {
    
    public var enable = false
    
    weak var textfieldView : UIView?
    
    weak var previousViewController : UIViewController?
    
    weak var previousTextfieldView : UIView?
    
    var lineExist = false
    
    var respondSiblings : [UIView]?
    
    var loadingView : UIView = UIView()
    
    public var lineColor : UIColor! = UIColor.init(red: 0, green: 141/255.0, blue: 219/255.0, alpha: 1.0)
    
    public var lineWidth : CGFloat! = 2.0
    
    private var animating = false
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.textfieldDidBeginEditAction(_:)), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        enable = false
    }
    
    public class func sharedInstance() -> HNLineAnimationManager {
        struct Static{
            static let singleInstance = HNLineAnimationManager()
        }
        return Static.singleInstance
    }
    
    private func keyWindow() -> UIWindow? {
        if textfieldView?.window != nil {
            return textfieldView?.window
        }
        else {
            struct Static {
                static var _keyWindow : UIWindow?
            }
            let originalKeyWindow = UIApplication.sharedApplication().keyWindow
            
            if originalKeyWindow != nil && Static._keyWindow != originalKeyWindow {
                Static._keyWindow = originalKeyWindow
            }
            
            return Static._keyWindow
        }
    }
    
    
    func textfieldDidBeginEditAction(noti : NSNotification){
        
        if enable == false {
            return;
        }
        textfieldView = noti.object as? UIView
        lineExist = false
        if textfieldView != nil && textfieldView?.isAlertViewTextField() == false && textfieldView?.isTextView() == false {
            let viewController = textfieldView?.viewController()
            if previousViewController == nil {
                drawStartLineOnView(textfieldView)
            }
            else if previousViewController != nil && previousViewController != viewController {
                let layer : HNLineShapeLayer? = existlineShapeLayerOnView(previousTextfieldView)! as HNLineShapeLayer
                layer?.removeFromSuperlayer()
                drawStartLineOnView(textfieldView)
            }
            else if previousViewController == viewController {
                if previousTextfieldView != nil {
                    for textfield in (textfieldView?.responderSiblings())! {
                        if textfield == previousTextfieldView {
                            moveToAnotherResponder()
                        }
                    }
                }
                else {
                    drawStartLineOnView(textfieldView)
                }
            }
        }
        
    }
    
    func drawStartLineOnView(textfield : UIView!) {
        let textfieldFrame = textfield.frame
        let lineLength = textfieldFrame.size.width
        let startPoint = CGPointMake(0.2 * lineLength, textfieldFrame.size.height - lineWidth)
        
        let lineLayer = HNLineShapeLayer()
        lineLayer.bounds = textfield.bounds
        lineLayer.position = CGPointMake(0.5 * lineLength, textfieldFrame.size.height * 0.5)
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        path.addLineToPoint(CGPointMake(0, startPoint.y))
        path.moveToPoint(startPoint)
        path.addLineToPoint(CGPointMake(lineLength, startPoint.y))
        lineLayer.path = path.CGPath
        lineLayer.strokeColor = lineColor.CGColor
        lineLayer.lineWidth = lineWidth
        textfield.layer.addSublayer(lineLayer)
        
        let strokeEndAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        strokeEndAnimation.delegate = self
        strokeEndAnimation.fromValue = [0.0]
        strokeEndAnimation.toValue = [1.0]
        strokeEndAnimation.duration = 0.4
        strokeEndAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        strokeEndAnimation.removedOnCompletion = false
        
        CATransaction.begin()
        lineLayer.addAnimation(strokeEndAnimation, forKey: "strokeEnd")
        CATransaction.commit()
        
    }
    
    func moveToAnotherResponder() {
        if textfieldView == nil || previousTextfieldView == nil {
            return;
        }
        
        lineExist = true
        let controllerView : UIView? = textfieldView?.viewController()?.view
        if controllerView == nil {
            print("moveToAnotherResponder Error")
            return;
        }
        let previousFrame = previousTextfieldView!.frame
        let presentFrame = textfieldView!.frame
        
        let animationLayer = HNLineShapeLayer()
        animationLayer.bounds = (controllerView?.bounds)!
        animationLayer.position = CGPointMake(controllerView!.bounds.size.width * 0.5, controllerView!.bounds.size.height * 0.5)
        animationLayer.lineWidth = lineWidth
        animationLayer.strokeColor = lineColor.CGColor
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(previousFrame.origin.x, CGRectGetMaxY(previousFrame) - lineWidth))
        path.addLineToPoint(CGPointMake(CGRectGetMaxX(previousFrame), CGRectGetMaxY(previousFrame) - lineWidth))
        let radius = linePathAddArcWithPath(path)
        path.addLineToPoint(CGPointMake(presentFrame.origin.x, CGRectGetMaxY(presentFrame) - lineWidth))
        animationLayer.path = path.CGPath
        controllerView!.layer.addSublayer(animationLayer)
        
        let totalLength = radius * (CGFloat)(M_PI) + previousFrame.size.width + presentFrame.size.width
        let startLinePercent = previousFrame.size.width / totalLength
        let endLinePercent = presentFrame.size.width / totalLength
        
        let strokeStartAnimation = CABasicAnimation.init(keyPath: "strokeStart")
        strokeStartAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        strokeStartAnimation.removedOnCompletion = false
        strokeStartAnimation.fillMode = kCAFillModeForwards
        strokeStartAnimation.delegate = self
        strokeStartAnimation.duration = 0.4
        strokeStartAnimation.fromValue = [0.0]
        strokeStartAnimation.toValue = [1.0 - endLinePercent]
        
        let strokeEndAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        strokeEndAnimation.removedOnCompletion = false
        strokeEndAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        strokeEndAnimation.fillMode = kCAFillModeForwards
        strokeEndAnimation.duration = 0.4
        strokeEndAnimation.fromValue = [1.0 - startLinePercent]
        strokeEndAnimation.toValue = [1.0]
        
        CATransaction.begin()
        animationLayer.addAnimation(strokeStartAnimation, forKey: "strokeStart")
        animationLayer.addAnimation(strokeEndAnimation, forKey: "strokeEnd")
        CATransaction.commit()
        
    }
    
    func linePathAddArcWithPath(path : UIBezierPath!) -> CGFloat {
        let previousMaxX = CGRectGetMaxX(previousTextfieldView!.frame)
        let previousMaxY = CGRectGetMaxY(previousTextfieldView!.frame)
        let presentMaxX = CGRectGetMaxX(textfieldView!.frame)
        let presentMaxY = CGRectGetMaxY(textfieldView!.frame)
        let arcCenter = CGPointMake(0.5 * (previousMaxX + presentMaxX), 0.5 * (previousMaxY + presentMaxY) - lineWidth)
        let minusX = presentMaxX - previousMaxX
        let minusY = presentMaxY - previousMaxY
        let radius = sqrt(minusX * minusX + minusY * minusY) * 0.5
        var startAngle : CGFloat = 0.0
        if minusX == 0 {
            startAngle = -(CGFloat)(M_PI) * 0.5
        }
        else{
            startAngle = atan(minusY / minusX)
        }
        if minusY >= 0 {
            path.addArcWithCenter(arcCenter, radius: radius, startAngle: startAngle, endAngle: startAngle + (CGFloat)(M_PI), clockwise: true)
        }
        else{
            path.addArcWithCenter(arcCenter, radius: radius, startAngle: startAngle + (CGFloat)(M_PI), endAngle: startAngle, clockwise: false)
        }
        return radius
        
        
    }
    
    func bezierCurveLengthFromStartPoint(start : CGPoint, end : CGPoint, controlPoint : CGPoint) -> CGFloat {
        let kSubdivisions = 50
        let step = 1.0 / (CGFloat)(kSubdivisions)
        var totalLength : CGFloat! = 0.0
        var prevPoint = start
        
        for i in 1...kSubdivisions {
            let t = (CGFloat)(i) * step
            let x = (1.0 - t)*(1.0 - t)*start.x + 2.0*(1.0 - t)*t*controlPoint.x + t*t*end.x
            let y = (1.0 - t)*(1.0 - t)*start.y + 2.0*(1.0 - t)*t*controlPoint.y + t*t*end.y
            
            let diff = CGPointMake(x - prevPoint.x, y - prevPoint.y)
            
            totalLength = totalLength + sqrt(diff.x*diff.x + diff.y*diff.y)
            prevPoint = CGPointMake(x, y)
            
        }
        return totalLength
        
    }
    
    func existlineShapeLayerOnView(view : UIView!) -> HNLineShapeLayer? {
        for layer in view.layer.sublayers! {
            if layer.isKindOfClass(HNLineShapeLayer) {
                return (layer as! HNLineShapeLayer)
            }
        }
        return nil
    }
    
    public override func animationDidStart(anim: CAAnimation) {
        respondSiblings = textfieldView!.responderSiblings()
        for textfield in respondSiblings! {
            if textfield != textfieldView! {
                textfield.userInteractionEnabled = false
            }
        }
        if lineExist == true {
            let layer = existlineShapeLayerOnView(previousTextfieldView!)
            layer?.removeAllAnimations()
            layer?.removeFromSuperlayer()
        }
    }
    
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        for textfield in respondSiblings! {
            if textfield != textfieldView! {
                textfield.userInteractionEnabled = true
            }
        }
        
        if lineExist == true {
            let layer : HNLineShapeLayer? = existlineShapeLayerOnView(textfieldView!.viewController()?.view)
            let lineLayer = HNLineShapeLayer()
            lineLayer.lineWidth = lineWidth
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(0, textfieldView!.frame.size.height - lineWidth))
            path.addLineToPoint(CGPointMake(textfieldView!.frame.size.width, textfieldView!.frame.size.height - lineWidth))
            lineLayer.path = path.CGPath
            lineLayer.strokeColor = lineColor.CGColor
            textfieldView!.layer.addSublayer(lineLayer)
            if layer != nil {
                layer!.hidden = true
                layer!.removeAllAnimations()
                layer!.removeFromSuperlayer()
            }
        }
        else {
            let layer = existlineShapeLayerOnView(textfieldView!) as HNLineShapeLayer?
            layer?.removeAllAnimations()
        }
     
        previousViewController = textfieldView!.viewController()
        previousTextfieldView = textfieldView
    }
    
    public func startLoadingAnimation() {
        if textfieldView == nil {
            return;
        }
        let loadingview = self.loadingView
        let keywindow = keyWindow()!
        loadingView.frame = keywindow.bounds
        keywindow.addSubview(loadingview)
        
        let circleRadius : CGFloat = 20.0
        let startPoint = CGPointMake(textfieldView!.frame.origin.x, CGRectGetMaxY(textfieldView!.frame) - lineWidth)
        let circleCenter = CGPointMake(loadingview.frame.size.width * 0.5, loadingview.frame.size.height * 0.5)
        let circleUpPoint = CGPointMake(loadingview.frame.size.width * 0.5, loadingview.frame.size.height * 0.5 - circleRadius)
        let lineLayer = HNLineShapeLayer()
        lineLayer.bounds = loadingview.bounds
        lineLayer.position = circleCenter
        lineLayer.strokeColor = lineColor.CGColor
        lineLayer.lineWidth = lineWidth
        let path = UIBezierPath()
        let controlPoint = CGPointMake(min(circleCenter.x, startPoint.x) - 60, max(circleCenter.y, startPoint.y) * 0.55 + min(circleCenter.y, startPoint.y) * 0.45)
        path.moveToPoint(startPoint)
        path.addQuadCurveToPoint(circleUpPoint, controlPoint: controlPoint)
        path.addArcWithCenter(circleCenter, radius: circleRadius, startAngle: -(CGFloat)(M_PI)*0.5, endAngle: (CGFloat)(M_PI)*1.5, clockwise: true)
        lineLayer.path = path.CGPath
        loadingview.layer.addSublayer(lineLayer)
        
        let endPercent = circleRadius * 2.0*(CGFloat)(M_PI) / (circleRadius * 2.0*(CGFloat)(M_PI) + bezierCurveLengthFromStartPoint(startPoint, end: circleUpPoint, controlPoint: controlPoint))
        let strokeStartAnimation = CABasicAnimation.init(keyPath: "strokeStart")
        strokeStartAnimation.removedOnCompletion = false
        strokeStartAnimation.fillMode = kCAFillModeBoth
        strokeStartAnimation.fromValue = [0.0]
        strokeStartAnimation.toValue = [1 - endPercent]
        strokeStartAnimation.duration = 0.4
        strokeStartAnimation.beginTime = CACurrentMediaTime() + 0.4
        
        let strokeEndAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        strokeEndAnimation.removedOnCompletion = false
        strokeEndAnimation.fillMode = kCAFillModeBoth
        strokeEndAnimation.duration = 0.8
        strokeEndAnimation.fromValue = [0.0]
        strokeEndAnimation.toValue = [1.0]
        
        let circleAnimation = CABasicAnimation.init(keyPath: "transform.scale")
        circleAnimation.fromValue = [1.0]
        circleAnimation.toValue = [1.2]
        circleAnimation.removedOnCompletion = false
        circleAnimation.fillMode = kCAFillModeBoth
        circleAnimation.repeatCount = HUGE
        circleAnimation.autoreverses = true
        circleAnimation.duration = 0.6
        circleAnimation.beginTime = CACurrentMediaTime() + 0.85
        
        animating = true
        textfieldView!.resignFirstResponder()
        existlineShapeLayerOnView(textfieldView!)?.removeFromSuperlayer()
        previousTextfieldView = nil
        textfieldView = nil
        UIView.animateWithDuration(0.3) { 
            () -> Void in
            self.loadingView.backgroundColor = UIColor.whiteColor()
        }
        CATransaction.begin()
        lineLayer.addAnimation(strokeStartAnimation, forKey: "strokeStart")
        lineLayer.addAnimation(strokeEndAnimation, forKey: "strokeEnd")
        lineLayer.addAnimation(circleAnimation, forKey: "transform")
        CATransaction.commit()
        
    }
    
    public func stopLoadingAnimation() {
        if animating == false {
            return;
        }
        let loadingview = self.loadingView
        let layer : HNLineShapeLayer? = existlineShapeLayerOnView(loadingview)
        UIView.animateWithDuration(0.3, animations: { 
            () -> Void in
            layer?.removeAllAnimations()
            layer?.removeFromSuperlayer()
            loadingview.backgroundColor = UIColor.clearColor()
            }) { (finished) in
                loadingview.removeFromSuperview()
        }
        
    }
    
}
