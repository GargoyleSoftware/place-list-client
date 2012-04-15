//
//  SongListViewControllerViewController.m
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import "SongListViewController.h"

#import "SongCell.h"
#import "SongModel.h"

#import "NetworkManager.h"

@interface SongListViewController ()

@end

@implementation SongListViewController

//@synthesize songs = _songs;
@synthesize model = _model;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
      //self.navigationItem.title = @"Song List";
      self.title = @"Song List";

      self.model = [SongModel sharedInstance];

      //self.songs = [NSMutableArray array];
      //[self.songs addObject: @"What is Love"];
      //[self.songs addObject: @"What's my age again"];
      //[self.songs addObject: @"1976"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addWasPressed:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (void)addWasPressed:(id)sender
{
  

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return self.model.count;
    return [self.model sortedKeys].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"SongCell";
  SongCell *cell = (SongCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SongCell" owner:self options:nil];
    cell = (SongCell *)[nib objectAtIndex:0];
  }
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  // Configure the cell...

  NSUInteger row = indexPath.row;
  //cell.textLabel.text = @"Hello";
  //cell.textLabel.text = [self.songs objectAtIndex: row];
    
  NSString *songId = [[self.model sortedKeys] objectAtIndex: row];
  
  //cell.songLabel.text = [self.songs objectAtIndex: row];
  cell.songLabel.text = songId;
  cell.songImageView.image = [UIImage imageNamed: @"music-note"];

  cell.tag = row;
  cell.delegate = self;

  return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - SongCellDelegate

- (void)cellDidVote:(NSInteger)cellTag remove:(BOOL)remove
{
  //id song = [self.songs objectAtIndex: cellTag];
  //NSDictionary *song = [[self.model sortedKeys] objectAtIndex: cellTag];

  NSString *trackId = [[self.model sortedKeys] objectAtIndex: cellTag];
  if (!remove) {
    [[NetworkManager sharedInstance] upvoteTrack: trackId
					  remove: remove];

    NSLog(@"Song was UPVoted: %@", [trackId description]);
  } else {
    [[NetworkManager sharedInstance] upvoteTrack: trackId
					  remove: remove];
    NSLog(@"Song was DOWNvoted: %@", [trackId description]);
  }

}

@end
