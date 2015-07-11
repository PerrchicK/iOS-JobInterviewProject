//
//  Place.h
//  CandidateProject
//
//  Created by Perry Shalom on 7/10/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface Place : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D placePosition;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *placeId;

@end