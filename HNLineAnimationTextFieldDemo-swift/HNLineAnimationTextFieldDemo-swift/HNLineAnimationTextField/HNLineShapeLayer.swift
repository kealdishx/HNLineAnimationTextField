//
//  HNLineShapeLayer.swift
//  HNLineAnimationTextFieldDemo-swift
//
//  Created by zakariyyaSv on 16/4/26.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

import UIKit

class HNLineShapeLayer: CAShapeLayer {
    override init() {
        super.init()
        fillColor = UIColor.clearColor().CGColor
        lineJoin = kCALineJoinRound
        lineCap = kCALineCapRound
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
