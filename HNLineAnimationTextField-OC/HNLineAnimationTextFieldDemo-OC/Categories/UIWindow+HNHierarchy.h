//
//  UIWindow+HNHierarchy.h
//  HNLineAnimationTextFieldDemo-OC
//
//  Created by zakariyyaSv on 16/4/24.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (HNHierarchy)

@property (nullable,nonatomic,strong,readonly) UIViewController *topMostController;

/**
 Returns the topViewController in stack of topMostController.
 */
@property (nullable, nonatomic, readonly, strong) UIViewController *currentViewController;

@end
