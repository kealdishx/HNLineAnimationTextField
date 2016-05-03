//
//  HNLineAnimationManager.h
//  HNLineAnimationTextFieldDemo-OC
//
//  Created by zakariyyaSv on 16/4/24.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSArray+HNSort.h"
#import "UIView+HNHierarchy.h"
#import "UIWindow+HNHierarchy.h"

@interface HNLineAnimationManager : NSObject

@property (nonatomic,assign,getter=isEnable) BOOL enable;

// If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view.
@property (nonatomic,assign) BOOL layoutIfNeededOnUpdate;

// line layer's stroke color,default is RGBA(0,141/255.0,219/255.0,1.0)
@property (nonatomic,strong) UIColor *lineColor;

// line layer's lineWidth,default is 2.0
@property (nonatomic,assign) CGFloat lineWidth;

// return loading animation state
@property (nonatomic,assign,readonly,getter=isAnimating) BOOL animating;

// return singleton instance
+ (instancetype)sharedInstance;

// start loading animation
- (void)startLoadingAnimation;

// stop loading animation
- (void)stopLoadingAnimation;

@end
