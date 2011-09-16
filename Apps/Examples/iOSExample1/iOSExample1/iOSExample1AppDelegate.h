//
//  iOSExample1AppDelegate.h
//  iOSExample1
//
//  Created by Frank Denbow on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iOSExample1ViewController;

@interface iOSExample1AppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet iOSExample1ViewController *viewController;

@end
