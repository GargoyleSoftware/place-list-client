//
//  SongCell.h
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *songImageView;
@property (nonatomic, retain) IBOutlet UILabel *songLabel;
@property (nonatomic, retain) IBOutlet UIButton *upButton;
@property (nonatomic, retain) IBOutlet UIButton *downButton;

@end
