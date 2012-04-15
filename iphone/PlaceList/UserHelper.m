//
//  UserHelper.m
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import "UserHelper.h"

@implementation UserHelper

+ (NSString *)getUUID
{
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  CFRelease(theUUID);
  return [(NSString *)string autorelease];
}


static NSString *gUsername = nil;

+ (NSString *)getUsername
{
  if (!gUsername) {
    gUsername = [[self class] getUUID];
  }
  return gUsername;
}

@end
