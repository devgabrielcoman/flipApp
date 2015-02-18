//
//  LikesTableViewCell.h
//  Rented
//
//  Created by Cristian Olteanu on 2/17/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "ShadowLabel.h"

@interface LikesTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet ShadowLabel* usernameLabel;
@property (weak, nonatomic) IBOutlet ShadowLabel* timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView* clockImageView;
@property (weak, nonatomic) IBOutlet UIView* profilePictureContainer;
@property (weak, nonatomic) IBOutlet AsyncImageView* profilePictureImageView;
@property (weak, nonatomic) IBOutlet UIView* lineView;

@property (weak, nonatomic) PFObject* favorite;

-(void)customiseWithObject:(PFObject*)favorite;

@end
