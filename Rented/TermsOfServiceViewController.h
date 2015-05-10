//
//  TermsOfServiceViewController.h
//  Rented
//
//  Created by Cristian Olteanu on 3/15/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardViewController.h"

@interface TermsOfServiceViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView* textView;

@property (nonatomic, weak) IBOutlet UIButton* logoutButton;

@property (nonatomic, strong) DashboardViewController* dashboardVC;

@end
