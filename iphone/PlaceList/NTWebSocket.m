//
//  NTWebSocket.m
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import "NTWebSocket.h"

#import "UserHelper.h"

#define SOCKET_URL @"ws://localhost:8080/socket" 

@interface NTWebSocket ()

@property (nonatomic, readwrite, retain) SRWebSocket* ws;

@end

@implementation NTWebSocket

@synthesize ws;

#pragma mark - Initialization

- (id)init
{
  self = [super init];
  if (self) 
  {
    NSURLRequest *req = [NSURLRequest requestWithURL: 
      [NSURL URLWithString: SOCKET_URL]
    ];
    NSLog(@"Opening socket with URL: %@", [req URL]);
    self.ws = [[SRWebSocket alloc] initWithURLRequest: req];
    self.ws.delegate = self;
  }
  return self;

}

#pragma mark - DEMO Methods

- (void) startWebSocket
{
  [self open];

  ////continue processing other stuff
  //[self send: @"Hello World"];
}

#pragma mark - Public Methods

- (void)send:(id)data
{
  [self.ws send: data];
}

- (void)open
{
  [self.ws open];
}

- (void)close
{
  [self.ws close];
}

#pragma mark - Login Methods

- (void)login 
{

  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
    [UserHelper getUsername], @"user_id",
  nil];
  
  NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
    @"login", @"cmd",
    params, @"params",
  nil];

  [self send: jsonDict];

}

#pragma mark - SRWebSocketDelegate Methods


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message {

  //Hooray! I got a message to print.
  NSLog(@"Did receive message: %@", message);

}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {

  NSLog(@"Socket is open for business.");

  [self login];
}


- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error { 

  NSLog(@"Oops. An error occurred. Error: %@", error);

}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean { 
    

  NSLog(@"Oops. It closed with code: %d. Reason: %@", code, reason);


}

#pragma mark - Cleanup

- (void)dealloc 
{
  [ws release];
  [super dealloc];
}


@end
