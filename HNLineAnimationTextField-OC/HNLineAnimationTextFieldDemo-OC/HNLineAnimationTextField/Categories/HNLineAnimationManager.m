//
//  HNLineAnimationManager.m
//  HNLineAnimationTextFieldDemo-OC
//
//  Created by zakariyyaSv on 16/4/24.
//  Copyright © 2016年 Zakariyya. All rights reserved.
//

#import "HNLineAnimationManager.h"
#import "HNLineShapeLayer.h"

@interface HNLineAnimationManager()

// To save UITextfield via textfield notification
@property (nonatomic,weak) UIView *textfieldView;

@property (nonatomic,weak) UIViewController *previousViewController;

@property (nonatomic,weak) UIView *previousTextFieldView;

@property (nonatomic,assign) BOOL lineExist;

@property (nonatomic,strong) NSArray *respondSiblings;

@property (nonatomic,strong) UIView *loadingView;


@end

@implementation HNLineAnimationManager

+ (void)load{
    [[HNLineAnimationManager sharedInstance] setEnable:YES];
}

- (instancetype)init{
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _lineWidth = 2.0f;
            _lineColor = [UIColor colorWithRed:0 green:141/255.0 blue:219/255.0 alpha:1.0];
            _lineExist = NO;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEdit:) name:UITextFieldTextDidBeginEditingNotification object:nil];
            [self setLayoutIfNeededOnUpdate:NO];
        });
    }
    return self;
}

+ (instancetype)sharedInstance{
    static HNLineAnimationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HNLineAnimationManager alloc] init];
    });
    return sharedInstance;
}

- (UIWindow *)keyWindow{
    if (_textfieldView.window) {
        return _textfieldView.window;
    }
    else{
        static UIWindow *_keyWindow = nil;
        UIWindow *originalKeyWindow = [UIApplication sharedApplication].keyWindow;
        //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
        if (originalKeyWindow != nil && _keyWindow != originalKeyWindow)  _keyWindow = originalKeyWindow;
        
        return _keyWindow;
    }
}

#pragma mark - lazy
- (UIView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[UIView alloc] init];
    }
    return _loadingView;
}

#pragma mark - dealloc
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setEnable:NO];
}

#pragma mark - notification
- (void)textFieldViewDidBeginEdit:(NSNotification *)noti{
    if (!self.enable) {
        return;
    }
    _textfieldView = noti.object;
    _lineExist = NO;
    if (_textfieldView != nil && ![_textfieldView isAlertViewTextField] && ![_textfieldView isTextView]) {
        UIViewController *viewController = [_textfieldView viewController];
        if (!_previousViewController) {
            [self drawStartLineOnView:_textfieldView];
        }
        else if (_previousViewController && _previousViewController != viewController){
            HNLineShapeLayer *layer = (HNLineShapeLayer *)[self existlineShapeLayerOnView:_previousTextFieldView];
            [layer removeFromSuperlayer];
            [self drawStartLineOnView:_textfieldView];
        }
        else if (_previousViewController == viewController){
            if (_previousTextFieldView) {
                
                for (UITextField *textfield in [_textfieldView responderSiblings]) {
                    if (textfield == (UITextField *)_previousTextFieldView) {
                        [self moveToAnotherResponder];
                    }
                }
            }
            else{
                [self drawStartLineOnView:_textfieldView];
            }
        }
        else {
            NSLog(@"animation configure error");
        }
        
    }
}

