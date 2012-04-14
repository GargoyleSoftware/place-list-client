//
//  NTWebSocket.h
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebSocket.h"

@interface NTWebSocket : NSObject <WebSocketDelegate> {
  @private
      WebSocket* ws;
}

@property (nonatomic, readonly) WebSocket* ws;

- (void) startWebSocket;

@end

