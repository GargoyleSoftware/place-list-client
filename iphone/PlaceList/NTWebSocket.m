//
//  NTWebSocket.m
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import "JSON.h"

#import "NTWebSocket.h"

#import "Macros.h"
#import "SongModel.h"

#define SOCKET_URL @"ws://jordanorelli.com:8080/socket" 

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
     
  }
  return self;

}

#pragma mark - DEMO Methods

#pragma mark - Public Methods

- (void)send:(id)data
{
  [self.ws send: data];
}

- (void)open
{
  NSURLRequest *req = [NSURLRequest requestWithURL: 
                       [NSURL URLWithString: SOCKET_URL]
                       ];
  NSLog(@"Opening socket with URL: %@", [req URL]);

  self.ws = [[SRWebSocket alloc] initWithURLRequest: req];
  self.ws.delegate = self;
  [self.ws open];
}

- (void)close
{
  [self.ws close];
}

#pragma mark - SRWebSocketDelegate Methods


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message {

  //Hooray! I got a message to print.
  NSLog(@"Did receive message: %@", message);
  NSString *example = @"{\"cmd\":\"event_info\",\"params\":{\"event_id\":\"365778960128138\",\"user_id\":\"1332960041\",\"upcoming\":null,\"history\":null}}";
  
  //NSDictionary *json = [message JSONValue];
  NSDictionary *json = [example JSONValue];
  NSString *command = [json objectForKey: @"cmd"];
  NSDictionary *params = [json objectForKey: @"params"];

  
  if ([command isEqualToString: @"event_info"]) {
    NSDictionary *upcoming = [params objectForKey: @"upcoming"];
    if (NOT_NULL(upcoming)) {
    for (NSString *trackId in [upcoming allKeys]) {
      NSInteger points = [[upcoming objectForKey: trackId] length];
      [[SongModel sharedInstance] addTrackId: trackId points: points];
    }
    }
  } else if ([command isEqualToString: @"add_track"]) {
    NSString *trackId = [params objectForKey: @"track_id"];
    [[SongModel sharedInstance] addTrackId: trackId];
  } else {
    NSLog(@"I don't know what to do. Command: %@", command);
  }

}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {

  NSLog(@"Socket is open for business.");

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
