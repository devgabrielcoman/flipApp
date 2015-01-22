//
//  ContactViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 21/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ContactViewController.h"
#import "UIColor+ColorFromHexString.h"
#import "UIImage+ProportionalFill.h"
#import <MessageUI/MessageUI.h>
#import <UIAlertView+Blocks.h>

@interface ContactViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _cancelRequestBtn.backgroundColor = [UIColor colorFromHexString:@"8f9da7"];
    _apartmentImageView.image = [_apartmentSnapshot imageCroppedToFitSize:_apartmentImageView.frame.size];
    _requestMessageLbl.text = _message;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (IBAction)dismissAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelRequest:(id)sender
{
    [DEP.api.apartmentApi removeApartmentRequest:_apartment completion:^(BOOL succeeded) {
        RTLog(@"Cancelled request for apartment");
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)contact:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
        [UIAlertView showWithTitle:@""
                           message:@"Cannot send emails from this device!"
                 cancelButtonTitle:@"Dismiss"
                 otherButtonTitles:nil
                          tapBlock:nil];
    
    MFMailComposeViewController *mail = [MFMailComposeViewController new];
    
    mail.mailComposeDelegate = self;
    
    [mail setSubject:@"Hello"];
    
    NSArray *toRecipients = [NSArray arrayWithObject:@"hello@hiflip.com"];
    NSArray *ccRecipients = @[];
    NSArray *bccRecipients = @[];
    
    [mail setToRecipients:toRecipients];
    [mail setCcRecipients:ccRecipients];
    [mail setBccRecipients:bccRecipients];
    
    NSString *emailBody = @"I would like to tell you something...";
    [mail setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:mail animated:YES completion:NULL];
}

#pragma mark - MailComposer delegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(result == MFMailComposeResultFailed)
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
