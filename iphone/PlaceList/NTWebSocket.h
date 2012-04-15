//
//  NTWebSocket.h
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRWebSocket.h"

@interface NTWebSocket : NSObject <SRWebSocketDelegate> {
}

@property (nonatomic, readonly, retain) SRWebSocket* ws;

- (void)send:(id)data;
- (void)open;
- (void)close;


@end

