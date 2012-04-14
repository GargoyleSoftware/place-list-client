//
//  EventListViewController.h
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventDetailViewController;
@class NTWebSocket;

#import <CoreData/CoreData.h>

@interface EventListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) EventDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NTWebSocket *webSocket;

@end
