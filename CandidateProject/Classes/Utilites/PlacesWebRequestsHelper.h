//
//  PlacesHelper.h
//  CandidateProject
//
//  Created by Perry Shalom on 7/10/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

typedef void (^PlacesNearbyCompletionBlock)(BOOL succeeded, NSArray *placesNearby);
typedef void (^AddressByCoordinateCompletionBlock)(BOOL succeeded, NSString *address);
typedef void (^AutocompleteCompletionBlock)(BOOL succeeded, NSArray *predictions);
typedef void (^PlaceRecommendationCompletionBlock)(BOOL succeeded, NSDictionary *recommendation);

@interface PlacesWebRequestsHelper : NSObject

/**
 Gets a list of place nearby a given coordinate, using nearby Google Maps API
 @param coordinate The coordinate of the specific spot to look around it
 @param radius The range to look at, in meters
 @param completionBlock A code snippet to be executed when the action is completed
 */
+(void)findPlacesNearbyCoordinate:(CLLocationCoordinate2D)coordinate radius:(NSInteger)radius completionBlock:(PlacesNearbyCompletionBlock)completionBlock;

/**
 Using reverse geocoding with google API to find address by coordinate
 @param coordinate The coordinate of the specific place
 @param completionBlock A code snippet to be executed when the action is completed
 */
+(void)findAddressByCoordinate:(CLLocationCoordinate2D)coordinate completionBlock:(AddressByCoordinateCompletionBlock)completionBlock;

/**
 Gets a list of predictions for an address from a given string
 @param phrase A string of the requested address or a part of it
 @param completionBlock A code snippet to be executed when the action is completed
 */
+(void)getAutocompleteFromPhrase:(NSString *)phrase completionBlock:(AutocompleteCompletionBlock)completionBlock;

@end