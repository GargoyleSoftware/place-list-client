//
//  SongModel.h
//  PlaceList
//
//  Created by David Kay on 4/15/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongModel : NSObject

@property (nonatomic, retain) NSMutableDictionary *songs;

+ (SongModel *)sharedInstance;

- (void)addTrackId:(NSString *)trackId;
- (void)addTrackId:(NSString *)trackId points:(NSInteger)points;

@end
