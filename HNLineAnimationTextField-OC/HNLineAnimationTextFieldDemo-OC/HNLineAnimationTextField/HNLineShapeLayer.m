//
//  HNLineShapeLayer.m
//  HNLineAnimationTextFieldDemo-OC
//
//  Created by zakariyyaSv on 16/4/24.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

#import "HNLineShapeLayer.h"
#import <UIKit/UIKit.h>

@implementation HNLineShapeLayer

- (instancetype)init{
    if (self = [super init]) {
        self.fillColor = [UIColor clearColor].CGColor;
        self.lineJoin = kCALineJoinRound;
        self.lineCap = kCALineCapRound;
        self.opaque = YES;
    }
    return self;
}

@end
