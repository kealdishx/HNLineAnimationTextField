//
//  Array+HNSort.swift
//  HNLineAnimationTextFieldDemo-swift
//
//  Created by zakariyyaSv on 16/4/26.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

import Foundation
import UIKit

internal extension Array{
    internal func sortedByTag() ->[Element]{
        return sort({ (obj1 : Element, obj2 : Element) -> Bool in
            let view1 = obj1 as! UIView
            let view2 = obj2 as! UIView
            return (view1.tag < view2.tag)
        })
    }
    
    internal func sortedByPosition() -> [Element] {
        return sort({ (obj1 : Element, obj2 : Element) -> Bool in
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
        })
    }
}

