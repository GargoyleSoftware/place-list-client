//
//  EventListViewController.m
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

//#import <SocketRocket/SRSocketRocket.h>
//#import <SocketRocket/SRWebSocket.h>
#import "SRWebSocket.h"

#import "EventListViewController.h"

#import "EventDetailViewController.h"
#import "Macros.h"
#import "NTWebSocket.h"
#import "NTAppDelegate.h"


@interface EventListViewController ()
  - (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation EventListViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

@synthesize webSocket = _webSocket;
@synthesize events = _events;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    //self.title = NSLocalizedString(@"Master", @"Master");
    self.title = @"Events";
    //self.navigationItem.title = @"Song List";
  }
  return self;
}

#pragma mark - Cleanup

- (void)dealloc
{
  [_detailViewController release];
  [__fetchedResultsController release];
  [__managedObjectContext release];
  [super dealloc];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  //UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-default"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
  //self.navigationItem.leftBarButtonItem = self.editButtonItem;
  //self.navigationItem.leftBarButtonItem = backButton;

  UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
  //UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openSocketConnection:)] autorelease];
  //self.navigationItem.rightBarButtonItem = addButton;

}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [self getAllAttendingEvents];

}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Public Methods

#pragma mark - Facebook Methods

- (void)getAllAttendingEvents
{
  NTAppDelegate *appDelegate = (NTAppDelegate *)[[UIApplication sharedApplication] delegate];
  // get information about the currently logged in user
  [appDelegate.facebook requestWithGraphPath:@"me/events/attending" andDelegate:self];
}

#pragma mark - FBRequestDelegate Methods


/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request {
  
  NSLog(@"requestLoading");

}

/**
 * Called when the Facebook API request has returned a response.
 *
 * This callback gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {

  NSLog(@"didReceiveResponse");
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {

  NSLog(@"didFailWithError: %@", error);
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {

  NSLog(@"didLoad: %@", result);

  NSDictionary *dict = (NSDictionary *)result;

  NSArray *events = [dict objectForKey: @"data"];
  self.events = events;

  [self.tableView reloadData];
}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {

  NSLog(@"didLoadRawResponse");

}

#pragma mark - UI Callbacks

- (void)popViewController:(id)sender
{
  [self.navigationController popViewControllerAnimated: YES];
}

- (void)openSocketConnection:(id)sender
{
  NTWebSocket* webSocket = [[NTWebSocket alloc] init];
  [webSocket startWebSocket];
  self.webSocket = webSocket;
}

- (void)insertNewObject:(id)sender
{
  NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
  NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
  NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

  // If appropriate, configure the new managed object.
  // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
  [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];

  // Save the context.
  NSError *error = nil;
  if (![context save:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.events.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  //[self configureCell:cell atIndexPath:indexPath];

  NSDictionary *event = [self.events objectAtIndex: indexPath.row];

  cell.textLabel.text = [event objectForKey: @"name"];


  return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (!self.detailViewController) {
    self.detailViewController = [[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil] autorelease];
  }
  NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
  self.detailViewController.detailItem = object;
  [self.navigationController pushViewController:self.detailViewController animated:YES];
}



@end
