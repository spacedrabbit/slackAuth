//
//  AppDelegate.m
//  SlackAuths
//
//  Created by Louis Tur on 11/9/14.
//  Copyright (c) 2014 Louis Tur. All rights reserved.
//

#import "AppDelegate.h"
#import "SlackAPISessionManager.h"
#import <NXOAuth2Client/NXOAuth2.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [SlackAPISessionManager initialize];
    [SlackAPISessionManager createRequestForService:@"slack" withCompletion:^(BOOL success) {
        if (success) {
            NSLog(@"it was successful");
        }else{
            NSLog(@"not success");
        }
    }];

    
    return YES;
}




@end
