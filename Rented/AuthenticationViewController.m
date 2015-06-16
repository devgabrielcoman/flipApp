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
#import "TutorialPage1ViewController.h"
#import <AFNetworking.h>
#import "MBProgressHUD.h"

#define kDotOff @"dot_offX2"
#define kDotOn @"Dot_onX2"

@interface AuthenticationViewController ()



@end

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setVisualDetails];
    
    self.pageNumber = 0;
    
    UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whyFacebookLoginLabelTapped:)];
    [self.whyFacebookLoginLabel addGestureRecognizer:tapGesture];
    
    NSRange underlineRange = [self.multipleLineLabel.text rangeOfString:@"never"];
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:self.multipleLineLabel.text];
    [attributedString addAttribute:NSUnderlineStyleAttributeName
                             value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                             range:underlineRange];
    [self.multipleLineLabel setAttributedText:attributedString];
    
}

- (void)setVisualDetails
{

    

}

-(void)viewWillLayoutSubviews
{
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    
    self.tutorial1Icon2ProportionConstraint.constant = - self.tutorial1Icon2.frame.size.height;
    self.tutorial2Icon2ProportionConstraint.constant = - self.tutorial2Icon2.frame.size.height;
    self.tutorial3Icon2ProportionConstraint.constant = - self.tutorial3Icon2.frame.size.height;
    
    [self.iconsContainerView layoutSubviews];
}
-(void)viewDidAppear:(BOOL)animated
{

}

