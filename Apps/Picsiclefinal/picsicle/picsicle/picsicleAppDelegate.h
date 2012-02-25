//
//  picsicleAppDelegate.h
//  picsicle
//
//  Created by Frank Denbow on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class picsicleViewController;

@interface picsicleAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet picsicleViewController *viewController;

@end
