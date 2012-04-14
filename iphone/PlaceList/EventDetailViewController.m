//
//  EventDetailViewController.m
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import "EventDetailViewController.h"

#import "SongListViewController.h"

@interface EventDetailViewController ()
- (void)configureView;
@end

@implementation EventDetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;

@synthesize enterButton = _enterButton;

- (void)dealloc
{
  [_detailItem release];
  [_detailDescriptionLabel release];

  [_enterButton release];

  [super dealloc];
}

#pragma mark - UI callbacks

- (IBAction)enterWasPressed:(id)sender
{
  SongListViewController *vc = [[SongListViewController alloc] init];
  [self.navigationController pushViewController: vc
				      animated: YES];
  [vc release];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];

        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

  if (self.detailItem) {
      self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
  }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
  self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      //self.title = NSLocalizedString(@"Detail", @"Detail");
      self.title = @"Party Detail";
    }
    return self;
}
							
@end
