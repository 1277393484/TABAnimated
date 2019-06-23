//
//  UITableViewCell+Animated.m
//  AnimatedDemo
//
//  Created by tigerAndBull on 2018/9/21.
//  Copyright © 2018年 tigerAndBull. All rights reserved.
//

#import "UITableViewCell+TABLayoutSubviews.h"
#import "TABAnimated.h"

#import <objc/runtime.h>

@implementation UITableViewCell (TABLayoutSubviews)

+ (void)load {
    
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        
        // Gets the layoutSubviews method to the class,whose type is a pointer to a objc_method structure.
        Method originMethod = class_getInstanceMethod([self class], @selector(layoutSubviews));
        // Get the method you created.
        Method newMethod = class_getInstanceMethod([self class], @selector(tab_cell_layoutSubviews));
        // exchange
        method_exchangeImplementations(originMethod, newMethod);
    });
}

#pragma mark - Exchange Method

- (void)tab_cell_layoutSubviews {
    [self tab_cell_layoutSubviews];
    
    // start/end animation.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UITableView *superView;
        // adapt to different ios versions.
        if ([[[self superview] superview] isKindOfClass:[UITableView class]]) {
            superView = (UITableView *)self.superview.superview;
        }else {
            superView = (UITableView *)self.superview;
        }
         
        if (![superView isKindOfClass:[UITableView class]]) {
            return;
        }
        
        NSIndexPath *indexPath = [superView indexPathForCell:self];
        
        TABTableAnimated *tabAnimated = (TABTableAnimated *)((UITableView *)superView.tabAnimated);
        
        // 开启动画
        if (tabAnimated.state == TABViewAnimationStart &&
            [tabAnimated currentSectionIsAnimating:superView section:indexPath.section] && !self.tabLayer.isLoad) {
            NSMutableArray <TABComponentLayer *> *array = @[].mutableCopy;
            // start animations
            [TABManagerMethod getNeedAnimationSubViews:self
                                         withSuperView:superView
                                          withRootView:self
                                     withRootSuperView:superView
                                          isInNestView:NO
                                                 array:array];
            
            self.tabLayer.componentLayerArray = array;
            
            __weak typeof(self) weakSelf = self;
            if (superView.tabAnimated.categoryBlock) {
                superView.tabAnimated.categoryBlock(weakSelf);
            }
            
            self.tabLayer.animatedBackgroundColor = superView.tabAnimated.animatedBackgroundColor;
            self.tabLayer.animatedColor = superView.tabAnimated.animatedColor;
            [self.tabLayer updateSublayers:self.tabLayer.componentLayerArray.mutableCopy];
            
            if (self.tabLayer.nestView) {
                self.tabLayer.backgroundColor = UIColor.clearColor.CGColor;
                [TABManagerMethod resetData:self];
            }
            self.tabLayer.isLoad = YES;
            
            // add shimmer animation
            if ([TABManagerMethod canAddShimmer:superView]) {
                for (NSInteger i = 0; i < self.tabLayer.resultLayerArray.count; i++) {
                    TABComponentLayer *layer = self.tabLayer.resultLayerArray[i];
                    UIColor *baseColor = [TABAnimated sharedAnimated].shimmerBackColor;
                    CGFloat brigtness = [TABAnimated sharedAnimated].shimmerBrightness;
                    layer.colors = @[
                                     (id)baseColor.CGColor,
                                     (id)[TABAnimationMethod brightenedColor:baseColor brightness:brigtness].CGColor,
                                     (id) baseColor.CGColor
                                     ];
                    [TABAnimationMethod addShimmerAnimationToLayer:layer
                                                          duration:[TABAnimated sharedAnimated].animatedDurationShimmer
                                                               key:kTABShimmerAnimation
                                                         direction:[TABAnimated sharedAnimated].shimmerDirection];
                    
                }
            }
            
            if (!superView.tabAnimated.isNest) {
                
                // add bin animation
                if ([TABManagerMethod canAddBinAnimation:superView]) {
                    [TABAnimationMethod addAlphaAnimation:self
                                                 duration:[TABAnimated sharedAnimated].animatedDurationBin
                                                      key:kTABAlphaAnimation];
                }
                
                // add drop animation
                if ([TABManagerMethod canAddDropAnimation:superView]) {
                    
                    UIColor *deepColor;
                    if (superView.tabAnimated.dropAnimationDeepColor) {
                        deepColor = superView.tabAnimated.dropAnimationDeepColor;
                    }else {
                        deepColor = [TABAnimated sharedAnimated].dropAnimationDeepColor;
                    }
                    
                    CGFloat duration = 0;
                    CGFloat cutTime = 0.02;
                    CGFloat allCutTime = cutTime*(self.tabLayer.resultLayerArray.count-1)*(self.tabLayer.resultLayerArray.count)/2.0;
                    if (superView.tabAnimated.dropAnimationDuration != 0.) {
                        duration = superView.tabAnimated.dropAnimationDuration;
                    }else {
                        duration = [TABAnimated sharedAnimated].dropAnimationDuration;
                    }
                    
                    for (NSInteger i = 0; i < self.tabLayer.resultLayerArray.count; i++) {
                        TABComponentLayer *layer = self.tabLayer.resultLayerArray[i];
                        if (layer.removeOnDropAnimation) {
                            continue;
                        }
                        [TABAnimationMethod addDropAnimation:layer
                                                       index:layer.dropAnimationIndex
                                                    duration:duration*(self.tabLayer.dropAnimationCount+1)-allCutTime
                         
                                                       count:self.tabLayer.dropAnimationCount+1
                                                    stayTime:layer.dropAnimationStayTime-i*cutTime
                                                   deepColor:deepColor
                                                         key:kTABDropAnimation];
                    }
                }
                
            }
            
            if (self.tabLayer.nestView) {
                [self.tabLayer.nestView tab_startAnimation];
            }
        }
        
        // 结束动画
        if (tabAnimated.state == TABViewAnimationEnd) {
            [TABManagerMethod endAnimationToSubViews:self];
        }
    });
}

@end
