//
//  Picsicle2AppDelegate.h
//  Picsicle2
//
//  Created by Frank Denbow on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Picsicle2ViewController;

@interface Picsicle2AppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet Picsicle2ViewController *viewController;

@end
