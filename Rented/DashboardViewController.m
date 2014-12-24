//
//  DashboardViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 23/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "DashboardViewController.h"

@interface DashboardViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLbl;
@property (weak, nonatomic) IBOutlet UIButton *myPlaceBtn;
@property (weak, nonatomic) IBOutlet UIButton *otherPlacesBtn;
@property (weak, nonatomic) IBOutlet UIButton *likesBtn;
@property (weak, nonatomic) IBOutlet UIButton *locationLbl;
@property (weak, nonatomic) IBOutlet UIButton *preferencesBtn;
@property (weak, nonatomic) IBOutlet UIButton *saySomethingBtn;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setVisualDetails];
}

- (void)setVisualDetails
{
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarView.backgroundColor = StatusBarBackgroundColor;
    [self.view addSubview:statusBarView];
    
    _myPlaceBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:15.0];
    _otherPlacesBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:15.0];
    _likesBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:15.0];
    
    _preferencesBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _saySomethingBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    
    _usernameLbl.font = [UIFont fontWithName:@"GothamRounded-Bold" size:13.0];
    _locationLbl.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:10.0];
    
    _profileImgView.layer.cornerRadius = _profileImgView.frame.size.width/2;
    _profileImgView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Handlers

- (IBAction)openMyPlace:(id)sender {
}

- (IBAction)openOtherPlaces:(id)sender {
}

- (IBAction)openMyLikes:(id)sender {
}

- (IBAction)showPreferences:(id)sender {
}

- (IBAction)sendEmail:(id)sender {
}



@end
