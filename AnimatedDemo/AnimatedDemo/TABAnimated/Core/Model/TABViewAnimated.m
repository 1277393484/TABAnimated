//
//  TABBaseAnimated.m
//  AnimatedDemo
//
//  Created by tigerAndBull on 2019/4/27.
//  Copyright © 2019 tigerAndBull. All rights reserved.
//

#import "TABViewAnimated.h"

const NSInteger TABViewAnimatedErrorCode = -1000;

NSString * const TABViewAnimatedHeaderPrefixString = @"tab_header_";
NSString * const TABViewAnimatedFooterPrefixString = @"tab_footer_";
NSString * const TABViewAnimatedDefaultSuffixString = @"default_resuable_view";

@implementation TABViewAnimated

- (instancetype)init {
    if (self = [super init]) {
        _animatedCountArray = @[].mutableCopy;
        _cellClassArray = @[].mutableCopy;
        _superAnimationType = TABViewSuperAnimationTypeDefault;
        _dropAnimationDuration = 0;
        _filterSubViewSize = CGSizeZero;
        
//        UIViewController *controller = [self tab_viewController];
//        if (controller) {
//            _targetControllerClassName = NSStringFromClass(controller.class);
//        }
    }
    return self;
}

//- (UIViewController*)tab_viewController {
//    for (UIView *next = [self superview]; next; next = next.superview) {
//        UIResponder *nextResponder = [next nextResponder];
//        if ([nextResponder isKindOfClass:[UIViewController
//                                          class]]) {
//            return (UIViewController*)nextResponder;
//        }
//    }
//    return nil;
//}

- (BOOL)currentSectionIsAnimatingWithSection:(NSInteger)section {
    return YES;
}

@end
