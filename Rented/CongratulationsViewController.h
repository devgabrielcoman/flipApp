//
//  CongratulationsViewController.h
//  Rented
//
//  Created by Cristian Olteanu on 2/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CongratulationsViewController : UIViewController


@property (weak, nonatomic) IBOutlet UILabel* congratulationsLabel;
@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet UIButton* shareButton;

-(IBAction)shareButtonTapped:(id)sender;
-(IBAction)backButtonTapped:(id)sender;

@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) PFObject* apartment;


@end
