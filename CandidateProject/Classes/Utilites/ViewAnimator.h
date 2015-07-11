//
//  ViewAnimator.h
//  CandidateProject
//
//  Created by Perry Shalom on 7/10/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ViewAnimator : NSObject

+(void)animateMovementOfView:(UIView *)view fromPoint:(CGPoint)startingPoint toPoint:(CGPoint)endingPoint completion:(void (^)(BOOL))completion;
+(void)popView:(UIView *) view completion:(void (^)(BOOL finished))completion;
+(void)fadeView:(UIView *) view fadeIn:(BOOL) fadeIn duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;

@end