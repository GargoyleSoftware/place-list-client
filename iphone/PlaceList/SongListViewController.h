//
//  SongListViewControllerViewController.h
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SongCell.h"

@class SongModel;

@interface SongListViewController : UITableViewController <SongCellDelegate>

//@property (nonatomic, retain) NSMutableArray *songs;
@property (nonatomic, retain) SongModel *model;

@end
