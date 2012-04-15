//
//  SongModel.m
//  PlaceList
//
//  Created by David Kay on 4/15/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import "SongModel.h"

#define LIKE_POINTS 1

@implementation SongModel

@synthesize songs = _songs;

#pragma mark -  Singleton

static SongModel * gSongModel;
+ (SongModel *)sharedInstance {
  if (!gSongModel) {
    gSongModel = [[SongModel alloc] init];
  }

  return gSongModel;
}

#pragma mark - Initialization

- (id)init
{
  if (self = [super init]) {
    self.songs = [NSMutableDictionary dictionary];
  }
  return self;
}

#pragma mark - 

- (void)addTrackId:(NSString *)trackId points:(NSInteger)points
{

  if ([self.songs objectForKey: trackId]) {
    NSNumber *old = [self.songs objectForKey: trackId];
    [self.songs setObject: [NSNumber numberWithInteger: points + [old integerValue]]
		   forKey: trackId];
  } else {
    [self.songs setObject: [NSNumber numberWithInteger: points]
		   forKey: trackId];
  }

}

- (void)addTrackId:(NSString *)trackId
{
  [self addTrackId: trackId points: LIKE_POINTS];
}

@end
