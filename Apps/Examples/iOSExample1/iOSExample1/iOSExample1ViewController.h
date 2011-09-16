//
//  iOSExample1ViewController.h
//  iOSExample1
//
//  Created by Frank Denbow on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iOSExample1ViewController : UIViewController {
    UITextField *tempText;
    UILabel *resultLabel;
    
}

@property (nonatomic, retain) IBOutlet UILabel *resultLabel;
@property (nonatomic, retain) IBOutlet UITextField *tempText;

- (IBAction)changeTemp :(id)sender;

@end
