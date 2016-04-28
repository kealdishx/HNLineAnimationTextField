//
//  UIView+HNHierarchy.swift
//  HNLineAnimationTextFieldDemo-swift
//
//  Created by zakariyyaSv on 16/4/26.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

import Foundation
import UIKit

private var HNIsAskingCanBecomeFirstResponder = "HNIsAskingCanBecomeFirstResponder"

public extension UIView {
    
    public var isAskingCanBecomeFirstResponder: Bool {
        get {
            if  let value = objc_getAssociatedObject(self, &HNIsAskingCanBecomeFirstResponder) as? Bool {
                return value
            }
            else{
                return false
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &HNIsAskingCanBecomeFirstResponder, newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func viewController() -> UIViewController? {
        var nextResponder : UIResponder? = self
        repeat {
            nextResponder = nextResponder?.nextResponder()
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        }while nextResponder != nil
        return nil
    }
    
    public func topMostController() -> UIViewController? {
        var controllerHierarchy = [UIViewController]()
        if var topController = window?.rootViewController {
            controllerHierarchy.append(topController)
            while topController.presentedViewController != nil {
                topController = topController.presentedViewController!
                controllerHierarchy.append(topController)
            }
            var matchController : UIResponder? = viewController()
            
            while matchController != nil && controllerHierarchy.contains(matchController as! UIViewController) == false {
                repeat {
                    matchController = matchController?.nextResponder()
                }while matchController != nil && matchController is UIViewController == false
            }
            return matchController as? UIViewController
        }
        else{
            return viewController()
        }
        
    }
    
    // Returns all siblings that canBecomeFirstResponder
    public func responderSiblings() -> [UIView] {
        var tempTextFields = [UIView]()
        if let siblings = superview?.subviews {
            for textfield in siblings {
                if textfield._HNcanBecomeFirstResponder() == true {
                    tempTextFields.append(textfield)
                }
            }
        }
        return tempTextFields
    }
    
    public func deepResponderViews() -> [UIView] {
        let subViews = subviews.sort { (obj1 : AnyObject, obj2 : AnyObject) -> Bool in
            let view1 = obj1 as! UIView
            let view2 = obj2 as! UIView
            
            let x1 = CGRectGetMinX(view1.frame)
            let y1 = CGRectGetMinY(view1.frame)
            let x2 = CGRectGetMinX(view2.frame)
            let y2 = CGRectGetMinY(view2.frame)
            
            if y1 != y2 {
                return y1 < y2
            }
            else{
                return x1 < x2
            }
        }
        var textfields = [UIView]()
        
        for textfield in subViews {
            if textfield._HNcanBecomeFirstResponder() == true {
                textfields.append(textfield)
            }
            else if textfield.subviews.count != 0 && userInteractionEnabled == true && hidden == false && alpha != 0.0 {
                for deepView in textfield.deepResponderViews() {
                    textfields.append(deepView)
                }
            }
        }
        
        return textfields
    }
    
    private func _HNcanBecomeFirstResponder() -> Bool{
        isAskingCanBecomeFirstResponder = true
        var _HNCanBecomeFirstResponder = (canBecomeFirstResponder() == true && userInteractionEnabled == true && hidden == false && alpha != 0.0 && isAlertViewTextField() == false && isSearchBarTextField() == false)
        if _HNCanBecomeFirstResponder == true {
            if let textfield = self as? UITextField {
                _HNCanBecomeFirstResponder = textfield.enabled
            }
        }
        isAskingCanBecomeFirstResponder = false
        return _HNCanBecomeFirstResponder
    }
    
    public func isAlertViewTextField() -> Bool{
        struct InternalClass {
            static var UIAlertSheetTextFieldClass : AnyClass? = NSClassFromString("UIAlertSheetTextField")
            static var UIAlertSheetTextFieldClass_iOS8 : AnyClass? = NSClassFromString("_UIAlertControllerTextField")
        }
        return (InternalClass.UIAlertSheetTextFieldClass != nil && isKindOfClass(InternalClass.UIAlertSheetTextFieldClass!)) || (InternalClass.UIAlertSheetTextFieldClass_iOS8 != nil && isKindOfClass(InternalClass.UIAlertSheetTextFieldClass_iOS8!))
    }
    
    public func isSearchBarTextField() -> Bool {
        struct InternalClass {
            static var UISearchBarTextFieldClass: AnyClass? = NSClassFromString("UISearchBarTextField")
        }
        
        return (InternalClass.UISearchBarTextFieldClass != nil && isKindOfClass(InternalClass.UISearchBarTextFieldClass!)) || self is UISearchBar
    }
    
    public func isTextView() -> Bool {
        return isKindOfClass(UITextView)
    }
    
    private func depth() -> Int {
        var depth : Int = 0
        if let superView = superview {
            depth = superView.depth() + 1
        }
        return depth
        
    }
    
}

extension NSObject {
    public func HNDescription() -> String {
        return "<\(self) \(unsafeAddressOf(self))>"
    }
}