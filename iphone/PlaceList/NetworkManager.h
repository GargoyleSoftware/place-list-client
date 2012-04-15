//
//  NetworkManager.h
//  PlaceList
//
//  Created by David Kay on 4/15/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FBConnect.h"

@class NTWebSocket;

@interface NetworkManager : NSObject <FBRequestDelegate>

+ (NetworkManager *)sharedInstance;

@property (nonatomic, retain) NTWebSocket *webSocket;
@property (nonatomic, retain) NSString *eventId;

- (BOOL)openSocketConnectionWithEvent:(NSString *)eventId;
- (void)closeSocketConnection;

- (void)getFacebookId;

- (void)upvoteTrack:(NSString *)trackId remove:(BOOL)remove;

@end
