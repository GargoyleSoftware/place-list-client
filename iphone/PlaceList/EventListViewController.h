//
//  EventListViewController.h
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FBConnect.h"

@class EventDetailViewController;
@class NTWebSocket;


@interface EventListViewController : UITableViewController <NSFetchedResultsControllerDelegate, FBRequestDelegate>

@property (strong, nonatomic) EventDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NTWebSocket *webSocket;

@property (strong, nonatomic) NSArray *events;

@end
