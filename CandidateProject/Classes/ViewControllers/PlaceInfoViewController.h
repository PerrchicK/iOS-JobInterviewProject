//
//  PlaceInfoViewController.h
//  CandidateProject
//
//  Created by Perry Shalom on 7/11/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GMSPlace.h>

@class PlaceInfoViewController;

/**
 Delegate for handling this view controller's requests
 */
@protocol PlaceInfoViewControllerDelegate <NSObject>

/**
 The callback to invoke when the download process is finished
 */
-(void) placeInfoViewController:(PlaceInfoViewController *)placeInfoViewController navigateToCoordinate:(CLLocationCoordinate2D)coordinate;
-(void) placeInfoViewControllerDone:(PlaceInfoViewController *)placeInfoViewController;

@end

@interface PlaceInfoViewController : UIViewController

@property (nonatomic, strong) GMSPlace *place;
@property (nonatomic, weak) id<PlaceInfoViewControllerDelegate> delegate;

@end