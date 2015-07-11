//
//  AppDelegate.m
//  CandidateProject
//
//  Created by Perry Shalom on 7/9/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import "AppDelegate.h"
#import "UsefulStrings.h"
@import GoogleMaps;

#define kGoogleMapsSdkApiKey @"AIzaSyC4E7gUIvrOpZgZ1Ywkl71AC89bV5Pv09E"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSSetUncaughtExceptionHandler(&perrysExceptionHandler);

    [GMSServices provideAPIKey:kGoogleMapsSdkApiKey];
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Exceptions & Crashes Handler

void perrysExceptionHandler(NSException *exception)
{
    NSLog(@"Caught Exception:\n%@", exception);
    NSArray *stack = [exception callStackSymbols];
    NSLog(@"Stack Trace:\n%@", stack);
    NSDictionary *dataAsDictionary;
    if (stack) {
        dataAsDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"], @"BuildNumber", [exception name], @"ExeptionMessage", [exception reason], @"Action", [stack description], @"Stack Trace", nil];
    } else {
        dataAsDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"], @"BuildNumber", [exception name], @"ExeptionMessage", [exception reason], @"Action", nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject: dataAsDictionary forKey: kPersistanceLastCrashKey];
    if ([[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"Crash details saved");
    }
}

@end