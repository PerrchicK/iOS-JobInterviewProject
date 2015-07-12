//
//  UIView+Extras.m
//  psst
//
//  Created by Perry Shalom on 6/18/15.
//  Copyright (c) 2015 NPE Software. All rights reserved.
//

#import "UIView+Extras.h"

@implementation UIView(Extras)

-(void)makeShadow {
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.masksToBounds = NO;
}

-(void)makeRoundCorners {
    self.layer.cornerRadius = 12;
    self.layer.masksToBounds = NO;
    self.clipsToBounds = YES;
}

@end