//
//  PicsicleAppDelegate.h
//  Picsicle
//
//  Created by Frank Denbow on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PicsicleViewController;

@interface PicsicleAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PicsicleViewController *viewController;

@end
