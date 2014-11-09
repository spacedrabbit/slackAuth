//
//  SlackAPISessionManager.m
//  SlackAuths
//
//  Created by Louis Tur on 11/9/14.
//  Copyright (c) 2014 Louis Tur. All rights reserved.
//

#import "SlackAPISessionManager.h"
#import <NXOAuth2Client/NXOAuth2.h>
#import <AFNetworking/AFNetworking.h>
#import <UIWebView+AFNetworking.h>

static NSString * const kSlackClientID = @"2727337933.2963733646";
static NSString * const kSlackClientTeam = @"T02MD9XTF";//@"Fall-2014";

//static NSString * const kSlackRedirectURI = @"https://fis-fall-2014.slack.com";

static NSString * const kSlackRedirectURI = @"myApp://redirectSlack.com";
static NSString * const kSlackClientSecret = @"f08de1a24342e7683755d2080b7dd6a1";
//static NSString * const kSlackAuthURI = @"https://slack.com/oauth/authorize";
static NSString * const kSlackAuthURI = @"https://slack.com/api/api.test";
static NSString * const kSlackTokenURI = @"https://slack.com/api/oauth.access";
static NSString * const kSlackAccountType =@"slack";

@interface SlackAPISessionManager()<NSURLSessionDelegate>


@end

@implementation SlackAPISessionManager

+(void)initialize{
    
    static SlackAPISessionManager * sharedSlackAPIManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSlackAPIManager = [[SlackAPISessionManager alloc] init];

    });
    
    [[NXOAuth2AccountStore sharedStore] setClientID:kSlackClientID
                                             secret:kSlackClientSecret
                                   authorizationURL:[NSURL URLWithString:kSlackAuthURI]
                                           tokenURL:[NSURL URLWithString:kSlackTokenURI]
                                        redirectURL:[NSURL URLWithString:kSlackRedirectURI]
                                     forAccountType:kSlackAccountType];
    
}

/*
https://slack.com/oauth/authorize?client_id=2727337933.2963733646&response_type=code&redirect_uri=https%3A%2F%2Ffis-fall-2014.slack.com

 this is the request url for the GET code requst
Request URL:https://fis-fall-2014.slack.com/?code=2727337933.2968451529.2e56b54dcb&state=
code=2727337933.2968451529.2e56b54dcb&state=
 need to GET that URL
 then POST it
 response hedear has a key of location: https://fis-fall-2014.slack.com?code=2727337933.2968473771.c7fb7b408b&state=

full url for auth request
https://fis-fall-2014.slack.com/oauth/authorize/2969782734.2d7820f150

 these are URL extensions for picking a team and authorizing the team, respectively
 oauth/pick/2969823878.2b78bccd82
 oauth/authorize/2969849160.893967356c

 this is the code on the accept button
<form action="/oauth/authorize/2968394521.8faa92cdab" method="post" accept-encoding="UTF-8" class="large_bottom_margin align_center">
*/

+(void) createRequestForService:(NSString *)service withCompletion:(void(^)(BOOL))success{
    
    
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"slack" withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        
        UIWindow *baseWindow = [[[UIApplication sharedApplication] delegate] window];
        UIViewController *baseViewController = baseWindow.rootViewController;

        
        UIViewController *loginWindowController = [[UIViewController alloc] init];
        //[loginWindowController setModalPresentationStyle:UIModalPresentationOverFullScreen];
        
        UIWebView *authenticationWindow = [[UIWebView alloc] initWithFrame:baseWindow.frame];
        
        [loginWindowController setView:authenticationWindow];
        
        [baseWindow addSubview:authenticationWindow];

        //[baseViewController addChildViewController:loginWindowController];
        [baseViewController presentViewController:loginWindowController animated:YES completion:^{
           
            
            
        }];
        //[[UIApplication sharedApplication] ]
        
        
    }];
}


@end
