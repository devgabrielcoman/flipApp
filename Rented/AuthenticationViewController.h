//
//  AuthenticationViewController.h
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthenticationViewController : UIViewController

@property (nonatomic, weak) IBOutlet    UILabel*    smallWhyFacebookLoginLabel;
@property (nonatomic, weak) IBOutlet    UILabel*    whyFacebookLoginLabel;
@property (nonatomic, weak) IBOutlet    UILabel*    bigWhyFacebookLoginLabel;
@property (nonatomic, weak) IBOutlet    UILabel*    multipleLineLabel;

@property (nonatomic, strong)   IBOutlet    UILabel*    loginLabel;
@property (nonatomic, strong)   IBOutlet    UILabel*    tutorial1Label;
@property (nonatomic, strong)   IBOutlet    UILabel*    tutorial2Label;
@property (nonatomic, strong)   IBOutlet    UILabel*    tutorial3Label;

@property (nonatomic, strong)   IBOutlet    UIImageView*dotPage0;
@property (nonatomic, strong)   IBOutlet    UIImageView*dotPage1;
@property (nonatomic, strong)   IBOutlet    UIImageView*dotPage2;
@property (nonatomic, strong)   IBOutlet    UIImageView*dotPage3;


@property (nonatomic, strong)   IBOutlet    UIImageView*loginIcon1;
@property (nonatomic, strong)   IBOutlet    UIImageView*loginIcon2;

@property (nonatomic, strong)   IBOutlet    UIImageView*tutorial1Icon1;
@property (nonatomic, strong)   IBOutlet    UIImageView*tutorial1Icon2;
@property (nonatomic, strong)   IBOutlet    UIImageView*tutorial1Icon3;

@property (nonatomic, strong)   IBOutlet    UIImageView*tutorial2Icon1;
@property (nonatomic, strong)   IBOutlet    UIImageView*tutorial2Icon2;
@property (nonatomic, strong)   IBOutlet    UIImageView*tutorial2Icon3;

@property (nonatomic, strong)   IBOutlet    UIImageView*tutorial3Icon1;
@property (nonatomic, strong)   IBOutlet    UIImageView*tutorial3Icon2;
@property (nonatomic, strong)   IBOutlet    UIImageView*tutorial3Icon3;

@property (nonatomic, weak) IBOutlet    UIView*     parentContainerView;
@property (nonatomic, weak) IBOutlet    UIView*     iconsContainerView;


@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *smallWidthConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *bigWidthConstraint;

@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *smallYPositionConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *yPositionConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *yPositionConstraint2;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *bigYPositionConstraint;

@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *loginIcon1CenteredConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *loginIcon2CenteredConstraint;

@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *tutorial1Icon1CenteredConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *tutorial1Icon2ProportionConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *tutorial1Icon3CenteredConstraint;

@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *tutorial2Icon1CenteredConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *tutorial2Icon2ProportionConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *tutorial2Icon3CenteredConstraint;

@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *tutorial3Icon1CenteredConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *tutorial3Icon2ProportionConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *tutorial3Icon3CenteredConstraint;

@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *loginButtonCenteredConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *whyFacebookCenteredConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *nextButtonCenteredConstraint;
@property (nonatomic, strong)   IBOutlet    NSLayoutConstraint *closeButtonCenteredConstraint;


@property (nonatomic)   NSInteger   pageNumber;


@end
