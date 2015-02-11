//
//  TutorialViewController.h
//  Rented
//
//  Created by macmini on 1/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)closeTutorial:(id)sender;
@end
