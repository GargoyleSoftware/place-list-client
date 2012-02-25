//
//  PixAppDelegate.h
//  Pix
//
//  Created by Frank Denbow on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PixViewController;

@interface PixAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PixViewController *viewController;

@end
