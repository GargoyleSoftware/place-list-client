//
//  iOSExample1ViewController.m
//  iOSExample1
//
//  Created by Frank Denbow on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iOSExample1ViewController.h"

@implementation iOSExample1ViewController

@synthesize tempText, resultLabel;

-(void) changeTemp:(id)sender{
    
    double farenheight = [tempText.text doubleValue];
    double celcius = (farenheight - 32) / 1.8;
    
    NSString *newText = [[NSString alloc] initWithFormat:@"Celcius %f", celcius];
    resultLabel.text = newText;
    [newText release];

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
