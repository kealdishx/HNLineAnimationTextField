//
//  UIWindow+HNHierarchy.m
//  HNLineAnimationTextFieldDemo-OC
//
//  Created by zakariyyaSv on 16/4/24.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

#import "UIWindow+HNHierarchy.h"

@implementation UIWindow (HNHierarchy)

- (UIViewController *)topMostController{
    UIViewController *topController = [self rootViewController];
    
    while ([topController presentedViewController]) {
        topController = [topController presentedViewController];
    }
    return topController;
}

- (UIViewController *)currentViewController{
    UIViewController *currentController = [self topMostController];
    while ([currentController isKindOfClass:[UINavigationController class]] && [(UINavigationController *)currentController topViewController]) {
        currentController = [(UINavigationController*)currentController topViewController];
    }
    return currentController;
}

@end
