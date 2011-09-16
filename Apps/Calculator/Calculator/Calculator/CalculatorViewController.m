//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Frank Denbow on 9/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"

@implementation CalculatorViewController

-(CalculatorBrain *)brain{
    if(!brain){
       brain= [[CalculatorBrain alloc] init];
    }
    
    return brain;
}

- (IBAction)digitPressed:(UIButton *)sender{
    NSString *digit = [[sender titleLabel] text];
    
    if(userIsTypingNumber){
        [display setText:[[display text] stringByAppendingString:digit]];
    }
    else{
        [display setText:digit];
        userIsTypingNumber = YES;
    }
    
}
- (IBAction)operationPresed:(UIButton *)sender{
    if(userIsTypingNumber){
        [[self brain] setOperand:[[display text] doubleValue]];
        userIsTypingNumber= NO;
    }
    NSString *operation = [[sender titleLabel] text];
    double result = [[self brain] performOperation:operation];
    [display setText:[NSString stringWithFormat:@"%g", result]];
}

@end
