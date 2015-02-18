//
//  lastFeedCell.h
//  Rented
//
//  Created by Cristian Olteanu on 2/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol lastFeedCellDelegate <NSObject>

-(void)shareFlip;

@end

@interface lastFeedCell : UITableViewCell

@property (nonatomic, strong) id <lastFeedCellDelegate> delegate;

@end
