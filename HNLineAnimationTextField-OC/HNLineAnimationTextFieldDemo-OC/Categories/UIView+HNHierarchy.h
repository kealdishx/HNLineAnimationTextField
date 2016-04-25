//
//  UIView+HNHierarchy.h
//  HNLineAnimationTextFieldDemo-OC
//
//  Created by zakariyyaSv on 16/4/24.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HNHierarchy)

@property (nonatomic,readonly) BOOL isAskingCanBecomeFirstResponder;

@property (nonatomic,strong,readonly,nullable) UIViewController *viewController;

@property (nonatomic,strong,readonly,nullable) UIViewController *topMostController;

//- (nullable UIView *)superviewOfClassType:(nonnull Class)classType;

@property (nonnull, nonatomic, readonly, copy) NSArray *responderSiblings;

@property (nonnull, nonatomic, readonly, copy) NSArray *deepResponderViews;

@property (nonnull, nonatomic, readonly, copy) NSString *subHierarchy;

@property (nonnull, nonatomic, readonly, copy) NSString *superHierarchy;

@property (nonnull, nonatomic, readonly, copy) NSString *debugHierarchy;

/**
 Returns YES if the receiver object is UISearchBarTextField, otherwise return NO.
 */
@property (nonatomic, getter=isSearchBarTextField, readonly) BOOL searchBarTextField;

/**
 Returns YES if the receiver object is UIAlertSheetTextField, otherwise return NO.
 */
@property (nonatomic, getter=isAlertViewTextField, readonly) BOOL alertViewTextField;

@property (nonatomic,getter=isTextView,readonly) BOOL textView;

@end

@interface NSObject (HN_logging)

@property (nonnull, nonatomic, readonly, copy) NSString *HNDescription;


@end
