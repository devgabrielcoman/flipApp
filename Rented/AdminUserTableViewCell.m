//
//  AdminUserTableViewCell.m
//  Rented
//
//  Created by Cristian Olteanu on 2/5/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "AdminUserTableViewCell.h"

@implementation AdminUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.profilePictureImageView.layer setCornerRadius:30];
    [self.profilePictureImageView setClipsToBounds:YES];
    [self.profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)customiseWithUser: (PFUser*) user
{
    self.user = user;
    
    [self.profilePictureImageView setCrossfadeDuration:0];
    [self.profilePictureImageView setImage:nil];
    [self.profilePictureImageView setShowActivityIndicator:YES];
    [self.profilePictureImageView setImageURL:[NSURL URLWithString:user[@"profilePictureUrl"]]];
    [self.usernameLabel setText:user[@"username"]];
    if ([user[@"isVerified"] integerValue] == 0)
    {
        [self.verifiedSwitch setOn:NO];
    }
    else
    {
        [self.verifiedSwitch setOn:YES];
    }
}

-(IBAction)toggleSwithState:(id)sender
{
    [DEP.api.userApi toggleVerifiedForUser:self.user verified:self.verifiedSwitch.isOn];
}

@end
