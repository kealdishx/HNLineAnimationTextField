//
//  UIWindow+HNHierarchy.swift
//  HNLineAnimationTextFieldDemo-swift
//
//  Created by zakariyyaSv on 16/4/26.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

import Foundation
import UIKit

public extension UIWindow{
     override public func topMostController() -> UIViewController?{
        var topController = rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController;
        }
        return topController
        
    }
    
    public func currentViewController() -> UIViewController? {
        var  currentViewController = topMostController()
        while currentViewController != nil && currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil {
            currentViewController = (currentViewController as! UINavigationController).topViewController
        }
        return currentViewController
    }
}