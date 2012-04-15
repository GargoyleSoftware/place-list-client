//
//  SongCell.m
//  PlaceList
//
//  Created by David Kay on 4/14/12.
//  Copyright (c) 2012 Gargoyle Software. All rights reserved.
//

#import "SongCell.h"

@implementation SongCell

@synthesize songImageView = _songImageView;
@synthesize songLabel = _songLabel;
@synthesize upButton = _upButton;
@synthesize downButton = _downButton;

@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Private Methods

- (void)voteWasPressed:(BOOL)remove
{
  NSLog(@"voteWasPressed");
  if (self.delegate) {
    [self.delegate cellDidVote: self.tag remove: remove];
  }
}

- (void)toggleSelected:(UIButton *)sender
{
  sender.selected = ! sender.selected;
}

#pragma mark - UI Callbacks

- (IBAction)downVoteWasPressed:(id)sender
{
  [self voteWasPressed: YES];
}

- (IBAction)upVoteWasPressed:(id)sender
{
  UIButton *button = (UIButton *)sender;
  [self toggleSelected: button];

  [self voteWasPressed: !button.selected];
}


@end