- (void)drawStartLineOnView:(UIView *)textfield{
    CGRect textFrame = textfield.frame;
    CGFloat lineLength = textFrame.size.width;
    CGPoint startPoint = CGPointMake(0.2 * lineLength, textFrame.size.height - _lineWidth);
    
    HNLineShapeLayer *lineLayer = [HNLineShapeLayer layer];
    lineLayer.bounds = textfield.bounds;
    lineLayer.position = CGPointMake(lineLength * 0.5, textFrame.size.height * 0.5);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:CGPointMake(0, startPoint.y)];
    [path moveToPoint:startPoint];
    [path addLineToPoint:CGPointMake(lineLength, startPoint.y)];
    lineLayer.path = path.CGPath;
    lineLayer.strokeColor = _lineColor.CGColor;
    lineLayer.lineWidth = _lineWidth;
    [textfield.layer addSublayer:lineLayer];
    
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.delegate = self;
    strokeEndAnimation.fromValue = @[@0.0];
    strokeEndAnimation.toValue = @[@1.0];
    strokeEndAnimation.duration = 0.4f;
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeEndAnimation.removedOnCompletion = NO;
    
    [CATransaction begin];
    [lineLayer addAnimation:strokeEndAnimation forKey:@"strokeEnd"];
    [CATransaction commit];
}

- (void)moveToAnotherResponder{
    if (!_textfieldView || !_previousTextFieldView) {
        return;
    }
    _lineExist = YES;
    UIView *controllerView = [_textfieldView viewController].view;
    CGRect previousFrame = _previousTextFieldView.frame;
    CGRect presentFrame = _textfieldView.frame;
    HNLineShapeLayer *animationLayer = [HNLineShapeLayer layer];
    animationLayer.bounds = controllerView.bounds;
    animationLayer.position = CGPointMake(controllerView.bounds.size.width * 0.5, controllerView.bounds.size.height * 0.5);
    animationLayer.lineWidth = _lineWidth;
    animationLayer.strokeColor = _lineColor.CGColor;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(previousFrame.origin.x, CGRectGetMaxY(previousFrame) - _lineWidth)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(previousFrame), CGRectGetMaxY(previousFrame) - _lineWidth)];
    CGFloat radius = [self linePathAddArcWithPath:path];
    [path addLineToPoint:CGPointMake(presentFrame.origin.x, CGRectGetMaxY(presentFrame) - _lineWidth)];
    animationLayer.path = path.CGPath;
    [controllerView.layer addSublayer:animationLayer];
    
    CGFloat totalLength = radius * M_PI + previousFrame.size.width + presentFrame.size.width;
    CGFloat startLinePercent = previousFrame.size.width / totalLength * 1.0;
    CGFloat endLinePercent = presentFrame.size.width / totalLength * 1.0;
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    strokeStartAnimation.removedOnCompletion = NO;
    strokeStartAnimation.fillMode = kCAFillModeForwards;
    strokeStartAnimation.delegate = self;
    strokeStartAnimation.duration = 0.4f;
    strokeStartAnimation.fromValue = @[@0.0];
    strokeStartAnimation.toValue = @[@(1.0 - endLinePercent)];
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.removedOnCompletion = NO;
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    strokeEndAnimation.fillMode = kCAFillModeForwards;
    strokeEndAnimation.duration = 0.4f;
    strokeEndAnimation.fromValue = @[@(1 - startLinePercent)];
    strokeEndAnimation.toValue = @[@1.0];
    
    [CATransaction begin];
    [animationLayer addAnimation:strokeStartAnimation forKey:@"strokeStart"];
    [animationLayer addAnimation:strokeEndAnimation forKey:@"strokeEnd"];
    [CATransaction commit];
}
                                       
- (CGFloat)linePathAddArcWithPath:(UIBezierPath *)path{
    CGFloat previousMaxX = CGRectGetMaxX(_previousTextFieldView.frame);
    CGFloat previousMaxY = CGRectGetMaxY(_previousTextFieldView.frame) - _lineWidth;
    CGFloat presentMaxX = CGRectGetMaxX(_textfieldView.frame);
    CGFloat presentMaxY = CGRectGetMaxY(_textfieldView.frame) - _lineWidth;
    CGPoint arcCenter = CGPointMake(0.5 * (previousMaxX + presentMaxX), 0.5 * (previousMaxY + presentMaxY));
    CGFloat minusX = presentMaxX - previousMaxX;
    CGFloat minusY = presentMaxY - previousMaxY;
    CGFloat radius = sqrtf(minusX * minusX + minusY * minusY) * 0.5;
    CGFloat startAngle;
    if (minusX == 0) {
        startAngle = - M_PI * 0.5;
    }
    else{
        startAngle = atanf(minusY / minusX);
    }
    if (minusY >= 0) {
        [path addArcWithCenter:arcCenter radius:radius startAngle:startAngle endAngle:M_PI + startAngle clockwise:YES];
    }
    else{
        [path addArcWithCenter:arcCenter radius:radius startAngle:startAngle + M_PI endAngle:startAngle clockwise:NO];
    }
    
    return radius;
}

