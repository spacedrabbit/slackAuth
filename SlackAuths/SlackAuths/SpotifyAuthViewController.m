//
//  SpotifyAuthViewController.m
//  SlackAuths
//
//  Created by Louis Tur on 11/10/14.
//  Copyright (c) 2014 Louis Tur. All rights reserved.
//
#import "AppDelegate.h"
#import "SpotifyAuthViewController.h"
#import <Spotify/Spotify.h>

#import <Spotify/Spotify.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIWebView+AFNetworking.h>

/*
 
 - must be GET request with headers set -
 GET /1/classes/Users/xOQ1BJGl3X HTTP/1.1
 Host: api.parse.com
 X-Parse-REST-API-Key: YkKRL42ZVIDPNrvFqLSIjoHSXA8p5t0SI4hfmSM3
 X-Parse-Application-Id: 5HQQuuB7Oo85wgcQuOElTPyy81aexHCttCSf5OIi
 Cache-Control: no-cache
 
 response JSON
 {
 "createdAt": "2014-11-04T03:09:50.345Z",
 "hasVoted": 0,
 "isAdmin": false,
 "name": "Louis",
 "objectId": "xOQ1BJGl3X",
 "receivedDownvotes": 0,
 "receivedUpvotes": 0,
 "timesAdmin": 1,
 "topSongs": [
 "testsong"
 ],
 "updatedAt": "2014-11-10T16:55:24.358Z"
 }
 
 */

// -- (PARSE) spotifyGlos           --//
// -- https://api.parse.com/1/users --//
static NSString * const kParseApplicationID = @"5HQQuuB7Oo85wgcQuOElTPyy81aexHCttCSf5OIi";
static NSString * const kParseRESTKey = @"YkKRL42ZVIDPNrvFqLSIjoHSXA8p5t0SI4hfmSM3";

// -- (SPOTIFY) spotifyCreds --//
static NSString * const kSpotifyAccountType =@"spotify";
static NSString * const kSpotifyClientSecret = @"ea449fa4da8044ad8bcf67e58c30934a";
static NSString * const kSpotifyClientID = @"b1888b168ab341f19b1b6a3e257f76d9";

// -- (SPOTIFY) spotifyURIS --//
//static NSString * const kSpotifyRedirectURI = @"https://api.parse.com/1/users/xOQ1BJGl3X";
static NSString * const kSpotifyAuthURI = @"https://accounts.spotify.com/authorize";
//static NSString * const kSpotifyTokenURI = @"https://slack.com/api/oauth.access";
static NSString * const kSpotifyRedirectURI = @"glos://returnAfterAuth";
static NSString * kSpotifyToken=@"";

@interface SpotifyAuthViewController () <UIApplicationDelegate>

@property (strong, nonatomic) SPTAuth * spotifyAuthClient;

@end

@implementation SpotifyAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setDelegate:self];
    [SpotifyAuthViewController createAuthSessionForSpotify];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(void) createAuthSessionForSpotify{
    
    AFURLSessionManager * urlSession = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSNumber * hashKey = [NSNumber numberWithInteger:[[NSDate date] hash]];
    NSDictionary * jsonRequestParameters = @{ @"client_id"      :kSpotifyClientID,
                                              @"response_type"  :@"token",
                                              @"redirect_uri"   :[NSURL URLWithString:kSpotifyRedirectURI],
                                              
                                              @"scope"          :@[@"streaming",@"user-read-private"],
                                              @"show_dialog"    :@"true"
                                             };
    //@"state"          :[hashKey stringValue], // --- maybe add if all else is working
    AFJSONRequestSerializer *jsonRequestWhyNot = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest * spotifyRequest = [jsonRequestWhyNot requestWithMethod:@"GET"
                                                                      URLString:kSpotifyAuthURI
                                                                     parameters:jsonRequestParameters
                                                                       error:nil];
    
    /*
    //-- URL pre-3 leg: https://accounts.spotify.com/authorize?client_id=b1888b168ab341f19b1b6a3e257f76d9&scope=streaming%20user-library-read%20user-read-private%20user-read-email&redirect_uri=glos%3A%2F%2FreturnAfterAuth&download_prompt=true&response_type=code
        
        */
    /*
     //-- URL Post 3:https://accounts.spotify.com/authorize?client_id=b1888b168ab341f19b1b6a3e257f76d9&redirect_uri=glos%3A%2F%2Freturnafterauth&response_type=token&scope%5B%5D=streaming&scope%5B%5D=user-read-private&show_dialog=false&state=437359917
     */
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:spotifyRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        NSLog(@"**** THE RESPONSE:\n\n %@", response);
        
        NSJSONSerialization * jsonObj = (NSJSONSerialization *)responseObject;
        
        if ([NSJSONSerialization isValidJSONObject:responseObject]) {
            NSLog(@"(AS*F){(ASF{)AS(UF{OASIYFO{ASIFY VALID JSON");
            if ( jsonObj ) {
                //
            }
        }
        NSLog(@"**** THe RESPONSEOBJECT: %@", jsonObj);
        
        if (error) {
            NSLog(@"OH SHIT< ERRRORS: %@", error);
        }
        
    }];
    [dataTask resume];
    
    
    [urlSession setDataTaskDidBecomeDownloadTaskBlock:^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask) {
        NSLog(@"Did become download task");
        
    }];
    
    [urlSession setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response) {
        NSLog(@"Received some response");
        NSLog(@"The response from in the delegate:\n\n %@" , response);
        
        [[UIApplication sharedApplication] openURL:response.URL];

        return NSURLSessionResponseAllow;
    }];
    
    [urlSession setDataTaskDidReceiveDataBlock:^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
        NSLog(@"Data task received data");
        NSLog(@"Data from in the delegate Method: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
        NSLog(@"Additional Stuff? Is this the redirect? :\n\n ");
        NSLog(@"The NSURLSession: %@", session);
        NSLog(@"The Data task returned: %@", dataTask);
        
    }];
    
    
    
    [urlSession setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest *(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request) {
        //will do this at some point...
        
        NSLog(@"Performing Redirect Block");
        return [NSURLRequest requestWithURL:nil];
    }];
    [urlSession setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *credential) {
        
        NSLog(@"Did receive auth challenge");
        return NSURLSessionAuthChallengeUseCredential;
    }];
    [urlSession setDataTaskDidBecomeDownloadTaskBlock:^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask) {
        
        NSLog(@"Data task did become download task block");
    }];
    [urlSession setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@" Did send body data block");
    }];
    
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    if ( [[url absoluteString] hasPrefix:kSpotifyRedirectURI]) {
        NSLog(@"%@", [url absoluteString]);
        
    }

    return YES;
}



@end
