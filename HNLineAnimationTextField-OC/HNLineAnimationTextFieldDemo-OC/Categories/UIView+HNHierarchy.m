//
//  UIView+HNHierarchy.m
//  HNLineAnimationTextFieldDemo-OC
//
//  Created by zakariyyaSv on 16/4/24.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

#import "UIView+HNHierarchy.h"
#import <objc/runtime.h>
#import "NSArray+HNSort.h"

@implementation UIView (HNHierarchy)

//Special textFields,textViews,scrollViews
Class UIAlertSheetTextFieldClass;       //UIAlertView
Class UIAlertSheetTextFieldClass_iOS8;  //UIAlertView

Class UITableViewCellScrollViewClass;   //UITableViewCell
Class UITableViewWrapperViewClass;      //UITableViewCell
Class UIQueuingScrollViewClass;         //UIPageViewController

Class UISearchBarTextFieldClass;        //UISearchBar

+ (void)initialize{
    [super initialize];
    UIAlertSheetTextFieldClass          = NSClassFromString(@"UIAlertSheetTextField");
    UIAlertSheetTextFieldClass_iOS8     = NSClassFromString(@"_UIAlertControllerTextField");
    
    UITableViewCellScrollViewClass      = NSClassFromString(@"UITableViewCellScrollView");
    UITableViewWrapperViewClass         = NSClassFromString(@"UITableViewWrapperView");
    UIQueuingScrollViewClass            = NSClassFromString(@"_UIQueuingScrollView");
    
    UISearchBarTextFieldClass           = NSClassFromString(@"UISearchBarTextField");

}

- (void)_setIsAskingCanBecomeFirstResponder:(BOOL)isAskingCanBecomeFirstResponder{
    objc_setAssociatedObject(self, @selector(isAskingCanBecomeFirstResponder), @(isAskingCanBecomeFirstResponder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAskingCanBecomeFirstResponder{
    NSNumber *isAskingCanBecomeFirstResponder = objc_getAssociatedObject(self, @selector(isAskingCanBecomeFirstResponder));
    return [isAskingCanBecomeFirstResponder boolValue];
}

// return view's controller
- (UIViewController *)viewController{
    UIResponder *nextResponder = self;
    do {
        nextResponder = [nextResponder nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    } while (nextResponder != nil);
    return nil;
}

- (UIViewController *)topMostController{
    NSMutableArray *controllersHierarchy = [[NSMutableArray alloc] init];
    UIViewController *topController = self.window.rootViewController;
    if (topController) {
        [controllersHierarchy addObject:topController];
    }
    while ([topController presentedViewController]) {
        topController = [topController presentedViewController];
        [controllersHierarchy addObject:topController];
    }
    UIResponder *matchController = [self viewController];
    while (matchController != nil && ![controllersHierarchy containsObject:matchController]) {
        do {
            matchController = [matchController nextResponder];
        } while (matchController != nil && ![matchController isKindOfClass:[UIViewController class]]);
    }
    return (UIViewController *)matchController;
}

- (BOOL)HNcanBecomeFirstResponder{
    [self _setIsAskingCanBecomeFirstResponder:YES];
    BOOL _HNcanBecomeFirstResponder = ([self canBecomeFirstResponder] && [self isUserInteractionEnabled] && ![self isHidden] && self.alpha != 0);
    if (_HNcanBecomeFirstResponder == YES) {
        if ([self isKindOfClass:[UITextField class]]) {
            _HNcanBecomeFirstResponder = [(UITextField *)self isEnabled];
        }
    }
    [self _setIsAskingCanBecomeFirstResponder:NO];
    return _HNcanBecomeFirstResponder;
}

// get all UITextfields that can become first responder
- (NSArray *)responderSiblings{
    NSArray *siblings = self.superview.subviews;
    NSMutableArray *textFields = [[NSMutableArray alloc] init];
    for (UITextField *textfield in siblings) {
        if ([textfield HNcanBecomeFirstResponder]) {
            [textFields addObject:textfield];
        }
    }
    return textFields;
}

- (NSArray *)deepResponderViews{
    NSMutableArray *textfields = [[NSMutableArray alloc] init];
    NSArray *subviews = [self.subviews positionArr];
    for (UITextField *textfield in subviews) {
        if ([textfield HNcanBecomeFirstResponder]) {
            [textfields addObject:textfield];
        }
        else if (textfield.subviews.count && [textfield isUserInteractionEnabled] && ![textfield isHidden] && [textfield alpha] != 0){
            [textfields addObjectsFromArray:[textfield deepResponderViews]];
        }
    }
    return textfields;
}

// get view hierarchy depth
- (NSInteger)depth{
    NSInteger depth = 0;
    if ([self superview]) {
        depth = [[self superview] depth] + 1;
    }
    return depth;
}

- (NSString *)subHierarchy{
    NSMutableString *debugInfo = [[NSMutableString alloc] initWithString:@"\n"];
    NSInteger depth = [self depth];
    for (int counter = 0; counter < depth; counter++) {
        [debugInfo appendString:[self debugHierarchy]];
    }
    for (UIView *subView in self.subviews) {
        [debugInfo appendString:[subView debugHierarchy]];
    }
    return debugInfo;
}

- (NSString *)superHierarchy
{
    NSMutableString *debugInfo = [[NSMutableString alloc] init];
    
    if (self.superview)
    {
        [debugInfo appendString:[self.superview superHierarchy]];
    }
    else
    {
        [debugInfo appendString:@"\n"];
    }
    
    NSInteger depth = [self depth];
    
    for (int counter = 0; counter < depth; counter ++)  [debugInfo appendString:@"|  "];
    
    [debugInfo appendString:[self debugHierarchy]];
    
    [debugInfo appendString:@"\n"];
    
    return debugInfo;
}

-(NSString *)debugHierarchy
{
    NSMutableString *debugInfo = [[NSMutableString alloc] init];
    
    [debugInfo appendFormat:@"%@: ( %.0f, %.0f, %.0f, %.0f )",NSStringFromClass([self class]), CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)];
    
    if ([self isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *scrollView = (UIScrollView*)self;
        [debugInfo appendFormat:@"%@: ( %.0f, %.0f )",NSStringFromSelector(@selector(contentSize)),scrollView.contentSize.width,scrollView.contentSize.height];
    }
    
    if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity) == false)
    {
        [debugInfo appendFormat:@"%@: %@",NSStringFromSelector(@selector(transform)),NSStringFromCGAffineTransform(self.transform)];
    }
    
    return debugInfo;
}

- (BOOL)isSearchBarTextField{
    return ([self isKindOfClass:UISearchBarTextFieldClass] || [self isKindOfClass:[UISearchBar class]]);
}

- (BOOL)isAlertViewTextField{
    return ([self isKindOfClass:UIAlertSheetTextFieldClass] || [self isKindOfClass:UIAlertSheetTextFieldClass_iOS8]);
}

- (BOOL)isTextView{
    return ([self isKindOfClass:[UITextView class]]);
}

@end

@implementation NSObject (HN_logging)

- (NSString *)HNDescription{
    return [NSString stringWithFormat:@"<%@,%p>",NSStringFromClass([self class]),self];
}

@end
