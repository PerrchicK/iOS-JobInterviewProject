//
//  ViewAnimator.m
//  CandidateProject
//
//  Created by Perry Shalom on 7/10/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import "ViewAnimator.h"

@implementation ViewAnimator

+(void)animateMovementOfView:(UIView *)view fromPoint:(CGPoint)startingPoint toPoint:(CGPoint)endingPoint completion:(void (^)(BOOL))completion {
    view.center = startingPoint;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.center = endingPoint;
    } completion:^(BOOL finished){
        if (completion) {
            completion(finished);
        }
    }];
}

+(void)popView:(UIView *) view completion:(void (^)(BOOL finished))completion {
    view.hidden = YES;
    // instantaneously make the image view small (when scaled to 1% of its actual size)
    view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    view.hidden = NO;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        if (completion) {
            completion(finished);
        }
    }];
}

+(void)fadeView:(UIView *) view fadeIn:(BOOL) fadeIn duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        UIViewAnimationOptions animationOptions;
        if (fadeIn) {
            animationOptions = UIViewAnimationOptionCurveEaseIn;
        }
        else {
            animationOptions = UIViewAnimationOptionCurveEaseOut;
        }

        view.alpha = fadeIn ? 0.0 : 1.0;
        view.hidden = NO;
        [UIView animateWithDuration: duration
                              delay: 0.0
                            options: animationOptions
                         animations:^{
                             view.alpha = fadeIn ? 1.0 : 0.0;
                         } completion:^(BOOL finished){
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    } else {
        view.alpha = fadeIn ? 1.0 : 0.0;
        view.hidden = !fadeIn;
        if (completion) {
            completion(YES);
        }
    }
}

@end