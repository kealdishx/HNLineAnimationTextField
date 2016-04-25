//
//  NSArray+HNSort.m
//  HNLineAnimationTextFieldDemo-OC
//
//  Created by zakariyyaSv on 16/4/24.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

#import "NSArray+HNSort.h"
#import <UIKit/UIKit.h>

@implementation NSArray (HNSort)

- (NSArray *)tagArr{
    return [self sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        if ([view1 respondsToSelector:@selector(tag)] && [view2 respondsToSelector:@selector(tag)]) {
            if ([view1 tag] < [view2 tag]) {
                return NSOrderedAscending;
            }
            else if ([view1 tag] > [view2 tag]){
                return NSOrderedDescending;
            }
            else{
                return NSOrderedSame;
            }
        }
        else{
            return NSOrderedSame;
        }
    }];
}

- (NSArray *)positionArr{
    return [self sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        CGFloat x1 = CGRectGetMinX(view1.frame);
        CGFloat y1 = CGRectGetMinY(view1.frame);
        CGFloat x2 = CGRectGetMinX(view2.frame);
        CGFloat y2 = CGRectGetMinY(view2.frame);
        
        if (y1 < y2) {
            return NSOrderedAscending;
        }
        else if (y1 > y2){
            return NSOrderedDescending;
        }
        else if (x1 < x2){
            return NSOrderedAscending;
        }
        else if (x1 > x2){
            return NSOrderedDescending;
        }
        else{
            return NSOrderedSame;
        }
    }];
}

@end
