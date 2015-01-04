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

@interface NoListingViewController ()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet UIButton *addApartmentBtn;

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
}

- (IBAction)addApartment:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
        [UIAlertView showWithTitle:@""
                           message:@"Cannot send emails from this device!"
                 cancelButtonTitle:@"Dismiss"
                 otherButtonTitles:nil
                          tapBlock:nil];
    
    MFMailComposeViewController *mail = [MFMailComposeViewController new];
    
    mail.mailComposeDelegate = self;
    
    [mail setSubject:@"New Listing"];
    
    NSArray *toRecipients = [NSArray arrayWithObject:@"admin_account@demo.com"];
    NSArray *ccRecipients = @[];
    NSArray *bccRecipients = @[];
    
    [mail setToRecipients:toRecipients];
    [mail setCcRecipients:ccRecipients];
    [mail setBccRecipients:bccRecipients];
    
    NSString *emailBody = @"Hi there, I would like to add my apartment here...";
    [mail setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:mail animated:YES completion:NULL];
}

#pragma mark - MailComposer delegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(result != MFMailComposeResultCancelled && result != MFMailComposeResultFailed)
        [UIAlertView showWithTitle:@""
                           message:@"An error occurred, please try again."
                 cancelButtonTitle:@"Dismiss"
                 otherButtonTitles:nil
                          tapBlock:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
