//
//  LikesTableViewCell.m
//  Rented
//
//  Created by Cristian Olteanu on 2/17/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "LikesTableViewCell.h"


@implementation LikesTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width/2;
    self.profilePictureImageView.layer.masksToBounds = YES;
    
    [self.profilePictureContainer setClipsToBounds:NO];
    self.profilePictureContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.profilePictureContainer.layer.shadowRadius = 1.5f;
    self.profilePictureContainer.layer.shadowOffset = CGSizeMake(0.f, 1.f);
    self.profilePictureContainer.layer.shadowOpacity = 0.5f;
    self.profilePictureContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.profilePictureContainer.bounds cornerRadius:self.profilePictureImageView.frame.size.width/2].CGPath;
    
    self.lineView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.lineView.layer.shadowRadius = 1.5f;
    self.lineView.layer.shadowOffset = CGSizeMake(0.f, 0.5f);
    self.lineView.layer.shadowOpacity = 0.5f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)customiseWithObject:(PFObject*)object
{
    self.favorite = object;
    PFUser *user= object[@"user"];
    
    self.usernameLabel.text = user.username;
    self.profilePictureImageView.showActivityIndicator = YES;
    self.profilePictureImageView.image = nil;
    self.profilePictureImageView.imageURL = [NSURL URLWithString:user[@"profilePictureUrl"]];
    
    NSDate* favoriteDate = [NSDate dateWithTimeIntervalSince1970:[object[@"timestamp"] doubleValue]];
    
    NSInteger numberOfSeconds = [[NSDate date] timeIntervalSinceDate:favoriteDate];
    NSInteger numberOfMinutes = numberOfSeconds/60;
    
    if (numberOfMinutes> 60)
    {
        NSInteger numberOfHours = numberOfMinutes/60;
        
        if (numberOfHours>24)
        {
            NSInteger numberOfDays = numberOfHours/24;
            
            if(numberOfDays>1)
            {
                [self.timeLabel setText:[NSString stringWithFormat:@"%d days ago",numberOfDays]];
            }
            else
            {
                [self.timeLabel setText:[NSString stringWithFormat:@"one day ago"]];
            }
            
        }
        else
        {
            if (numberOfHours>1)
            {
                [self.timeLabel setText:[NSString stringWithFormat:@"%d hours ago",numberOfHours]];
            }
            else
            {
                [self.timeLabel setText:[NSString stringWithFormat:@"one hour ago"]];
            }
            
        }
    }
    else
    {
        if (numberOfMinutes>1)
        {
            [self.timeLabel setText:[NSString stringWithFormat:@"%d minutes ago",numberOfMinutes] ];
        }
        else
        {
            if (numberOfMinutes==0)
            {
                [self.timeLabel setText:[NSString stringWithFormat:@"less than a minute ago"] ];
            }
            else
            {
                [self.timeLabel setText:[NSString stringWithFormat:@"a minute ago"] ];
            }
        }
        
    }
    
}


@end