- (CGFloat)bezierCurveLengthFromStartPoint: (CGPoint) start toEndPoint: (CGPoint) end withControlPoint: (CGPoint) control
{
    const int kSubdivisions = 50;
    const float step = 1.0f/(float)kSubdivisions;
    
    CGFloat totalLength = 0.0f;
    CGPoint prevPoint = start;
    
    // starting from i = 1, since for i = 0 calulated point is equal to start point
    for (int i = 1; i <= kSubdivisions; i++)
    {
        float t = i*step;
        
        float x = (1.0 - t)*(1.0 - t)*start.x + 2.0*(1.0 - t)*t*control.x + t*t*end.x;
        float y = (1.0 - t)*(1.0 - t)*start.y + 2.0*(1.0 - t)*t*control.y + t*t*end.y;
        
        CGPoint diff = CGPointMake(x - prevPoint.x, y - prevPoint.y);
        
        totalLength += sqrtf(diff.x*diff.x + diff.y*diff.y); // Pythagorean
        
        prevPoint = CGPointMake(x, y);
    }
    
    return totalLength;
}

- (CALayer *)existlineShapeLayerOnView:(UIView *)view{
    for (CALayer *layer in view.layer.sublayers) {
        if ([layer isKindOfClass:[HNLineShapeLayer class]]) {
            return layer;
        }
    }
    return nil;
}

#pragma mark - animationDelegate
- (void)animationDidStart:(CAAnimation *)anim{
    _respondSiblings = [_textfieldView responderSiblings];
    for (UITextField *textfield in _respondSiblings) {
        if (textfield != _textfieldView) {
            textfield.userInteractionEnabled = NO;
        }
    }
    if (_lineExist) {
        HNLineShapeLayer *layer = (HNLineShapeLayer *)[self existlineShapeLayerOnView:_previousTextFieldView];
        if (layer) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
        for (UITextField *textfield in _respondSiblings) {
            if (textfield != _textfieldView) {
                textfield.userInteractionEnabled = YES;
            }
        }
        if (_lineExist) {
            HNLineShapeLayer *layer = (HNLineShapeLayer *)[self existlineShapeLayerOnView:[_textfieldView viewController].view];
            HNLineShapeLayer *lineLayer = [HNLineShapeLayer layer];
            lineLayer.lineWidth = _lineWidth;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, _textfieldView.frame.size.height - _lineWidth)];
            [path addLineToPoint:CGPointMake(_textfieldView.frame.size.width, _textfieldView.frame.size.height - _lineWidth)];
            lineLayer.path = path.CGPath;
            lineLayer.strokeColor = _lineColor.CGColor;
            [_textfieldView.layer addSublayer:lineLayer];
            if (layer) {
                layer.hidden = YES;
                [layer removeAllAnimations];
                [layer removeFromSuperlayer];
            }
        }
        else{
            HNLineShapeLayer *layer = (HNLineShapeLayer *)[self existlineShapeLayerOnView:_textfieldView];
            if (layer) {
                [layer removeAllAnimations];
            }
        }
        _previousViewController = [_textfieldView viewController];
        _previousTextFieldView = _textfieldView;
    
}


