//
//  AppDelegate.m
//  SlackAuths
//
//  Created by Louis Tur on 11/9/14.
//  Copyright (c) 2014 Louis Tur. All rights reserved.
//

#import "AppDelegate.h"
#import "SpotifyAuthViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    
    return YES;
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    /*
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kSpotifyRedirectURI]]) {
        
        // Call the token swap service to get a logged in session
        [[SPTAuth defaultInstance]
         handleAuthCallbackWithTriggeredAuthURL:url
         tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kSpotifyTokenURI]
         callback:^(NSError *error, SPTSession *session) {
             
             if (error != nil) {
                 NSLog(@"*** Auth error: %@", error);
                 return;
             }
             
             // Call the -playUsingSession: method to play a track
             NSLog(@"lol all is good");
         }];
        return YES;
    }*/
    
    return YES;

}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    NSLog(@"Handling the url?");
    
    return YES;
}

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    
    NSLog(@"IDK, is this called?");
    
}


@end
