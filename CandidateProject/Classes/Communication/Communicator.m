//
//  Communicator.m
//  CandidateProject
//
//  Created by Perry Shalom on 7/9/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import "Communicator.h"

@implementation Communicator

+(void)makeGetRequestToUrl:(NSString *)urlString resultBlock:(CommunicatorResultBlock)resultBlock {
    if (urlString) {
        NSURL *url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSDictionary * innerJson = nil;
            if (!connectionError) {
                innerJson = [NSJSONSerialization
                                                   JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&connectionError
                                                   ];
            }
            if (resultBlock) {
                resultBlock(YES, innerJson, connectionError);
            }
        }];
    } else {
        if (resultBlock) {
            resultBlock(NO, nil, [NSError errorWithDomain:NSPOSIXErrorDomain code:101 userInfo:nil]);
        }
    }
}

@end