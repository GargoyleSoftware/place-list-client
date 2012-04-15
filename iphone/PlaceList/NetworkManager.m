//
//  NetworkManager.m
//  PlaceList
//
//  Created by David Kay on 4/15/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import "JSON.h"

#import "NetworkManager.h"

#import "NTWebSocket.h"
#import "NTAppDelegate.h"

@implementation NetworkManager

@synthesize webSocket = _webSocket;

static NetworkManager * gNetworkManager;
+ (NetworkManager *)sharedInstance {
  if (!gNetworkManager) {
    gNetworkManager = [[NetworkManager alloc] init];
  }

  return gNetworkManager;
}

#pragma mark - Initialization

- (id)init
{
  if (self = [super init]) {
    NTWebSocket* webSocket = [[[NTWebSocket alloc] init] autorelease];
    self.webSocket = webSocket;
    [self.webSocket open];
  }
  return self;
}

#pragma mark - Facebook

- (void)getFacebookId
{
  NTAppDelegate *appDelegate = (NTAppDelegate *)[[UIApplication sharedApplication] delegate];
  // get information about the currently logged in user
  [appDelegate.facebook requestWithGraphPath:@"me" andDelegate: self];
}

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request {
  
  NSLog(@"requestLoading");

}

/**
 * Called when the Facebook API request has returned a response.
 *
 * This callback gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {

  NSLog(@"didReceiveResponse");
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {

  NSLog(@"didFailWithError: %@", error);
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {

  NSLog(@"didLoad: %@", result);

  NSDictionary *dict = (NSDictionary *)result;

  [self saveUserId: [dict objectForKey: @"id"]];

}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {

  NSLog(@"didLoadRawResponse");

}

#pragma mark - Persistence

- (NSString *)loadUserId
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; 
  return [userDefaults objectForKey: @"username"];
}

- (void)saveUserId:(NSString *)userId
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; 
  [userDefaults setObject: userId forKey: @"username"];
  [userDefaults synchronize];
}

#pragma mark - Public Methods

//- (void)openSocketConnection
- (BOOL)openSocketConnectionWithEvent:(NSString *)eventId;
{
  //[self.webSocket open];

  //NTAppDelegate *appDelegate = (NTAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSString *facebookId = [self loadUserId];

  if (!facebookId) {
    return NO;
  } else {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
      facebookId , @"user_id"  , 
      eventId    , @"event_id" , 
    nil];

    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
      @"login" , @"cmd"    , 
      params   , @"params" , 
      nil];

    while (self.webSocket.ws.readyState != SR_OPEN) {
      // Wait forever
      NSLog(@"waiting");
    }

    [self.webSocket send: [jsonDict JSONRepresentation]];

    return YES;
  }
}

- (void)closeSocketConnection
{
  //[self.webSocket close];
}

@end
