//
//  NothingCell.h
//  Rented
//
//  Created by Cristian Olteanu on 2/13/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NothingCellDelegate <NSObject>

-(void)shareFlip;

@end

@interface NothingCell : UITableViewCell

@property (nonatomic, strong) id <NothingCellDelegate> delegate;

@end
