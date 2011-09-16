//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Frank Denbow on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorBrain.h"

@interface CalculatorViewController : UIViewController {
    IBOutlet UILabel *display;
    CalculatorBrain *brain;
    BOOL userIsTypingNumber;
}

- (IBAction)digitPressed:(UIButton *)sender;
- (IBAction)operationPresed:(UIButton *)sender;

@end
