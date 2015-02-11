//
//  NoListingViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 03/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "NoListingViewController.h"
#import "UIColor+ColorFromHexString.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <UIAlertView+Blocks.h>
#import "AddApartmentViewController.h"
#import "KAProgressLabel.h"
#import "AppDelegate.h"
#import "DashboardViewController.h"
#import "RentedPanelController.h"




@interface NoListingViewController ()<MFMailComposeViewControllerDelegate,AddApartmentDelegate>

@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet UIButton *addApartmentBtn;
@property (weak, nonatomic) IBOutlet KAProgressLabel *plabel;

@end

@implementation NoListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _messageLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:13.0];
    _messageLbl.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    _addApartmentBtn.backgroundColor = [UIColor colorFromHexString:@"3b5998"];
    _addApartmentBtn.layer.cornerRadius = 2.0;
    _addApartmentBtn.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:15.0];
    
    [self.plabel setBackBorderWidth:3.0];
    [self.plabel setFrontBorderWidth:4];
    [self.plabel setColorTable: @{
                                  NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor lightGrayColor],
                                  NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor colorFromHexString:@"3b5998"]
                                  }];
    
    self.plabel.center = self.view.center;
    self.plabel.userInteractionEnabled = YES;

    
    if([DEP.authenticatedUser[@"listingStatus"] integerValue] == ListingRequested)
    {
        _addApartmentBtn.alpha = 0.0f;
        _messageLbl.text = @"Your request has been registered and apartment will be added as soon as possible.";
        [self.plabel setProgress:0.5
                          timing:TPPropertyAnimationTimingEaseOut
                        duration:1.0
                           delay:0.0];
    }
    else
    {
        [self.plabel setProgress:0.01
                          timing:TPPropertyAnimationTimingEaseOut
                        duration:1.0
                           delay:0.0];
    }
    
}

-(void)addApartmentFinieshedWithChanges:(BOOL)changes
{
    if (changes)
    {
        AppDelegate* appDelegate= (AppDelegate*)[UIApplication sharedApplication].delegate;
        [(DashboardViewController*)[(RentedPanelController*)appDelegate.rootViewController leftPanel] openMyPlace:nil];
    }
}

- (IBAction)addApartment:(id)sender
{
    
    AddApartmentViewController* addApartmentVC = [[AddApartmentViewController alloc] initWithNibName:@"AddApartmentViewController" bundle:nil];
    [addApartmentVC setDelegate:self];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:addApartmentVC] animated:YES completion:^{}];
    
    
    // old version w/ email request
    /*
    if (![MFMailComposeViewController canSendMail])
        [UIAlertView showWithTitle:@""
                           message:@"Cannot send emails from this device!"
                 cancelButtonTitle:@"Dismiss"
                 otherButtonTitles:nil
                          tapBlock:nil];
    
    MFMailComposeViewController *mail = [MFMailComposeViewController new];
    
    mail.mailComposeDelegate = self;
    
    [mail setSubject:@"New Listing"];
    
    NSArray *toRecipients = [NSArray arrayWithObject:@"admin@hiflip.com"];
    NSArray *ccRecipients = @[];
    NSArray *bccRecipients = @[];
    
    [mail setToRecipients:toRecipients];
    [mail setCcRecipients:ccRecipients];
    [mail setBccRecipients:bccRecipients];
    
    NSString *emailBody = @"Hi there, I would like to add my apartment here...";
    [mail setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:mail animated:YES completion:NULL];
     */
}

#pragma mark - MailComposer delegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(result == MFMailComposeResultFailed)
        [UIAlertView showWithTitle:@""
                           message:@"An error occurred, please try again."
                 cancelButtonTitle:@"Dismiss"
                 otherButtonTitles:nil
                          tapBlock:nil];
    else
    {
        if(result == MFMailComposeResultSent)
        {
            DEP.authenticatedUser[@"listingStatus"] = [NSNumber numberWithInt:ListingRequested];
            [DEP.authenticatedUser saveInBackground];
            _addApartmentBtn.alpha = 0.0f;
            _messageLbl.text = @"Your request has been registered and apartment will be added as soon as possible.";
            
            [self.plabel setProgress:0.5
                              timing:TPPropertyAnimationTimingEaseOut
                            duration:1.0
                               delay:0.0];
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
