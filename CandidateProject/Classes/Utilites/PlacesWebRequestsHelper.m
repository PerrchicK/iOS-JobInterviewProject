//
//  PlacesHelper.m
//  CandidateProject
//
//  Created by Perry Shalom on 7/10/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import "PlacesWebRequestsHelper.h"
#import "Place.h"
#import "Prediction.h"
#import "Communicator.h"
#import "UsefulStrings.h"

#define kGoogleMapsUrlApiKey @"AIzaSyBprjBz5erFJ6Ai9OnEmZdY3uYIoWNtGGI"

#define kGoogleMapsResultsKey @"results"
#define kGoogleMapsFormattedAddressKey @"formatted_address"
#define kGoogleMapsFormattedAddressKey @"formatted_address"

#define kGoogleMapsGeometryKey @"geometry"
#define kGoogleMapsLocationKey @"location"
#define kGoogleMapsLatitudeKey @"lat"
#define kGoogleMapsLongitudeKey @"lng"

#define kGoogleMapsIconKey @"icon"
#define kGoogleMapsPlaceIdKey @"place_id"
#define kGoogleMapsNameKey @"name"

#define kGoogleMapsPredictionsKey @"predictions"
#define kGoogleMapsPredictionDescriptionKey @"description"


#define kMaxResultsLimit 100

@implementation PlacesWebRequestsHelper

+(void)findPlacesNearbyCoordinate:(CLLocationCoordinate2D)coordinate radius:(NSInteger)radius completionBlock:(PlacesNearbyCompletionBlock)completionBlock {
    if (radius > 0) {
        NSString *urlString = [NSString stringWithFormat:kFormatForNearByPlaces, coordinate.latitude, coordinate.longitude, @(radius), kGoogleMapsUrlApiKey];
        [Communicator makeGetRequestToUrl:urlString resultBlock:^(BOOL succeeded, NSDictionary *jsonAsDictionary, NSError *error) {
            NSArray *places = nil;
            if (!error) {
                NSLog(@"findPlacesNearbyCoordinate succeeded, json = %@",[jsonAsDictionary description]);
                
                // Validate before parsing
                if (jsonAsDictionary.count && [jsonAsDictionary[kGoogleMapsResultsKey] count]) {
                    NSArray *placesArrayFromJson = jsonAsDictionary[kGoogleMapsResultsKey];
                    
                    // Limiting the results to preserve memory
                    if (placesArrayFromJson.count < kMaxResultsLimit) {
                        NSMutableArray *placesArray = [NSMutableArray new];
                        for (NSDictionary *placeAsDictionary in placesArrayFromJson) {
                            // Validate before parsing
                            if (jsonAsDictionary.count && [jsonAsDictionary[kGoogleMapsResultsKey] count]) {
                                Place *place = [Place new];
                                NSDictionary *jsonLocation = placeAsDictionary[kGoogleMapsGeometryKey][kGoogleMapsLocationKey];
                                place.placePosition = CLLocationCoordinate2DMake([jsonLocation[kGoogleMapsLatitudeKey] floatValue],[jsonLocation[kGoogleMapsLongitudeKey] floatValue]);
                                place.iconUrl = placeAsDictionary[kGoogleMapsIconKey];
                                place.placeId = placeAsDictionary[kGoogleMapsPlaceIdKey];
                                place.placeName = placeAsDictionary[kGoogleMapsNameKey];
                                
                                [placesArray addObject:place];
                            }
                        }
                        places = [NSArray arrayWithArray:placesArray];
                    }
                }
            } else {
                NSLog(@"Error in communication to URL:%@\nError:%@", urlString, error);
            }
            
            if (completionBlock) {
                completionBlock(error == nil, places);
            }
        }];
    } else {
        // No radius is given, return an empty list of places
        if (completionBlock) {
            completionBlock(YES, [NSArray new]);
        }
    }
}

+(void)findAddressByCoordinate:(CLLocationCoordinate2D)coordinate completionBlock:(AddressByCoordinateCompletionBlock)completionBlock {
    NSString *urlString = [NSString stringWithFormat:kFormatForGeocode, coordinate.latitude, coordinate.longitude, kGoogleMapsUrlApiKey];
    [Communicator makeGetRequestToUrl:urlString resultBlock:^(BOOL succeeded, NSDictionary *jsonAsDictionary, NSError *error) {
        NSString *address = @"";
        if (!error) {
            NSLog(@"findAddressByCoordinate succeeded, json = %@",[jsonAsDictionary description]);
            // Validate before parsing
            if (jsonAsDictionary.count && [jsonAsDictionary[kGoogleMapsResultsKey] count]) {
                address = jsonAsDictionary[kGoogleMapsResultsKey][0][kGoogleMapsFormattedAddressKey];
            }
        } else {
            NSLog(@"Error in communication to URL:%@\nError:%@", urlString, error);
        }
        
        if (completionBlock) {
            completionBlock(error == nil, address);
        }
    }];
}

+(void)getAutocompleteFromPhrase:(NSString *)phrase completionBlock:(AutocompleteCompletionBlock)completionBlock {
    if (phrase.length) {// checks also nil
        NSString *urlString = [NSString stringWithFormat:kFormatForAutocompletePlacesSearch, phrase, kGoogleMapsUrlApiKey];
        [Communicator makeGetRequestToUrl:urlString resultBlock:^(BOOL succeeded, NSDictionary *jsonAsDictionary, NSError *error) {
            NSMutableArray *predictions = [NSMutableArray new];
            if (!error) {
                NSLog(@"findAddressByCoordinate succeeded, json = %@",[jsonAsDictionary description]);
                // Validate before parsing
                if (jsonAsDictionary.count && [jsonAsDictionary[kGoogleMapsPredictionsKey] count]) {
                    NSArray *predictionsArrayFromJson = jsonAsDictionary[kGoogleMapsPredictionsKey];
                    for (NSDictionary *predictionAsDictionary in predictionsArrayFromJson) {
                        // Validate before parsing
                        if (predictionAsDictionary.count &&
                            predictionAsDictionary[kGoogleMapsPredictionDescriptionKey] &&
                            predictionAsDictionary[kGoogleMapsPlaceIdKey]) {
                            Prediction *prediction = [Prediction new];
                            prediction.predictionDescription = predictionAsDictionary[kGoogleMapsPredictionDescriptionKey];
                            prediction.placeId = predictionAsDictionary[kGoogleMapsPlaceIdKey];
                            [predictions addObject:prediction];
                        }
                    }
                }
            } else {
                NSLog(@"Error in communication to URL:%@\nError:%@", urlString, error);
            }
            
            if (completionBlock) {
                completionBlock(error == nil, [NSArray arrayWithArray:predictions]);
            }
        }];
    } else {
        if (completionBlock) {
            completionBlock(YES, [NSArray new]);
        }
    }
}

@end