- (IBAction)loginWithFacebook:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [DEP.api.userApi authenticateUserWithFacebook:^(BOOL authenticated) {
        if (authenticated)
        {
            [[Mixpanel sharedInstance] track:@"Successful FB Login"];

            self.locationManager = [[CLLocationManager alloc]init];
            [self.locationManager setDelegate:self];
            
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            [self.locationManager startUpdatingLocation];
            

        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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

-(IBAction)swipeLeft:(id)sender
{
    [self nextPage];
}

-(void)nextPage;
{
    if (self.pageNumber ==3 || self.parentContainerView.frame.origin.y != 0)
    {
        return;
    }

    if (self.pageNumber ==2)
    {
        //go from page 2 to 3
        
        //dots
        [self.dotPage2 setImage:[UIImage imageNamed:kDotOff]];
        [self.dotPage3 setImage:[UIImage imageNamed:kDotOn]];
        
        //labels
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.tutorial2Label setAlpha:0];
        } completion:^(BOOL finished) {
            
        }];
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.tutorial3Label setAlpha:1];
            
        } completion:^(BOOL finished) {
            
        }];
        
        //icons
        
        self.tutorial3Icon1CenteredConstraint.constant =   wScr;
        self.tutorial3Icon3CenteredConstraint.constant = - wScr;
        
        [self.iconsContainerView layoutSubviews];
        
        self.tutorial3Icon1CenteredConstraint.constant = 0;
        self.tutorial3Icon2ProportionConstraint.constant = 0;
        self.tutorial3Icon3CenteredConstraint.constant = 0;
        
        self.tutorial2Icon1CenteredConstraint.constant = - wScr;
        self.tutorial2Icon2ProportionConstraint.constant = - self.tutorial2Icon2.frame.size.height;
        self.tutorial2Icon3CenteredConstraint.constant =   wScr;
        
        [UIView animateWithDuration:1
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.iconsContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        //buttons
        
        self.loginButtonCenteredConstraint.constant = -wScr;
        
        [self.parentContainerView layoutSubviews];
        
        self.loginButtonCenteredConstraint.constant = 0;
        
        self.nextButtonCenteredConstraint.constant = wScr;
        
        [UIView animateWithDuration:0.75
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.parentContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        self.pageNumber =3;

    }
    
    if (self.pageNumber ==1)
    {
        //go from page 1 to 2
        
        //dots
        [self.dotPage1 setImage:[UIImage imageNamed:kDotOff]];
        [self.dotPage2 setImage:[UIImage imageNamed:kDotOn]];
        
        //labels
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.tutorial1Label setAlpha:0];
            
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.tutorial2Label setAlpha:1];
            
        } completion:^(BOOL finished) {
            
        }];

        
        //icons
        
        self.tutorial2Icon1CenteredConstraint.constant =   wScr;
        self.tutorial2Icon3CenteredConstraint.constant = - wScr;
        
        [self.iconsContainerView layoutSubviews];
        
        self.tutorial2Icon1CenteredConstraint.constant = 0;
        self.tutorial2Icon2ProportionConstraint.constant = 0;
        self.tutorial2Icon3CenteredConstraint.constant = 0;
        
        self.tutorial1Icon1CenteredConstraint.constant = - wScr;
        self.tutorial1Icon2ProportionConstraint.constant = - self.tutorial1Icon2.frame.size.height;
        self.tutorial1Icon3CenteredConstraint.constant =   wScr;
        
        [UIView animateWithDuration:1
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.iconsContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        self.pageNumber =2;

    }
    
    if (self.pageNumber ==0)
    {
        //go from page 0 to 1
        
        //dots
        [self.dotPage0 setImage:[UIImage imageNamed:kDotOff]];
        [self.dotPage1 setImage:[UIImage imageNamed:kDotOn]];
        
        //labels
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

            [self.loginLabel setAlpha:0];
            
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.tutorial1Label setAlpha:1];
            
        } completion:^(BOOL finished) {
            
        }];
        
        //icons
        
        self.tutorial1Icon1CenteredConstraint.constant =   wScr;
        self.tutorial1Icon3CenteredConstraint.constant = - wScr;
        
        [self.iconsContainerView layoutSubviews];
        
        self.tutorial1Icon1CenteredConstraint.constant = 0;
        self.tutorial1Icon2ProportionConstraint.constant = 0;
        self.tutorial1Icon3CenteredConstraint.constant = 0;
        
        self.loginIcon1CenteredConstraint.constant = - wScr;
        self.loginIcon2CenteredConstraint.constant =   wScr;

        [UIView animateWithDuration:1
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.iconsContainerView layoutSubviews];
            
        } completion:^(BOOL finished) {
            
        }];
        
        //buttons
        
        self.nextButtonCenteredConstraint.constant = -wScr;
        self.closeButtonCenteredConstraint.constant = -wScr;

        [self.parentContainerView layoutSubviews];

        self.nextButtonCenteredConstraint.constant = 0;
        self.closeButtonCenteredConstraint.constant = 0;
        
        self.loginButtonCenteredConstraint.constant = wScr;
        self.whyFacebookCenteredConstraint.constant = wScr;
        
        [UIView animateWithDuration:0.75
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.parentContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        self.pageNumber =1;

    }
}
-(IBAction)swipeRight:(id)sender
{
    [self previousPage];
}
-(void)previousPage
{
    if (self.pageNumber ==0 || self.parentContainerView.frame.origin.y != 0)
    {
        return;
    }
    
    if (self.pageNumber ==1)
    {
        //go from page 1 to 0
        
        //dots
        [self.dotPage1 setImage:[UIImage imageNamed:kDotOff]];
        [self.dotPage0 setImage:[UIImage imageNamed:kDotOn]];
        
        
        //labels
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.tutorial1Label setAlpha:0];
            
        } completion:^(BOOL finished) {
            
        }];

    
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.loginLabel setAlpha:1];
            
        } completion:^(BOOL finished) {
            
        }];
    
        //icons
    
        self.loginIcon1CenteredConstraint.constant = - wScr;
        self.loginIcon2CenteredConstraint.constant =   wScr;
        
        [self.iconsContainerView layoutSubviews];
        
        self.loginIcon1CenteredConstraint.constant = 0;
        self.loginIcon2CenteredConstraint.constant = 0;
        
        self.tutorial1Icon1CenteredConstraint.constant =   wScr;
        self.tutorial1Icon2ProportionConstraint.constant = - self.tutorial1Icon2.frame.size.height;
        self.tutorial1Icon3CenteredConstraint.constant = - wScr;
        
        [UIView animateWithDuration:1
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.iconsContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];

        //buttons
        self.loginButtonCenteredConstraint.constant = wScr;
        self.whyFacebookCenteredConstraint.constant = wScr;
        
        [self.parentContainerView layoutSubviews];

        self.loginButtonCenteredConstraint.constant = 0;
        self.whyFacebookCenteredConstraint.constant = 0;
        
        self.nextButtonCenteredConstraint.constant = -wScr;
        self.closeButtonCenteredConstraint.constant = -wScr;
    
        
        [UIView animateWithDuration:0.75
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.parentContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        self.pageNumber =0;

    }
    
    if (self.pageNumber ==2)
    {
        
        //go from page 2 to 1
        
        //dots
        [self.dotPage2 setImage:[UIImage imageNamed:kDotOff]];
        [self.dotPage1 setImage:[UIImage imageNamed:kDotOn]];
        
        
        //labels
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.tutorial2Label setAlpha:0];
            
        } completion:^(BOOL finished) {
            
        }];
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.tutorial1Label setAlpha:1];
            
        } completion:^(BOOL finished) {
            
        }];
        
        //icons
        
        self.tutorial1Icon1CenteredConstraint.constant = - wScr;
        self.tutorial1Icon3CenteredConstraint.constant =   wScr;
        
        [self.iconsContainerView layoutSubviews];
        
        self.tutorial1Icon1CenteredConstraint.constant = 0;
        self.tutorial1Icon2ProportionConstraint.constant = 0;
        self.tutorial1Icon3CenteredConstraint.constant = 0;
        
        self.tutorial2Icon1CenteredConstraint.constant =   wScr;
        self.tutorial2Icon2ProportionConstraint.constant = - self.tutorial2Icon2.frame.size.height;
        self.tutorial2Icon3CenteredConstraint.constant = -  wScr;
        
        [UIView animateWithDuration:1
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.iconsContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        self.pageNumber =1;

    }
    
    if (self.pageNumber ==3)
    {
        
        //go from page 3 to 2
        
        //dots
        [self.dotPage3 setImage:[UIImage imageNamed:kDotOff]];
        [self.dotPage2 setImage:[UIImage imageNamed:kDotOn]];
        
        //labels
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.tutorial3Label setAlpha:0];
            
        } completion:^(BOOL finished) {
        
        }];
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.tutorial2Label setAlpha:1];
            
        } completion:^(BOOL finished) {
            
        }];
        
        //icons
        
        self.tutorial2Icon1CenteredConstraint.constant = - wScr;
        self.tutorial2Icon3CenteredConstraint.constant =   wScr;
        
        [self.iconsContainerView layoutSubviews];
        
        self.tutorial2Icon1CenteredConstraint.constant = 0;
        self.tutorial2Icon2ProportionConstraint.constant = 0;
        self.tutorial2Icon3CenteredConstraint.constant = 0;
        
        self.tutorial3Icon1CenteredConstraint.constant =   wScr;
        self.tutorial3Icon2ProportionConstraint.constant = - self.tutorial3Icon2.frame.size.height;
        self.tutorial3Icon3CenteredConstraint.constant = - wScr;
        
        [UIView animateWithDuration:1
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.iconsContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        //buttons
        
        self.nextButtonCenteredConstraint.constant = wScr;
        
        [self.parentContainerView layoutSubviews];
        
        self.nextButtonCenteredConstraint.constant = 0;
        
        self.loginButtonCenteredConstraint.constant = - wScr;
        
        [UIView animateWithDuration:0.75
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.parentContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        self.pageNumber =2;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(IBAction)whyFacebookLoginLabelTapped:(id)sender
{
    [self.whyFacebookLoginLabel setUserInteractionEnabled:NO];
    
    self.yPositionConstraint.constant = self.bigYPositionConstraint.constant;
    self.widthConstraint.constant = self.bigWidthConstraint.constant;

    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:0 animations:^{
        
        [self.parentContainerView layoutSubviews];
    } completion:^(BOOL finished) {
       
        
    }];
    
    CGRect containerFrame = self.parentContainerView.frame;
    containerFrame.origin.y = -containerFrame.size.height/2.0;

    [UIView animateWithDuration:1.05 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:0 animations:^{
        
        self.parentContainerView.frame = containerFrame;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(IBAction)closeButtonTapped:(id)sender
{
    self.yPositionConstraint.constant = self.smallYPositionConstraint.constant;
    self.widthConstraint.constant = self.smallWidthConstraint.constant;
    
    [UIView animateWithDuration:1.05 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:0 animations:^{
        
        [self.parentContainerView layoutSubviews];
    } completion:^(BOOL finished) {
        
        [self.whyFacebookLoginLabel setUserInteractionEnabled:YES];

        
    }];
    
    CGRect containerFrame = self.parentContainerView.frame;
    containerFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0 options:0 animations:^{
        
        self.parentContainerView.frame = containerFrame;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(IBAction)nextButtonTapped:(id)sender
{
    [self nextPage];
}

-(IBAction)closeButton2Tapped:(id)sender
{
    
    if (self.pageNumber ==1)
    {
        
        [self previousPage];
        
    }
    
    if (self.pageNumber ==2)
    {
        
        //go from page 2 to 0
        
        //dots
        [self.dotPage2 setImage:[UIImage imageNamed:kDotOff]];
        [self.dotPage0 setImage:[UIImage imageNamed:kDotOn]];
        
        
        //labels
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.tutorial2Label setAlpha:0];
            [self.loginLabel setAlpha:1];
            
        } completion:^(BOOL finished) {
            
        }];
        
        //icons
        
        self.loginIcon1CenteredConstraint.constant = - wScr;
        self.loginIcon2CenteredConstraint.constant =   wScr;
        
        [self.iconsContainerView layoutSubviews];
        
        self.loginIcon1CenteredConstraint.constant = 0;
        self.loginIcon2CenteredConstraint.constant = 0;
        
        self.tutorial2Icon1CenteredConstraint.constant =   wScr;
        self.tutorial2Icon2ProportionConstraint.constant = - self.tutorial2Icon2.frame.size.height;
        self.tutorial2Icon3CenteredConstraint.constant = -  wScr;
        
        [UIView animateWithDuration:1
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.iconsContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        //buttons
        
        self.loginButtonCenteredConstraint.constant = wScr;
        self.whyFacebookCenteredConstraint.constant = wScr;
        
        [self.parentContainerView layoutSubviews];
        
        self.loginButtonCenteredConstraint.constant = 0;
        self.whyFacebookCenteredConstraint.constant = 0;
        
        self.nextButtonCenteredConstraint.constant = - wScr;
        self.closeButtonCenteredConstraint.constant = - wScr;
        
        [UIView animateWithDuration:0.75
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.parentContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        self.pageNumber =0;
        
    }
    
    if (self.pageNumber ==3)
    {
    
        //go from page 3 to 0
        
        //dots
        [self.dotPage3 setImage:[UIImage imageNamed:kDotOff]];
        [self.dotPage0 setImage:[UIImage imageNamed:kDotOn]];
        
        //labels
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.tutorial3Label setAlpha:0];
            [self.loginLabel setAlpha:1];
            
        } completion:^(BOOL finished) {
            
        }];
        
        //icons
        
        self.loginIcon1CenteredConstraint.constant = - wScr;
        self.loginIcon2CenteredConstraint.constant =   wScr;
        
        [self.iconsContainerView layoutSubviews];
        
        self.loginIcon1CenteredConstraint.constant = 0;
        self.loginIcon2CenteredConstraint.constant = 0;
        
        self.tutorial3Icon1CenteredConstraint.constant =   wScr;
        self.tutorial3Icon2ProportionConstraint.constant = - self.tutorial3Icon2.frame.size.height;
        self.tutorial3Icon3CenteredConstraint.constant = - wScr;
        
        [UIView animateWithDuration:1
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.iconsContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        //buttons
        
        self.whyFacebookCenteredConstraint.constant = wScr;
        
        [self.parentContainerView layoutSubviews];
        
        self.whyFacebookCenteredConstraint.constant = 0;
        
        self.closeButtonCenteredConstraint.constant = - wScr;
        
        [UIView animateWithDuration:0.75
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             
                             [self.parentContainerView layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        self.pageNumber =0;
    }
}

#pragma mark - CLLocationMagager delegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLGeocoder *geocoder = [CLGeocoder new];
    
    [geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
       
        CLPlacemark* placemark = [placemarks firstObject];
        
        NSString *city = placemark.locality;
        [[NSUserDefaults standardUserDefaults] setObject:city forKey:@"currentCity"];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNewUser"])
        {
            AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kHostString]];
            NSDictionary *params = @{@"userId": [PFUser currentUser].objectId,
                                     @"email": [PFUser currentUser].email};
            
            AFHTTPRequestOperation *op = [manager POST:@"invite/check" parameters:params  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFeedData" object:nil];
                }];
                
                NSLog(@"JSON: %@", responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            [op start];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFeedData" object:nil];
            }];
        }

        
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentCity"];
    if (!city || [city isEqualToString:@""])
    {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"currentCity"];   
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNewUser"])
    {
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kHostString]];
        NSDictionary *params = @{@"userId": [PFUser currentUser].objectId,
                                 @"email": [PFUser currentUser].email};
        
        AFHTTPRequestOperation *op = [manager POST:@"invite/check" parameters:params  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFeedData" object:nil];
            }];
            
            NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [op start];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFeedData" object:nil];
        }];
    }

}

@end
