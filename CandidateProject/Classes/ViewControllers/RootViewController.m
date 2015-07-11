//
//  RootViewController.m
//  CandidateProject
//
//  Created by Perry Shalom on 7/9/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import "RootViewController.h"
#import "MapViewController.h"
#import "UsefulStrings.h"

#define kTagForLastCrashAlertView 100

@interface RootViewController ()<UIAlertViewDelegate>

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MapViewController *startingViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MapViewController class])];

    [self addChildViewController:startingViewController];
    [self.view addSubview:startingViewController.view];
    
    // Check if last crash exists
    /*
     Perry: I know, there are many other ways to follow crashes.
     I decided to do it this way for my own manual QA tests.
     */
    NSDictionary *lastCrashDictionary = [[NSUserDefaults standardUserDefaults] objectForKey: kPersistanceLastCrashKey];
    if (lastCrashDictionary) {
        // Present crash and ask for confirmation to delete
        UIAlertView *crashAlertView = [[UIAlertView alloc] initWithTitle:@"Last crash - delete?" message:[lastCrashDictionary description] delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Delete", nil];
        crashAlertView.tag = kTagForLastCrashAlertView;
        [crashAlertView show];
    } else {
        //[self performSelector:@selector(_navigateToNextScre)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertView delegate method(s)

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kTagForLastCrashAlertView && buttonIndex > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kPersistanceLastCrashKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end