//
//  ViewController.m
//  OauthEchoTest
//
//  Created by Noto Kaname on 12/04/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#include <dispatch/dispatch.h>

@interface ViewController ()

@end

@implementation ViewController
{
    ACAccountStore* _accountStore;
    NSString* _userID;
}

- (void) getTwitterAccounts {
	// Create an account store object.
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
	[accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		if(granted) {
			// Get the list of Twitter accounts.
            __weak NSArray* accountsArray = [accountStore accountsWithAccountType:accountType];
            
            /*
             for (NSObject* account in accountsArray ) {
             NSLog(@"account=%@", account );
             }
             */
            
            _userID =  ((ACAccount*)[accountsArray objectAtIndex:0]).identifier;
            
            
		}else {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"認証が却下されました。" message:@"アプリの認証が却下されました設定画面から確認してください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
        }
	}];
}

- (void)sendRequestWithOauthEchoHeaders
{
	_accountStore = [[ACAccountStore alloc] init];
	ACAccount *twitterAccount = [_accountStore accountWithIdentifier:_userID ];
    
    // Create signed OAuth request.
    NSURL *spURL = [NSURL URLWithString:@"https://api.twitter.com/1/account/verify_credentials.json"];
    TWRequest *twRequest = [[TWRequest alloc] initWithURL:spURL parameters:nil requestMethod:TWRequestMethodGET];
    [twRequest setAccount:twitterAccount];
    NSURLRequest *signedURLRequest = [twRequest signedURLRequest];
    
    // Create API request with OAuth Echo headers.
    NSURL *apiURL = [NSURL URLWithString:/*@"http://api.twitpic.com/2/upload.json"*/ @"http:edl.sakura.ne.jp/oauthechotest/upload.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    
    NSString *serviceProvider = [[signedURLRequest URL] absoluteString];
    [request setValue:serviceProvider forHTTPHeaderField:@"X-Auth-Service-Provider"];
    
//    NSLog(@"X-Auth-Service-Provider=%@", serviceProvider );
    NSString *authorization = [signedURLRequest valueForHTTPHeaderField:@"Authorization"];
    [request setValue:authorization forHTTPHeaderField:@"X-Verify-Credentials-Authorization"];
    
//    NSLog(@"X-Verify-Credentials-Authorization=%@", authorization );
    // ...and, set parameters and send the request.
    
    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSError* error = nil;
        NSURLResponse* response = nil;
        
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        char* utf8String = malloc([data length]+1);
        [data getBytes:utf8String length:[data length] ];
        utf8String[[data length]] = '\0';
        NSString* resultString = [NSString stringWithUTF8String:utf8String];
        NSLog(@"resultString=%@",resultString);
        free(utf8String);
        
    });
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getTwitterAccounts];
}

- (IBAction)firedSend:(id)sender
{
    [self sendRequestWithOauthEchoHeaders];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
