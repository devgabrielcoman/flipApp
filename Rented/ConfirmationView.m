//
//  ConfirmationView.m
//  Rented
//
//  Created by Lucian Gherghel on 22/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ConfirmationView.h"
#import "UIColor+ColorFromHexString.h"

@implementation ConfirmationView

- (void)awakeFromNib
{
    _uploadCredentialsBtn.titleLabel.numberOfLines = 2;
    _keepBrowsingBtn.titleLabel.numberOfLines = 2;
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor colorFromHexString:@"d6d6d6"].CGColor;
    
    _uploadCredentialsBtn.layer.borderWidth = 1.0f;
    _uploadCredentialsBtn.layer.borderColor = [UIColor colorFromHexString:@"d6d6d6"].CGColor;
    
    _keepBrowsingBtn.layer.borderWidth = 1.0f;
    _keepBrowsingBtn.layer.borderColor = [UIColor colorFromHexString:@"d6d6d6"].CGColor;
}

- (IBAction)uploadCredentials:(id)sender
{
    [self dismissCurrentView];
}

- (IBAction)keepBrowsing:(id)sender
{
    [self dismissCurrentView];
}

- (void)dismissCurrentView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