- (void)startLoadingAnimation{
    if (!_textfieldView) {
        return;
    }
    UIView *loadingView = self.loadingView;
    UIWindow *keyWindow = [self keyWindow];
    loadingView.frame = keyWindow.bounds;
    [keyWindow addSubview:loadingView];
    
    CGFloat circleRadius = 20.0f;
    CGPoint startPoint = CGPointMake(_textfieldView.frame.origin.x, CGRectGetMaxY(_textfieldView.frame) - _lineWidth);
    CGPoint circleCenter = CGPointMake(loadingView.frame.size.width * 0.5, loadingView.frame.size.height * 0.5);
    CGPoint circleUpPoint = CGPointMake(loadingView.frame.size.width * 0.5, loadingView.frame.size.height * 0.5 - circleRadius);
    HNLineShapeLayer *lineLayer = [HNLineShapeLayer layer];
    lineLayer.position = circleCenter;
    lineLayer.bounds = loadingView.bounds;
    lineLayer.strokeColor = _lineColor.CGColor;
    lineLayer.lineWidth = _lineWidth;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint controlPoint = CGPointMake(MIN(circleCenter.x, startPoint.x) - 60, MAX(circleCenter.y, startPoint.y) * 0.55 + MIN(circleCenter.y, startPoint.y) * 0.45);
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:circleUpPoint controlPoint:controlPoint];
    [path addArcWithCenter:circleCenter radius:circleRadius startAngle:- M_PI * 0.5 endAngle:M_PI * 1.5 clockwise:YES];
    lineLayer.path = path.CGPath;
    [loadingView.layer addSublayer:lineLayer];
    
    CGFloat endPercent = circleRadius * 2.0 * M_PI / (circleRadius * 2.0 * M_PI + [self bezierCurveLengthFromStartPoint:startPoint toEndPoint:circleUpPoint withControlPoint:controlPoint]);
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.removedOnCompletion = NO;
    strokeStartAnimation.fillMode = kCAFillModeBoth;
    strokeStartAnimation.fromValue = @[@0.0];
    strokeStartAnimation.toValue = @[@(1 - endPercent)];
    strokeStartAnimation.duration = 0.4f;
    strokeStartAnimation.beginTime = CACurrentMediaTime() + 0.4;
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.removedOnCompletion = NO;
    strokeEndAnimation.fillMode = kCAFillModeBoth;
    strokeEndAnimation.duration = 0.8;
    strokeEndAnimation.fromValue = @[@0.0];
    strokeEndAnimation.toValue = @[@1.0];
    
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    circleAnimation.fromValue = @[@1.0];
    circleAnimation.toValue = @[@1.2];
    circleAnimation.removedOnCompletion = NO;
    circleAnimation.fillMode = kCAFillModeBoth;
    circleAnimation.repeatCount = HUGE_VALF;
    circleAnimation.autoreverses = YES;
    circleAnimation.duration = 0.6f;
    circleAnimation.beginTime = CACurrentMediaTime() + 0.85;
    
    _animating = YES;
    [_textfieldView resignFirstResponder];
    HNLineShapeLayer *layer = (HNLineShapeLayer *)[self existlineShapeLayerOnView:_textfieldView];
    [layer removeFromSuperlayer];
    _previousTextFieldView = nil;
    _textfieldView = nil;
    [UIView animateWithDuration:0.3 animations:^{
        loadingView.backgroundColor = [UIColor whiteColor];
    }];
    [CATransaction begin];
    [lineLayer addAnimation:strokeStartAnimation forKey:@"strokeStart"];
    [lineLayer addAnimation:strokeEndAnimation forKey:@"strokeEnd"];
    [lineLayer addAnimation:circleAnimation forKey:@"transform"];
    [CATransaction commit];
}

- (void)stopLoadingAnimation{
    if (!_animating) {
        return;
    }
    UIView *loadingView = self.loadingView;
    HNLineShapeLayer *layer = (HNLineShapeLayer *)[self existlineShapeLayerOnView:loadingView];
    [UIView animateWithDuration:0.3f animations:^{
        if (layer) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
        loadingView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        
        [loadingView removeFromSuperview];
    }];
    
}

@end
