//
//  AuthenticationDoneViewController.h
//  Rented
//
//  Created by Cristian Olteanu on 5/11/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AuthenticationDoneViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *noLocationContainer;
@property (nonatomic, weak) IBOutlet UIView *listContainer;
@property (nonatomic, weak) IBOutlet UIView *cityContainer;

@property (nonatomic, weak) IBOutlet UILabel* rankingLabel;


@end
