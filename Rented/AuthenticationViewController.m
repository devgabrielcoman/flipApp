//
//  AuthenticationViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "UIColor+ColorFromHexString.h"
#import "UIImage+ProportionalFill.h"
#import "FeedViewController.h"
#import "UIViewController+JASidePanels.h"
#import <JASidePanelController.h>
#import "TutorialPageView.h"
#import "TermsOfServiceViewController.h"

@interface AuthenticationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *fbLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *tutorialBtn;
@property (weak, nonatomic) IBOutlet UILabel *flipLbl;

@end

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setVisualDetails];
}

- (void)setVisualDetails
{
    _messageLbl.font = [UIFont fontWithName:@"GothamRounded-Bold" size:20];
//    _messageLbl.layer.shadowOffset = CGSizeMake(0.5, 0.5);
//    _messageLbl.layer.shadowRadius = 0.5;
//    _messageLbl.layer.shadowOpacity = 0.5;
//    _messageLbl.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    _fbLoginBtn.backgroundColor = [UIColor colorFromHexString:@"3b5998"];
    _fbLoginBtn.layer.cornerRadius = 2.0;
    //_fbLoginBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Bold" size:15.0];
    _fbLoginBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_fbLoginBtn setImage:[[UIImage imageNamed:@"facebook-icon"] imageScaledToFitSize:CGSizeMake(20.0, 20.0)] forState:UIControlStateNormal];
    
    _tutorialBtn.layer.cornerRadius = 2.0;
    _tutorialBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    
    _backgroundImageView.image = [[UIImage imageNamed:@"fliptype_720"] imageScaledToFitSize:CGSizeMake(wScr, hScr)];
    _flipLbl.font = [UIFont fontWithName:@"GothamRounded-Bold" size:65.0];
    //_flipLbl.textColor = [UIColor colorFromHexString:@"4a90e2"];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UINavigationBar appearance] setBackgroundColor:[UIColor clearColor]];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
}
-(void)viewDidAppear:(BOOL)animated
{

}

- (IBAction)loginWithFacebook:(id)sender
{
    [DEP.api.userApi authenticateUserWithFacebook:^(BOOL authenticated) {
        if (authenticated)
        {
            [[Mixpanel sharedInstance] track:@"Successful FB Login"];

            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFeedData" object:nil];
            }];
        }
        else
        {
            [[[UIAlertView alloc]initWithTitle:nil message:@"There was a problem loging in. Please allow Flip to access your Facebook profile." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
    }];
}

-(IBAction)showTutorial:(id)sender
{
//    TutorialPageView* page1 = [[TutorialPageView alloc] initWithNibName:@"TutorialPageView" bundle:nil];
//    page1.image = [UIImage imageNamed:@"1"];
//    page1.index = 1;
//    [self.navigationController pushViewController:page1 animated:YES];
    [self setTitle:@" "];
    TermsOfServiceViewController* tosVC = [[TermsOfServiceViewController alloc]init];
    [self.navigationController pushViewController:tosVC animated:YES];
}

-(IBAction)tosButtonTapped:(id)sender
{
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
