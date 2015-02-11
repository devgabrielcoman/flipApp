//
//  AdminUserTableViewCell.h
//  Rented
//
//  Created by Cristian Olteanu on 2/5/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>



@interface AdminUserTableViewCell : UITableViewCell

@property (weak, nonatomic)     IBOutlet    AsyncImageView*     profilePictureImageView;
@property (weak, nonatomic)     IBOutlet    UILabel*            usernameLabel;
@property (weak, nonatomic)     IBOutlet    UISwitch*           verifiedSwitch;

@property (strong, nonatomic)               PFUser*             user;

-(void)customiseWithUser: (PFUser*) user;

@end
