//
//  ContactViewController.h
//  Rented
//
//  Created by Lucian Gherghel on 21/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *requestMessageLbl;
@property (weak, nonatomic) IBOutlet UIImageView *apartmentImageView;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelRequestBtn;
@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;

@property UIImage *apartmentSnapshot;
@property NSString *message;
@property PFObject *apartment;

@end
