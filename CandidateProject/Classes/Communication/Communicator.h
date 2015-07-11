//
//  Communicator.h
//  CandidateProject
//
//  Created by Perry Shalom on 7/9/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CommunicatorResultBlock)(BOOL succeeded, NSDictionary *jsonAsDictionary, NSError *error);

@interface Communicator : NSObject

+(void)makeGetRequestToUrl:(NSString *)urlString resultBlock:(CommunicatorResultBlock)resultBlock;

@end