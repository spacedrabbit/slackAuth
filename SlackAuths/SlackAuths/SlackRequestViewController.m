//
//  SlackRequestViewController.m
//  SlackAuths
//
//  Created by Louis Tur on 11/9/14.
//  Copyright (c) 2014 Louis Tur. All rights reserved.
//

//ugh... this is a mess... refactor and remove unneeded dependancies 
#import "SlackRequestViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/UIWebView+AFNetworking.h>
#import <AFNetworking/UIProgressView+AFNetworking.h>

#import "SlackAPISessionManager.h"
#import <AFOAuth2Client/AFOAuth2Client.h>
#import <NXOAuth2Client/NXOAuth2.h>

#import <MBProgressHUD/MBProgressHUD.h>

// -- Slack API Info --//
// Info is for "glos" app project
static NSString * const kSlackClientID = @"2727337933.2963733646";
static NSString * const kSlackClientSecret = @"f08de1a24342e7683755d2080b7dd6a1";
static NSString * const kSlackClientTeam = @"T02MD9XTF";//@"Fall-2014";
static NSString * const kSlackAccountType =@"slack";

// -- Slack URI's --//
static NSString * const kSlackRedirectURI = @"myApp://redirectSlack.com";
static NSString * const kSlackAuthURI = @"https://slack.com/oauth/authorize";
static NSString * const kSlackTokenURI = @"https://slack.com/api/oauth.access";


@interface SlackRequestViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *slackWebAPIRequest;
@property (strong, nonatomic) NSMutableURLRequest *slackURLRequest;

@end

@implementation SlackRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blueColor]];
    
    // -- Move this to main implementation so that this segue doesnt happen at all
    // -- for users that are logged in
    
    if ( [AFOAuthCredential retrieveCredentialWithIdentifier:@"slack"] ) {
        NSLog(@"Saved Credentials Found");
    }else{
        
        //this loading UI can be removed... not really seen as is...
        MBProgressHUD *webLoadProgressHUD = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
        [webLoadProgressHUD setMode:MBProgressHUDModeIndeterminate];
        [webLoadProgressHUD setLabelText:@"Loading.."];
        
        
        [webLoadProgressHUD showAnimated:YES whileExecutingBlock:^{
            [self displayAuthWebPage];
        } completionBlock:^{
            [webLoadProgressHUD hide:YES afterDelay:2.0];
            NSLog(@"%lu", self.slackWebAPIRequest.dataDetectorTypes);
        }];

    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ---- AFNetworking/UIWebView ----
-(void) displayAuthWebPage{
    
    [self.slackWebAPIRequest setDelegate:self];

    NSDictionary *authParameters = @{ @"client_id":kSlackClientID,
                                      @"client_secret":kSlackClientSecret,
                                      @"team":kSlackClientTeam,
                                      @"redirect_uri":@"myapp://redirectslack.com",
                                      @"team":kSlackClientTeam,
                                      @"FROM":@"louis.tur@flatironschool.com"
                                      };
    
    
    AFHTTPRequestSerializer *requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    self.slackURLRequest = [requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat:@"%@",kSlackAuthURI] parameters:authParameters error:nil];
    
    [self.slackWebAPIRequest setScalesPageToFit:YES]; // makes shit fit.
    
    /*
     *  I love UIWebView+AFNetworking... this loadRequest:progress: method, automatically sets up a
     *  UIWebView with the correct requests and delegation methods ... swoon.
     */
    [self.slackWebAPIRequest loadRequest:self.slackURLRequest progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    } success:^NSString *(NSHTTPURLResponse *response, NSString *HTML) {
       // NSLog(@"%@", HTML);
        NSLog(@"%@", response );
        NSLog(@"The response URL: %@ ", response.URL);
        
        return HTML;
    } failure:^(NSError *error) {
        NSLog(@"You may have gotten an error, but the URLRequest was: %@ ", self.slackURLRequest);
    }];

}

//-- Delegate method for UIWebView to Start request loading
//-- Messy... needs refactoring and better documentation to be modular
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"Navigation type: %lu, The should request: %@", navigationType, request);
    
    // -- This checks to see if a form was submitted
    // -- In this case, the form is a "Submit" that corresponds to a user clicking "Accept"
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {
        NSLog(@"The Request URL: %@", request.URL);
        NSLog(@"The request headers: %@", request.allHTTPHeaderFields);
        NSLog(@"The http data: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] );
        
        // -- if it's the redirect URL, then we need to send this to the token handler + get the code
        // -- thus this checks the requestURL if it has the redirectURI prefix.. which would indicate that
        // -- the first part of this auth process has happened
        if ([[request.URL absoluteString] hasPrefix:[kSlackRedirectURI lowercaseString]]) {
            
            // -- messy way of extracting the token.. hard coded to remove the uneeded characters
            NSString * baseCode = [[request.URL absoluteString] stringByReplacingOccurrencesOfString:[kSlackRedirectURI lowercaseString] withString:@""];
            NSString * moreTrimmed = [baseCode stringByReplacingOccurrencesOfString:@"&state=" withString:@""];
            NSString * code = [moreTrimmed stringByReplacingOccurrencesOfString:@"?code=" withString:@""];
            NSLog(@"Final string: %@ ", code);
            
            //let's get a token, eh?
            AFOAuth2Client *tokenClientRequest = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:kSlackTokenURI]
                                                                                clientID:kSlackClientID
                                                                                  secret:kSlackClientSecret];
            
            [tokenClientRequest authenticateUsingOAuthWithURLString:kSlackTokenURI
                                                               code:code
                                                        redirectURI:[kSlackRedirectURI lowercaseString]
                                                            success:^(AFOAuthCredential *credential)
                {
                    //the AFOAuth does the heavy lifting here, but it gets me a token
                    NSLog(@" MY CREDENTIALS! %@", credential);
                    if ([AFOAuthCredential storeCredential:credential withIdentifier:@"slack"]) {
                        NSLog(@"credetionals stored as slack");
                    }
                    //dismiss the modally presented view
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                }
                                                            failure:^(NSError *error)
                {
                    NSLog(@"No credentials :(   \n and Error: %@", error);
                }];
        }
    }
    return YES;
}

#pragma mark ---- UIWebView+AFNetorking Delegate Methods -----
//the following are all diagnostic to see the flow
-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"Im starting to Load!");
    NSLog(@"And here's my response: %@ ", webView.responseSerializer);
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"did finish load");
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"DID FAIL %@", error);
}

#pragma mark ---- Contraints(not used) ----
//not being used
-(void) setUpConstraints{
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_slackWebAPIRequest);
    
    NSArray * webViewConstraints = @[
                                     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_slackWebAPIRequest]-|" options:0 metrics:nil views:views],
                                     
                                     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_slackWebAPIRequest]-|" options:0 metrics:nil views:views]
                                     ];
    
    for(NSArray *constraints in webViewConstraints){
        [self.view addConstraints:constraints];
    }
}

@end
